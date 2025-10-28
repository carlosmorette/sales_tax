defmodule SalesTax.Receipt do
  def generate_receipt(items, %{total: total, sales_tax: sales_tax}) do
    items_str = Enum.map_join(items, "\n", &format_item/1)
    tax_str = "Impostos sobre vendas: #{format_price(sales_tax)}"
    total_str = "Total: #{format_price(total)}"

    [items_str, tax_str, total_str]
    |> Enum.reject(&(&1 == ""))
    |> Enum.join("\n")
  end

  defp format_item(%{quantity: qty, name: name, price: price}) do
    "#{qty} #{name}: #{format_price(price)}"
  end

  defp format_price(price) when is_float(price) do
    :io_lib.format("~.2f", [price]) |> to_string()
  end

  defp format_price(price) when is_integer(price) do
    "#{price}.00"
  end
end
