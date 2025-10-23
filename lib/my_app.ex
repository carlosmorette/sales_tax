defmodule MyApp do
  @moduledoc """
  Main module for processing sales tax calculations and generating receipts.
  """

  alias MyApp.{Calculator, Config, Validator}

  @doc """
  Process a JSON file and generate a receipt.

  ## Examples

      iex> MyApp.process_file("path/to/input.json")
      {:ok, "receipt content..."}
  """
  @spec process_file(String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def process_file(file_path) when is_binary(file_path) do
    with {:ok, content} <- File.read(file_path),
         {:ok, json} <- parse_json(content),
         {:ok, receipt} <- process_json(json) do
      {:ok, receipt}
    else
      {:error, %Jason.DecodeError{}} ->
        {:error, "Invalid JSON format in file: #{file_path}"}

      {:error, reason} when is_binary(reason) ->
        {:error, reason}

      _ ->
        {:error, "Failed to process file: #{file_path}"}
    end
  end

  @doc """
  Process a JSON map and generate a receipt.

  ## Examples

      iex> MyApp.process_json(%{items: [...]})
      {:ok, "receipt content..."}
  """
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

  # Private functions

  defp parse_json(content) when is_binary(content) do
    case Jason.decode(content, keys: :atoms) do
      {:ok, json} -> {:ok, json}
      {:error, error} -> {:error, "Invalid JSON: #{inspect(error)}"}
    end
  end

  defp generate_receipt(items, %{tax_total: tax_total, price_total: price_total}) do
    item_lines =
      items
      |> Enum.map(fn %{quantity: qty, name: name, price: price} ->
        total_price = price * qty
        "#{qty} #{name}: #{format_price(total_price)}"
      end)
      |> Enum.join("\n")

    """
    #{item_lines}
    Impostos sobre vendas: #{format_price(tax_total)}
    Total: #{format_price(price_total)}
    """
    |> String.trim_trailing()
  end

  defp format_price(price) when is_float(price) do
    :io_lib.format("~.2f", [price]) |> to_string()
  end

  defp format_price(price) when is_integer(price) do
    "#{price}.00"
  end
end
