defmodule SalesTax.Calculator do
  @moduledoc false

  alias SalesTax.Types

  @spec calculate_taxes([Types.item()], Types.tax_rates()) :: [Types.item()]
  def calculate_taxes(items, tax_rates) do
    Enum.map(items, &calculate_item_taxes(&1, tax_rates))
  end

  @spec calculate_item_taxes(Types.item(), Types.tax_rates()) :: Types.item()
  def calculate_item_taxes(item, %{
        basic_tax_rate: basic_tax_rate,
        import_duty_rate: import_duty_rate,
        tax_exempt_categories: tax_exempt_categories
      }) do
    original_price = item.price

    basic_tax =
      calculate_basic_tax(%{item | price: original_price}, basic_tax_rate, tax_exempt_categories)

    import_duty = calculate_import_duty(%{item | price: original_price}, import_duty_rate)
    total_tax = round_to_nearest_005(basic_tax + import_duty)

    %{
      item
      | price: Float.round(original_price + total_tax, 2),
        original_price: original_price
    }
  end

  @spec calculate_totals([Types.item()]) :: %{total: float(), sales_tax: float()}
  def calculate_totals(items) do
    {tax_total, price_total} =
      Enum.reduce(items, {0.0, 0.0}, fn item, {tax_acc, price_acc} ->
        item_tax = item.price - item.original_price
        {tax_acc + item_tax * item.quantity, price_acc + item.price * item.quantity}
      end)

    %{
      total: Float.round(price_total, 2),
      sales_tax: Float.round(tax_total, 2)
    }
  end

  defp calculate_basic_tax(%{category: category} = item, rate, exempt_categories) do
    if category in exempt_categories do
      0.0
    else
      item.price * rate
    end
  end

  defp calculate_import_duty(%{is_imported: true, price: price}, rate) do
    price * rate
  end

  defp calculate_import_duty(%{is_imported: false}, _rate) do
    0.0
  end

  defp round_to_nearest_005(amount) when is_float(amount) do
    cents = trunc(amount * 100)
    remainder = rem(cents, 5)
    rounded_cents = if remainder > 0, do: cents + (5 - remainder), else: cents
    Float.round(rounded_cents / 100, 2)
  end

  defp round_to_nearest_005(amount) when is_integer(amount) do
    round_to_nearest_005(amount / 1.0)
  end
end
