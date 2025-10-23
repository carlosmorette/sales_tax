defmodule SalesTax.Config do
  @moduledoc false
  require Logger
  alias SalesTax.Types

  @config_file Application.compile_env(:sales_tax, [Config, :tax_rules_path])

  @spec get_tax_rates() :: {:ok, Types.tax_rates()} | {:error, String.t()}
  def get_tax_rates do
    with {:ok, config} <- load_config(),
         {:ok, parsed} <- parse_config(config) do
      {:ok, parsed}
    else
      error -> error
    end
  end

  defp load_config do
    case File.read(@config_file) do
      {:ok, content} ->
        case Jason.decode(content, keys: :atoms) do
          {:ok, config} -> {:ok, config}
          {:error, error} -> {:error, "Invalid JSON: #{inspect(error)}"}
        end

      {:error, reason} ->
        Logger.error("Failed to load tax config: #{inspect(reason)}")
        {:error, "Failed to load tax configuration"}
    end
  end

  defp parse_config(%{
         basic_tax_rate: basic_rate,
         import_duty_rate: import_rate,
         tax_exempt_categories: categories
       })
       when is_number(basic_rate) and is_number(import_rate) and is_list(categories) do
    {:ok,
     %{
       basic_tax_rate: basic_rate,
       import_duty_rate: import_rate,
       tax_exempt_categories: Enum.map(categories, &String.to_atom/1)
     }}
  end

  defp parse_config(_invalid) do
    {:error, "Invalid tax configuration format"}
  end
end
