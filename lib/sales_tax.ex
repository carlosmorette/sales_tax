defmodule SalesTax do
  @moduledoc false

  alias SalesTax.{Calculator, Config, Validator}

  @spec process_file(String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def process_file(file_path) when is_binary(file_path) do
    with {:ok, content} <- File.read(file_path),
         {:ok, json} <- parse_json(content),
         {:ok, receipt} <- process_json(json) do
      {:ok, receipt}
    else
      {:error, %Jason.DecodeError{}} -> {:error, "Invalid JSON format in file: #{file_path}"}
      {:error, reason} when is_binary(reason) -> {:error, reason}
      _ -> {:error, "Failed to process file: #{file_path}"}
    end
  end

  @spec process_json(map()) :: {:ok, String.t()} | {:error, String.t()}
  def process_json(%{} = input) do
    with {:ok, %{items: items}} <- Validator.validate_input(input),
         {:ok, tax_rates} <- Config.get_tax_rates() do
      items_with_taxes = Calculator.calculate_taxes(items, tax_rates)
      totals = Calculator.calculate_totals(items_with_taxes)
      receipt = generate_receipt(items_with_taxes, totals)
      {:ok, receipt}
    end
  end

  defp parse_json(content) do
    Jason.decode(content, keys: :atoms)
  end

  defp generate_receipt(items, %{total: total, sales_tax: sales_tax}) do
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
