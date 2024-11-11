# ChDB

Elixir bindings for [chDB.](https://github.com/chdb-io/chdb)

### Trying it out

```sh
curl -LO https://github.com/chdb-io/chdb/releases/download/v2.1.1/macos-arm64-libchdb.tar.gz -o libchdb.tar.gz
tar -xvzf macos-arm64-libchdb.tar.gz
export CHDB_NIF_LDFLAGS="-L."
```

```elixir
iex> Mix.install [{:chdb, github: "ruslandoga/chdb"}]
iex> ChDB.query_dirty_cpu(["--query", "select 42 format CSV"])
"42\n"
```
