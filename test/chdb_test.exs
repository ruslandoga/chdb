defmodule ChDBTest do
  use ExUnit.Case
  doctest ChDB

  test "RowBinary works" do
    assert rowbinary =
             ChDB.query_dirty_io(
               _args = [
                 "--format",
                 "RowBinary",
                 "--query",
                 "select * from system.numbers limit 10000"
               ]
             )

    numbers = decode_rowbinary(rowbinary)

    assert length(numbers) == 10000
    assert Enum.sum(numbers) == 49_995_000
  end

  defp decode_rowbinary(<<i::64-little-signed, rest::bytes>>) do
    [i | decode_rowbinary(rest)]
  end

  defp decode_rowbinary(<<>>) do
    []
  end
end
