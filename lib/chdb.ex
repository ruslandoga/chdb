defmodule ChDB do
  @moduledoc "ChDB bindings for Elixir"

  @doc ~S"""
  Executes a query on a Dirty IO scheduler.

  Example:

      iex> ChDB.query_dirty_io(["--query", "select 1"])
      "1\n"

  """
  @spec query_dirty_io([arg :: binary]) :: binary | nil
  def query_dirty_io(args) do
    query_dirty_io_nif(build_args(args))
  end

  defp query_dirty_io_nif(_args), do: :erlang.nif_error(:undef)

  @doc ~S"""
  Executes a query on a Dirty CPU scheduler.

  Example:

      iex> ChDB.query_dirty_cpu(["--query", "select 1"])
      "1\n"

  """
  @spec query_dirty_cpu([arg :: binary]) :: binary | nil
  def query_dirty_cpu(args) do
    query_dirty_cpu_nif(build_args(args))
  end

  defp query_dirty_cpu_nif(_args), do: :erlang.nif_error(:undef)

  defp build_args(args) do
    ["clickhouse\0" | process_args(args)]
  end

  defp process_args([arg | args]) do
    [c_str(arg) | process_args(args)]
  end

  defp process_args([] = done), do: done

  @compile inline: [c_str: 1]
  defp c_str(b) when is_binary(b), do: [b, 0]

  defp c_str(v) do
    raise ArgumentError, "expected a binary, got: #{inspect(v)}"
  end

  @compile {:autoload, false}
  @on_load {:load_nif, 0}

  @doc false
  def load_nif do
    :code.priv_dir(:chdb)
    |> :filename.join(~c"chdb_nif")
    |> :erlang.load_nif(0)
  end
end
