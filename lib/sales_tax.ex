defmodule SalesTax do
  @moduledoc false

  alias SalesTax.FileProcessor

  defdelegate process_file(file_path), to: FileProcessor
  defdelegate process_json(input), to: FileProcessor
end
