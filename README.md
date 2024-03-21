# ChDB

Elixir bindings for [ChDB.](https://github.com/chdb-io/chdb)

### Trying it out

```console
$ docker run --rm -ti hexpm/elixir:1.15.5-erlang-26.0.2-ubuntu-jammy-20230126 bash
$ apt update
$ apt install git curl build-essential
$ iex
```

```elixir
iex> Mix.install [{:chdb, github: "ruslandoga/chdb"}]
iex> ChDB.query(["--query", "select 42 format CSV"])
{:ok, "42\n"}
```
