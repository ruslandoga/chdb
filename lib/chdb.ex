defmodule ChDB do
  @moduledoc """
  Documentation for `ChDB`.
  """

  @doc """
  Issues a query to ChDB.

  Example:

      iex> {:ok, <<_::size(10000*64)>>} = query(_args = ["--format", "RowBinary", "--query", "select * from system.numbers limit 10000"])

  """
  def query([_ | _] = args) do
    ChDB.Nif.query_nif(["clickhouse" | args])
  end
end
