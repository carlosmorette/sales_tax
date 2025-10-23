defmodule SalesTax.Validator do
  @moduledoc false

  alias SalesTax.Types

  @valid_categories [:book, :food, :medical, :other]
  @required_fields [:name, :quantity, :price, :is_imported, :category]

  @spec validate_item(map()) :: {:ok, Types.item()} | {:error, String.t()}
  def validate_item(%{quantity: qty}) when qty <= 0 do
    {:error, "Quantity must be positive, got: #{qty}"}
  end

  def validate_item(%{price: price}) when price < 0 do
    {:error, "Price cannot be negative, got: #{price}"}
  end

  def validate_item(%{category: category} = item) do
    with {:ok, category_atom} <- normalize_category(category),
         true <- valid_category?(category_atom) do
      {:ok, ensure_original_price(%{item | category: category_atom})}
    else
      false -> category_error(category)
      error -> error
    end
  end

  def validate_item(item) do
    with nil <- find_missing_field(item, @required_fields),
         {:ok, category_atom} <- normalize_category(item.category),
         true <- valid_category?(category_atom) do
      {:ok,
       %{
         name: item.name,
         quantity: item.quantity,
         price: item.price,
         is_imported: item.is_imported,
         category: category_atom,
         original_price: item.price
       }}
    else
      {:error, reason} -> {:error, reason}
      field when not is_nil(field) -> {:error, "Missing required field: #{field}"}
      false -> category_error(item.category)
    end
  end

  @spec validate_items([map()]) :: {:ok, [Types.item()]} | {:error, String.t()}
  def validate_items(items) when is_list(items) do
    items
    |> Enum.with_index(1)
    |> Enum.reduce_while({:ok, []}, fn {item, idx}, {:ok, acc} ->
      case validate_item(item) do
        {:ok, valid_item} -> {:cont, {:ok, [valid_item | acc]}}
        {:error, reason} -> {:halt, {:error, "Error in item #{idx}: #{reason}"}}
      end
    end)
    |> case do
      {:ok, items} -> {:ok, Enum.reverse(items)}
      error -> error
    end
  end

  @spec validate_input(map()) :: {:ok, map()} | {:error, String.t()}
  def validate_input(%{items: []}), do: {:error, "Items list cannot be empty"}

  def validate_input(%{items: items} = input) when is_list(items) do
    with {:ok, items} <- validate_items(items) do
      {:ok, %{input | items: items}}
    end
  end

  def validate_input(_invalid) do
    {:error, "Input must be a map with an :items key containing a list of items"}
  end

  defp normalize_category(category) when is_binary(category) do
    try do
      {:ok, String.to_existing_atom(category)}
    rescue
      ArgumentError -> {:error, "Invalid category: #{category}"}
    end
  end

  defp normalize_category(category) when is_atom(category), do: {:ok, category}

  defp normalize_category(category),
    do: {:error, "Category must be a string or atom, got: #{inspect(category)}"}

  defp valid_category?(category), do: category in @valid_categories

  defp category_error(category) do
    categories = Enum.map_join(@valid_categories, ", ", &inspect/1)
    {:error, "Invalid category: #{inspect(category)}. Must be one of: #{categories}"}
  end

  defp find_missing_field(item, [field | rest]) do
    if Map.has_key?(item, field) do
      find_missing_field(item, rest)
    else
      field
    end
  end

  defp find_missing_field(_item, []), do: nil

  defp ensure_original_price(%{original_price: _} = item), do: item
  defp ensure_original_price(item), do: Map.put(item, :original_price, item.price)
end
