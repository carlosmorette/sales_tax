defmodule MyApp.Types do
  @moduledoc """
  Define os tipos usados no domínio de cálculo de impostos
  """

  @type money :: float() | integer()
  @type category :: :book | :food | :medical | :other
  @type tax_rate :: float()

  @type item :: %{
          required(:name) => String.t(),
          required(:quantity) => pos_integer(),
          required(:price) => money(),
          required(:is_imported) => boolean(),
          required(:category) => category()
        }

  @type tax_rates :: %{
          basic_tax_rate: tax_rate(),
          import_duty_rate: tax_rate(),
          tax_exempt_categories: [category()]
        }
end
