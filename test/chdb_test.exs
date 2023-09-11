defmodule ChDBTest do
  use ExUnit.Case
  doctest ChDB, import: true

  test "it works" do
    assert {:ok, "1\n"} = ChDB.query(["--query", "select 1"])
  end
end
