defmodule MyApp.Validator do
  @moduledoc """
  Valida itens e dados de entrada para o cálculo de impostos.
  """

  alias MyApp.Types

  @valid_categories [:book, :food, :medical, :other]

  @doc """
  Valida um único item do carrinho de compras.
  """
  @spec validate_item(map()) :: {:ok, Types.item()} | {:error, String.t()}
  def validate_item(%{quantity: qty}) when qty <= 0 do
    {:error, "Quantity must be positive, got: #{qty}"}
  end

  def validate_item(%{price: price}) when price < 0 do
    {:error, "Price cannot be negative, got: #{price}"}
  end

  def validate_item(%{category: category} = item) do
    normalized_category =
      if is_binary(category) do
        String.to_existing_atom(category)
      else
        category
      end

    if normalized_category in @valid_categories do
      # Garante que original_price esteja definido
      item_with_price =
        if Map.has_key?(item, :original_price) do
          item
        else
          Map.put(item, :original_price, item.price)
        end

      {:ok, %{item_with_price | category: normalized_category}}
    else
      {:error,
       "Invalid category: #{category}. Must be one of #{inspect(Enum.map(@valid_categories, &to_string/1))}"}
    end
  rescue
    ArgumentError ->
      {:error,
       "Invalid category: #{category}. Must be one of #{inspect(Enum.map(@valid_categories, &to_string/1))}"}
  end

  def validate_item(item) do
    required = [:name, :quantity, :price, :is_imported, :category]

    case Enum.find(required, &(!Map.has_key?(item, &1))) do
      nil ->
        # Converte a categoria para átomo se for string
        category =
          if is_binary(item.category) do
            String.to_existing_atom(item.category)
          else
            item.category
          end

        if category in @valid_categories do
          {:ok,
           %{
             name: item.name,
             quantity: item.quantity,
             price: item.price,
             is_imported: item.is_imported,
             category: category,
             original_price: item.price
           }}

          raise "oioii"
        else
          {:error,
           "Invalid category: #{category}. Must be one of #{inspect(Enum.map(@valid_categories, &to_string/1))}"}
        end

      key ->
        {:error, "Missing required field: #{key}"}
    end
  end

  @doc """
  Valida uma lista de itens do carrinho de compras.
  """
  @spec validate_items([map()]) :: {:ok, [Types.item()]} | {:error, String.t()}
  def validate_items(items) when is_list(items) do
    items
    |> Enum.with_index(1)
    |> Enum.reduce_while({:ok, []}, fn {item, idx}, {:ok, acc} ->
      case validate_item(item) do
        {:ok, valid_item} ->
          # Se a validação for bem-sucedida, adiciona o item à lista
          {:cont, {:ok, [valid_item | acc]}}

        {:error, reason} ->
          # Se houver erro, interrompe a iteração e retorna o erro
          {:halt, {:error, "Error in item #{idx}: #{reason}"}}
      end
    end)
    |> case do
      {:ok, items} ->
        # Inverte a lista para manter a ordem original
        {:ok, Enum.reverse(items)}

      error ->
        # Se houver erro, retorna o erro
        error
    end
  end

  @doc """
  Valida o formato do JSON de entrada.
  """
  @spec validate_input(map()) :: {:ok, map()} | {:error, String.t()}
  def validate_input(%{items: []}) do
    {:error, "Items list cannot be empty"}
  end

  def validate_input(%{items: items} = input) when is_list(items) do
    case validate_items(items) do
      {:ok, items} -> {:ok, %{input | items: items}}
      error -> error
    end
  end

  def validate_input(_invalid) do
    {:error, "Input must be a map with an :items key containing a list of items"}
  end
end
