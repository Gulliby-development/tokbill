defmodule Tokbill.Totals do
  @moduledoc false

  def total(invocation) do
    with {:ok, ledger} <- Tokbill.Ledger.parse(invocation.input) do
      totals =
        Enum.reduce(ledger.uses, %{uses: 0, input: 0, cached: 0, output: 0, cost: 0}, fn use, acc ->
          price = Map.fetch!(ledger.prices, use.model)

          %{
            uses: acc.uses + 1,
            input: acc.input + use.in,
            cached: acc.cached + use.cached,
            output: acc.output + use.out,
            cost: acc.cost + Tokbill.Money.cost(use, price)
          }
        end)

      output =
        "uses #{totals.uses}\ninput #{totals.input}\ncached #{totals.cached}\n" <>
          "output #{totals.output}\ncost #{Tokbill.Money.usd(totals.cost)}\n"

      {:ok, output}
    end
  end

  def rates(invocation) do
    with {:ok, ledger} <- Tokbill.Ledger.parse(invocation.input) do
      output =
        ledger.prices
        |> Enum.sort_by(fn {model, _price} -> model end)
        |> Enum.map(fn {model, price} ->
          "#{model} in #{Tokbill.Money.rate(price.in)} out #{Tokbill.Money.rate(price.out)} " <>
            "cached #{Tokbill.Money.rate(price.cached)}\n"
        end)
        |> IO.iodata_to_binary()

      {:ok, output}
    end
  end
end
