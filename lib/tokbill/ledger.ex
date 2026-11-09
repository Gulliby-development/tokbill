defmodule Tokbill.Ledger do
  @moduledoc false

  @model_pattern ~r|\A[A-Za-z0-9._:/-]{1,40}\z|
  @tag_pattern ~r/\A[a-z0-9_-]{1,20}\z/
  @date_pattern ~r/\A[0-9]{4}-[0-9]{2}-[0-9]{2}\z/

  def parse(text) when is_binary(text) do
    lines = ledger_lines(text)

    result =
      lines
      |> Enum.with_index(1)
      |> Enum.reduce_while(%{prices: %{}, uses: [], budgets: []}, fn {line, number}, acc ->
        case process_line(line, number, acc) do
          {:ok, next} -> {:cont, next}
          {:error, failure} -> {:halt, {:error, failure}}
        end
      end)

    case result do
      ledger when is_map(ledger) ->
        uses = Enum.reverse(ledger.uses)
        budgets = Enum.reverse(ledger.budgets)

        case Enum.find(uses, fn use -> not Map.has_key?(ledger.prices, use.model) end) do
          nil -> {:ok, %{ledger | uses: uses, budgets: budgets}}
          use -> {:error, failure(use.line, "no price for #{use.model}")}
        end

      error ->
        error
    end
  end

  defp ledger_lines(text) do
    terminated? = byte_size(text) > 0 and :binary.last(text) == ?\n
    pieces = :binary.split(text, "\n", [:global])
    pieces = if terminated?, do: Enum.drop(pieces, -1), else: pieces

    pieces
    |> Enum.with_index()
    |> Enum.map(fn {line, index} ->
      if (terminated? or index < length(pieces) - 1) and byte_size(line) > 0 and
           :binary.last(line) == ?\r do
        binary_part(line, 0, byte_size(line) - 1)
      else
        line
      end
    end)
  end

  defp process_line(line, number, acc) do
    case words(line) do
      [] ->
        {:ok, acc}

      [<<"#", _::binary>> | _] ->
        {:ok, acc}

      ["price" | rest] ->
        price_line(rest, number, acc)

      ["use" | rest] ->
        use_line(rest, number, acc)

      ["budget" | rest] ->
        budget_line(rest, number, acc)

      [kind | _] ->
        {:error, failure(number, "unknown line kind #{kind}")}
    end
  end

  defp words(line) do
    :binary.split(line, [" ", "\t"], [:global])
    |> Enum.reject(&(&1 == ""))
  end

  defp price_line([], number, _acc), do: {:error, failure(number, "price needs a model name")}

  defp price_line([model | fields], number, acc) do
    if not valid_model?(model) do
      {:error, failure(number, "bad model name #{model}")}
    else
      with {:ok, values} <- parse_fields(fields, [:in, :out, :cached], :price),
           :ok <- require_fields(values, [:in, :out], "price #{model} needs in= and out="),
           :ok <- unique_price(acc.prices, model) do
        price = %{in: values.in, out: values.out, cached: Map.get(values, :cached, values.in)}
        {:ok, %{acc | prices: Map.put(acc.prices, model, price)}}
      else
        {:error, message} -> {:error, failure(number, message)}
      end
    end
  end

  defp use_line([], number, _acc), do: {:error, failure(number, "use needs a model name")}

  defp use_line([model | fields], number, acc) do
    if not valid_model?(model) do
      {:error, failure(number, "bad model name #{model}")}
    else
      with {:ok, values} <- parse_fields(fields, [:in, :out, :cached, :tag, :day], :use),
           :ok <- require_fields(values, [:in, :out], "use #{model} needs in= and out="),
           :ok <- cached_within_input(values) do
        use = %{
          model: model,
          in: values.in,
          out: values.out,
          cached: Map.get(values, :cached, 0),
          tag: Map.get(values, :tag, "-"),
          day: Map.get(values, :day, "-"),
          line: number
        }

        {:ok, %{acc | uses: [use | acc.uses]}}
      else
        {:error, message} -> {:error, failure(number, message)}
      end
    end
  end

  defp budget_line(rest, number, acc) do
    case rest do
      [scope, limit] ->
        with :ok <- valid_scope(scope),
             {:ok, parsed_limit} <- money_value(Tokbill.Money.parse_limit(limit)),
             :ok <- unique_budget(acc.budgets, scope) do
          budget = %{scope: scope, limit: parsed_limit}
          {:ok, %{acc | budgets: [budget | acc.budgets]}}
        else
          {:error, message} -> {:error, failure(number, message)}
        end

      [_scope] ->
        {:error, failure(number, "budget needs SCOPE and LIMIT")}

      [] ->
        {:error, failure(number, "budget needs SCOPE and LIMIT")}

      [_scope, _limit, unexpected | _] ->
        {:error, failure(number, "unexpected #{unexpected}")}
    end
  end

  defp parse_fields(fields, allowed, kind) do
    Enum.reduce_while(fields, {:ok, %{}}, fn field, {:ok, values} ->
      case :binary.match(field, "=") do
        :nomatch ->
          {:halt, {:error, "bad field #{field}"}}

        {position, 1} ->
          key_text = binary_part(field, 0, position)
          value = binary_part(field, position + 1, byte_size(field) - position - 1)

          with {:ok, key} <- known_key(key_text, allowed),
               :ok <- not_repeated(values, key, key_text),
               {:ok, parsed} <- parse_field_value(kind, key, value) do
            {:cont, {:ok, Map.put(values, key, parsed)}}
          else
            {:error, message} -> {:halt, {:error, message}}
          end
      end
    end)
  end

  defp known_key(key_text, allowed) do
    key =
      case key_text do
        "in" -> :in
        "out" -> :out
        "cached" -> :cached
        "tag" -> :tag
        "day" -> :day
        _ -> nil
      end

    cond do
      key == nil or key not in allowed -> {:error, "unknown field #{key_text}"}
      true -> {:ok, key}
    end
  end

  defp not_repeated(values, key, key_text) do
    if Map.has_key?(values, key), do: {:error, "field #{key_text} given twice"}, else: :ok
  end

  defp parse_field_value(:price, key, value) when key in [:in, :out, :cached] do
    money_value(Tokbill.Money.parse_rate(value))
  end

  defp parse_field_value(:use, key, value) when key in [:in, :out, :cached] do
    case parse_count(value) do
      {:ok, count} -> {:ok, count}
      :error -> {:error, "bad count #{value}"}
    end
  end

  defp parse_field_value(:use, :tag, value) do
    if valid_tag?(value), do: {:ok, value}, else: {:error, "bad tag #{value}"}
  end

  defp parse_field_value(:use, :day, value) do
    if valid_day?(value), do: {:ok, value}, else: {:error, "bad day #{value}"}
  end

  defp money_value({:ok, value}), do: {:ok, value}
  defp money_value({:error, %Tokbill.Failure{message: message}}), do: {:error, message}

  defp parse_count(text) do
    if ascii_match?(text, ~r/\A[0-9]{1,10}\z/) do
      value = String.to_integer(text)
      if value <= 1_000_000_000, do: {:ok, value}, else: :error
    else
      :error
    end
  end

  defp require_fields(values, required, message) do
    if Enum.all?(required, &Map.has_key?(values, &1)), do: :ok, else: {:error, message}
  end

  defp cached_within_input(values) do
    if Map.get(values, :cached, 0) <= values.in,
      do: :ok,
      else: {:error, "cached tokens exceed input tokens"}
  end

  defp unique_price(prices, model) do
    if Map.has_key?(prices, model), do: {:error, "price for #{model} defined twice"}, else: :ok
  end

  defp unique_budget(budgets, scope) do
    if Enum.any?(budgets, &(&1.scope == scope)),
      do: {:error, "budget for #{scope} defined twice"},
      else: :ok
  end

  defp valid_scope("total"), do: :ok

  defp valid_scope(<<"model:", name::binary>>) do
    if valid_model?(name), do: :ok, else: {:error, "bad scope model:#{name}"}
  end

  defp valid_scope(<<"tag:", name::binary>>) do
    if valid_tag?(name), do: :ok, else: {:error, "bad scope tag:#{name}"}
  end

  defp valid_scope(<<"day:", date::binary>>) do
    if valid_day?(date), do: :ok, else: {:error, "bad scope day:#{date}"}
  end

  defp valid_scope(scope), do: {:error, "bad scope #{scope}"}

  defp valid_model?(text), do: ascii_match?(text, @model_pattern)
  defp valid_tag?(text), do: ascii_match?(text, @tag_pattern)

  defp valid_day?(text) do
    if ascii_match?(text, @date_pattern) do
      <<year::binary-size(4), "-", month::binary-size(2), "-", day::binary-size(2)>> = text
      year = String.to_integer(year)
      month = String.to_integer(month)
      day = String.to_integer(day)

      year in 1970..2999 and match?({:ok, _}, Date.new(year, month, day))
    else
      false
    end
  end

  defp ascii_match?(text, pattern) do
    String.valid?(text) and Regex.match?(pattern, text)
  end

  defp failure(number, message), do: Tokbill.Failure.new(1, "line #{number}: #{message}")
end
