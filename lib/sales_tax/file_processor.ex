defmodule SalesTax.FileProcessor do
  alias SalesTax.{Calculator, Config, Validator, Receipt}

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
         tax_rates <- Config.get_tax_rates() do
      items_with_taxes = Calculator.calculate_taxes(items, tax_rates)
      totals = Calculator.calculate_totals(items_with_taxes)
      receipt = Receipt.generate_receipt(items_with_taxes, totals)
      {:ok, receipt}
    end
  end

  defp parse_json(content) do
    Jason.decode(content, keys: :atoms)
  end
end
