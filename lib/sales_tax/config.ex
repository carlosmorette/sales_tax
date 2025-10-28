defmodule SalesTax.Config do
  @moduledoc false
  @config Application.compile_env(:sales_tax, [Config, :tax_rules])

  def get_tax_rates do
    @config
  end
end
