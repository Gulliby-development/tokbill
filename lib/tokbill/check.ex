defmodule Tokbill.Check do
  @moduledoc false

  def run(invocation) do
    with {:ok, ledger} <- Tokbill.Ledger.parse(invocation.input) do
      if ledger.budgets == [] do
        {:ok, "no budgets\n"}
      else
        warn = Map.get(invocation.options, "--warn", "80") |> String.to_integer()

        {lines, over?} =
          Enum.map_reduce(ledger.budgets, false, fn budget, any_over? ->
            spent = spent_for(budget.scope, ledger.uses, ledger.prices)
            status = classify(spent, budget.limit, warn)

            line =
              "#{budget.scope} spent #{Tokbill.Money.usd(spent)} limit #{Tokbill.Money.usd(budget.limit)} #{status}\n"

            {line, any_over? or status == "over"}
          end)

        report = IO.iodata_to_binary(lines)
        if over?, do: {:verdict, 3, report}, else: {:ok, report}
      end
    end
  end

  defp spent_for("total", uses, prices), do: sum_costs(uses, prices)

  defp spent_for(<<"model:", name::binary>>, uses, prices) do
    uses |> Enum.filter(&(&1.model == name)) |> sum_costs(prices)
  end

  defp spent_for(<<"tag:", name::binary>>, uses, prices) do
    uses |> Enum.filter(&(&1.tag == name)) |> sum_costs(prices)
  end

  defp spent_for(<<"day:", date::binary>>, uses, prices) do
    uses |> Enum.filter(&(&1.day == date)) |> sum_costs(prices)
  end

  defp sum_costs(uses, prices) do
    Enum.reduce(uses, 0, fn use, total ->
      total + Tokbill.Money.cost(use, Map.fetch!(prices, use.model))
    end)
  end

  defp classify(spent, limit, _warn) when spent > limit, do: "over"

  defp classify(spent, limit, warn) do
    if spent * 100 >= warn * limit, do: "warn", else: "ok"
  end
end
