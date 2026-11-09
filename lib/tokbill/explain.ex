defmodule Tokbill.Explain do
  @moduledoc false

  def run(%{args: [text], input: input}) do
    number = String.to_integer(text)

    with {:ok, ledger} <- Tokbill.Ledger.parse(input) do
      case Enum.fetch(ledger.uses, number - 1) do
        {:ok, use} ->
          price = Map.fetch!(ledger.prices, use.model)
          [uncached, cached, output] = Tokbill.Money.parts(use, price)
          raw = Tokbill.Money.raw(use, price)
          cost = Tokbill.Money.cost(use, price)

          {:ok,
           [
             "use #{number} on line #{use.line}: #{use.model}\n",
             render_part("uncached", uncached),
             render_part("cached", cached),
             render_part("output", output),
             "sum #{raw} -> #{Tokbill.Money.usd(cost)}\n"
           ]
           |> IO.iodata_to_binary()}

        :error ->
          {:error, Tokbill.Failure.new(1, "no use #{number}")}
      end
    end
  end

  defp render_part(label, {count, rate, product}) do
    "#{label} #{count} x #{rate} = #{product}\n"
  end
end
