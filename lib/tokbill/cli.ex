defmodule Tokbill.CLI do
  @moduledoc false

  alias Tokbill.Failure

  def reads_stdin?([first | _args]) do
    Enum.any?(Tokbill.Registry.commands(), &(&1.name == first))
  end

  def reads_stdin?(_args), do: false

  def run([], _input), do: {2, "", Tokbill.Registry.usage()}
  def run([first | _args], _input) when first in ["help", "-h", "--help"], do: {0, Tokbill.Registry.usage(), ""}
  def run(["--version" | _args], _input), do: {0, "tokbill 0.1.0\n", ""}

  def run([name | words], input) do
    case Enum.find(Tokbill.Registry.commands(), &(&1.name == name)) do
      nil ->
        render_error(Failure.new(2, "unknown command #{name}"))

      command ->
        with {:ok, options, args} <- scan(words, command, %{}, []),
             :ok <- validate(command, options, args) do
          invocation = %{options: options, args: args, input: input}
          render_result(command.run.(invocation))
        else
          {:error, failure} -> render_error(failure)
        end
    end
  end

  defp scan([], _command, options, args), do: {:ok, options, Enum.reverse(args)}

  defp scan([word | rest], command, options, args) do
    if option?(word) do
      cond do
        word != command.option -> scan_error("unknown option #{word}")
        Map.has_key?(options, word) -> scan_error("#{word} given twice")
        rest == [] -> scan_error("#{word} needs a value")
        hd(rest) == "" -> scan_error("#{word} needs a value")
        true -> scan(tl(rest), command, Map.put(options, word, hd(rest)), args)
      end
    else
      if length(args) >= command.positional do
        scan_error("unexpected argument #{word}")
      else
        scan(rest, command, options, [word | args])
      end
    end
  end

  defp option?(word), do: String.starts_with?(word, "-") and byte_size(word) > 1

  defp scan_error(message), do: {:error, Failure.new(2, message)}

  defp validate(command, options, args) do
    cond do
      length(args) < command.positional ->
        {:error, Failure.new(2, "#{command.name} needs #{command.needs}")}

      not valid_options?(options) ->
        option = Enum.find(Map.keys(options), &(not valid_integer?(&1, Map.fetch!(options, &1))))
        {minimum, maximum} = Tokbill.Registry.bounds(option)
        {:error, Failure.new(2, "#{option} needs an integer from #{minimum} to #{maximum}")}

      command.name == "group" and hd(args) not in ["model", "tag", "day"] ->
        {:error, Failure.new(2, "bad group key #{hd(args)}")}

      command.name == "explain" and not valid_number?(hd(args), 1, 99_999) ->
        {:error, Failure.new(2, "bad use number #{hd(args)}")}

      true ->
        :ok
    end
  end

  defp valid_options?(options) do
    Enum.all?(options, fn {option, value} -> valid_integer?(option, value) end)
  end

  defp valid_integer?(option, value) do
    {minimum, maximum} = Tokbill.Registry.bounds(option)
    valid_number?(value, minimum, maximum)
  end

  defp valid_number?(value, minimum, maximum) do
    case Regex.match?(~r/\A[0-9]{1,5}\z/, value) do
      true ->
        {number, ""} = Integer.parse(value)
        number >= minimum and number <= maximum

      false ->
        false
    end
  end

  defp render_result({:ok, output}), do: {0, output, ""}
  defp render_result({:verdict, status, output}), do: {status, output, ""}
  defp render_result({:error, %Tokbill.Failure{code: code, message: message}}), do: render_error(Failure.new(code, message))

  defp render_error(%Tokbill.Failure{code: code, message: message}), do: {code, "", "tokbill: #{message}\n"}
end
