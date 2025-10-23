defmodule MyAppTest do
  use ExUnit.Case, async: true

  describe "tax calculation scenarios" do
    test "input 1: 2 books, 1 music CD, 1 chocolate bar" do
      input = %{
        items: [
          %{quantity: 2, name: "livro", price: 12.49, is_imported: false, category: "book"},
          %{
            quantity: 1,
            name: "CD de música",
            price: 14.99,
            is_imported: false,
            category: "other"
          },
          %{
            quantity: 1,
            name: "barra de chocolate",
            price: 0.85,
            is_imported: false,
            category: "food"
          }
        ]
      }

      expected =
        """
        2 livro: 24.98
        1 CD de música: 16.49
        1 barra de chocolate: 0.85
        Impostos sobre vendas: 1.50
        Total: 42.32
        """
        |> String.trim_trailing()

      assert {:ok, ^expected} = MyApp.process_json(input)
    end

    test "input 2: 1 imported chocolate box, 1 imported perfume" do
      input = %{
        items: [
          %{
            quantity: 1,
            name: "caixa importada de chocolates",
            price: 10.00,
            is_imported: true,
            category: "food"
          },
          %{
            quantity: 1,
            name: "frasco importado de perfume",
            price: 47.50,
            is_imported: true,
            category: "other"
          }
        ]
      }

      expected =
        """
        1 caixa importada de chocolates: 10.50
        1 frasco importado de perfume: 54.65
        Impostos sobre vendas: 7.65
        Total: 65.15
        """
        |> String.trim_trailing()

      assert {:ok, ^expected} = MyApp.process_json(input)
    end

    test "input 3: imported perfume, local perfume, headache pills, imported chocolates" do
      input = %{
        items: [
          %{
            quantity: 1,
            name: "frasco importado de perfume",
            price: 27.99,
            is_imported: true,
            category: "other"
          },
          %{
            quantity: 1,
            name: "frasco de perfume",
            price: 18.99,
            is_imported: false,
            category: "other"
          },
          %{
            quantity: 1,
            name: "pacote de comprimidos para dor de cabeça",
            price: 9.75,
            is_imported: false,
            category: "medical"
          },
          %{
            quantity: 3,
            name: "caixas importadas de chocolates",
            price: 11.25,
            is_imported: true,
            category: "food"
          }
        ]
      }

      expected =
        """
        1 frasco importado de perfume: 32.19
        1 frasco de perfume: 20.89
        1 pacote de comprimidos para dor de cabeça: 9.75
        3 caixas importadas de chocolates: 35.55
        Impostos sobre vendas: 7.90
        Total: 98.38
        """
        |> String.trim_trailing()

      assert {:ok, ^expected} = MyApp.process_json(input)
    end
  end

  describe "edge cases" do
    test "empty items list returns error" do
      assert {:error, _reason} = MyApp.process_json(%{items: []})
    end

    test "invalid item returns error" do
      input = %{
        items: [
          # missing required fields
          %{quantity: 1, name: "item inválido", price: 10.0}
        ]
      }

      assert {:error, _reason} = MyApp.process_json(input)
    end
  end

  describe "process_file/1" do
    test "with valid file returns receipt" do
      input = %{
        items: [
          %{quantity: 1, name: "livro", price: 12.49, is_imported: false, category: "book"},
          %{
            quantity: 1,
            name: "CD de música",
            price: 14.99,
            is_imported: false,
            category: "other"
          }
        ]
      }

      expected =
        """
        1 livro: 12.49
        1 CD de música: 16.49
        Impostos sobre vendas: 1.50
        Total: 28.98
        """
        |> String.trim_trailing()

      # Create a temporary file
      file_path = "test_fixture_#{System.unique_integer([:positive])}.json"
      File.write!(file_path, Jason.encode!(input))

      try do
        assert {:ok, ^expected} = MyApp.process_file(file_path)
      after
        # Clean up the temporary file
        File.rm!(file_path)
      end
    end

    test "with non-existent file returns error" do
      assert {:error, _reason} = MyApp.process_file("non_existent_file.json")
    end
  end
end
