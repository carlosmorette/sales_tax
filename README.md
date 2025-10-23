# Sales Tax Calculator

Uma aplicação em Elixir para cálculo de impostos sobre vendas, seguindo as regras específicas de taxação de produtos importados e domésticos.

## Funcionalidades

- Cálculo automático de impostos básicos e de importação
- Suporte a diferentes categorias de produtos (livros, alimentos, medicamentos, outros)
- Geração de recibos detalhados
- Interface de linha de comando via Mix task
- Testes automatizados abrangentes

## Requisitos

- Elixir 1.18 ou superior
- Erlang/OTP 25 ou superior

## Instalação

1. Clone o repositório:
   ```bash
   git clone git@github.com:carlosmorette/sales_tax.git
   cd sales_tax
   ```

2. Instale as dependências:
   ```bash
   mix deps.get
   ```

## Como Usar

### Via Mix Task

A forma mais simples de usar a aplicação é através da task `process_receipt`:

```bash
# Processar um arquivo JSON com os itens
mix process_receipt caminho/para/seu/arquivo.json

# Exemplo com o arquivo de teste:
mix process_receipt priv/inputs/input1.json
```

### Como uma Biblioteca

Você também pode usar a aplicação como uma biblioteca em seu projeto:

```elixir
# Em seu código Elixir:
items = [
  %{quantity: 2, name: "livro", price: 12.49, is_imported: false, category: "book"},
  %{quantity: 1, name: "CD de música", price: 14.99, is_imported: false, category: "other"}
]

{:ok, receipt} = SalesTax.process_json(%{items: items})
IO.puts(receipt)
```

## Executando os Testes

```bash
mix test
```
