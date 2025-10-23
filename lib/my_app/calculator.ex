defmodule MyApp.Calculator do
  @moduledoc """
  Handles all tax-related calculations for shopping items.
  """

  alias MyApp.Types

  @doc """
  Calculates taxes for a list of items using the provided tax rates.
  """
  @spec calculate_taxes([Types.item()], Types.tax_rates()) :: [Types.item()]
  def calculate_taxes(items, tax_rates) do
    Enum.map(items, &calculate_item_taxes(&1, tax_rates))
  end

  @doc """
  Calculates taxes for a single item.
  """
  @spec calculate_item_taxes(Types.item(), Types.tax_rates()) :: Types.item()
  def calculate_item_taxes(item, %{
        basic_tax_rate: basic_tax_rate,
        import_duty_rate: import_duty_rate,
        tax_exempt_categories: tax_exempt_categories
      }) do
    original_price = item.price
    # Calcula os impostos sobre o preço original
    basic_tax =
      calculate_basic_tax(%{item | price: original_price}, basic_tax_rate, tax_exempt_categories)

    import_duty = calculate_import_duty(%{item | price: original_price}, import_duty_rate)
    total_tax = round_to_nearest_005(basic_tax + import_duty)

    # Atualiza o preço com os impostos arredondados
    updated_item = %{
      item
      | price: Float.round(original_price + total_tax, 2),
        original_price: original_price
    }

    updated_item
  end

  @spec calculate_basic_tax(Types.item(), float(), [Types.category()]) :: float()
  defp calculate_basic_tax(%{category: category, price: price}, rate, exempt_categories) do
    if category in exempt_categories do
      0.0
    else
      price * rate
    end
  end

  @spec calculate_import_duty(Types.item(), float()) :: float()
  defp calculate_import_duty(%{is_imported: true, price: price}, rate) do
    price * rate
  end

  defp calculate_import_duty(%{is_imported: false}, _rate), do: 0.0

  @spec round_to_nearest_005(float()) :: float()
  defp round_to_nearest_005(amount) when is_float(amount) do
    # Multiplica por 100 para trabalhar com centavos inteiros
    cents = trunc(amount * 100)
    remainder = rem(cents, 5)

    if remainder > 0 do
      # Arredonda para cima para o próximo múltiplo de 5
      (cents + (5 - remainder)) / 100
    else
      amount
    end
    |> Float.round(2)
  end

  @doc """
  Calculates the total tax and price for a list of items.
  Returns a map with the total tax and total price.
  """
  @spec calculate_totals([Types.item()]) :: %{tax_total: float(), price_total: float()}
  def calculate_totals(items) do
    Enum.reduce(items, %{tax_total: 0.0, price_total: 0.0}, fn item, acc ->
      tax_amount = item.price - (item.original_price || item.price)

      %{
        tax_total: acc.tax_total + tax_amount * item.quantity,
        price_total: acc.price_total + item.price * item.quantity
      }
    end)
  end
end
