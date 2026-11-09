defmodule Tokbill.Groups do
  @moduledoc false

  def run(invocation) do
    with {:ok, ledger} <- Tokbill.Ledger.parse(invocation.input) do
      key = group_key(hd(invocation.args))

      groups =
        Enum.reduce(ledger.uses, %{}, fn use, acc ->
          name = Map.fetch!(use, key)
          price = Map.fetch!(ledger.prices, use.model)
          cost = Tokbill.Money.cost(use, price)
          current = Map.get(acc, name, %{uses: 0, tokens: 0, cost: 0})

          Map.put(acc, name, %{
            uses: current.uses + 1,
            tokens: current.tokens + use.in + use.out,
            cost: current.cost + cost
          })
        end)

      ranked =
        groups
        |> Enum.sort_by(fn {name, group} -> {-group.cost, name} end)

      {:ok, render(ranked, Map.get(invocation.options, "--top"))}
    end
  end

  defp group_key("model"), do: :model
  defp group_key("tag"), do: :tag
  defp group_key("day"), do: :day

  defp render(groups, nil), do: render_groups(groups)

  defp render(groups, top) do
    {included, omitted} = Enum.split(groups, String.to_integer(top))
    output = render_groups(included)

    case omitted do
      [] -> output
      _ -> output <> render_others(omitted)
    end
  end

  defp render_groups(groups) do
    Enum.map_join(groups, fn {name, group} ->
      "#{name} uses #{group.uses} tokens #{group.tokens} cost #{Tokbill.Money.usd(group.cost)}\n"
    end)
  end

  defp render_others(groups) do
    count = length(groups)
    cost = Enum.reduce(groups, 0, fn {_name, group}, total -> total + group.cost end)
    "others #{count} cost #{Tokbill.Money.usd(cost)}\n"
  end
end
