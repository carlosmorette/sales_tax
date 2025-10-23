defmodule Mix.Tasks.ProcessReceipt do
  @moduledoc """
  Process a receipt JSON file and print the results.

  Usage:
    mix process_receipt path/to/input.json
  """

  use Mix.Task

  @shortdoc "Process a receipt JSON file and print the results"

  @impl Mix.Task
  def run(args) do
    with [file_path] <- args,
         {:ok, file_path} <- SalesTax.process_file(file_path) do
      IO.puts(file_path)
    else
      [] ->
        IO.puts("""
        Usage: mix process_receipt path/to/input.json

        Example:
          mix process_receipt priv/example_input.json
        """)

      error ->
        IO.inspect("Error: #{inspect(error)}")
    end
  end
end
