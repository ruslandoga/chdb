defmodule ChDBTest do
  use ExUnit.Case

  doctest ChDB

  test "it works" do
    assert "1\n" = ChDB.query_dirty_cpu(["--query", "select 1"])
  end
end
