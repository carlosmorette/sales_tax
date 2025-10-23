defmodule SalesTax.MixProject do
  use Mix.Project

  def project do
    [
      app: :sales_tax,
      name: "Sales Tax Calculator",
      version: "1.0.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "A sales tax calculator for imported and domestic products",
      package: [
        maintainers: ["Morette"],
        licenses: ["MIT"],
        links: %{"GitHub" => "https://github.com/morette/sales_tax"}
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {SalesTax.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.4"}
    ]
  end
end
