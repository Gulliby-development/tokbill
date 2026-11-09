defmodule Tokbill.Money do
  @moduledoc false

  @rate_pattern ~r/\A[0-9]{1,6}(?:\.[0-9]{1,4})?\z/
  @limit_pattern ~r/\A[0-9]{1,9}(?:\.[0-9]{1,6})?\z/

  def parse_rate(text) when is_binary(text) do
    if Regex.match?(@rate_pattern, text) do
      {:ok, decimal_units(text, 4)}
    else
      {:error, Tokbill.Failure.new(1, "bad rate #{text}")}
    end
  end

  def parse_limit(text) when is_binary(text) do
    if Regex.match?(@limit_pattern, text) do
      {:ok, decimal_units(text, 6)}
    else
      {:error, Tokbill.Failure.new(1, "bad limit #{text}")}
    end
  end

  def usd(micro) when is_integer(micro) do
    dollars = div(micro, 1_000_000)
    fraction = rem(micro, 1_000_000) |> Integer.to_string() |> String.pad_leading(6, "0")
    Integer.to_string(dollars) <> "." <> fraction
  end

  def rate(units) when is_integer(units) do
    whole = div(units, 10_000)
    fraction = rem(units, 10_000) |> Integer.to_string() |> String.pad_leading(4, "0")
    normalized = String.trim_trailing(fraction, "0")

    if normalized == "" do
      Integer.to_string(whole)
    else
      Integer.to_string(whole) <> "." <> normalized
    end
  end

  def parts(use, price) do
    cached = use.cached

    [
      {use.in - cached, price.in, (use.in - cached) * price.in},
      {cached, price.cached, cached * price.cached},
      {use.out, price.out, use.out * price.out}
    ]
  end

  def raw(use, price) do
    use
    |> parts(price)
    |> Enum.reduce(0, fn {_count, _rate, product}, total -> total + product end)
  end

  def cost(use, price), do: div(raw(use, price) + 5000, 10_000)

  defp decimal_units(text, scale) do
    case String.split(text, ".") do
      [whole] ->
        String.to_integer(whole) * power_of_ten(scale)

      [whole, fractional] ->
        String.to_integer(whole) * power_of_ten(scale) +
          String.to_integer(String.pad_trailing(fractional, scale, "0"))
    end
  end

  defp power_of_ten(4), do: 10_000
  defp power_of_ten(6), do: 1_000_000
end
