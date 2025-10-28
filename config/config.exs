import Config

config :sales_tax, Config,
  tax_rules: %{
    basic_tax_rate: 0.10,
    import_duty_rate: 0.05,
    tax_exempt_categories: [:book, :food, :medical]
  }
