# ChDB

Elixir bindings for [ChDB.](https://github.com/chdb-io/libchdb)

### Trying it out

On Mac M1 you can try it out using Docker

```console
$ docker run --rm -ti hexpm/elixir:1.15.5-erlang-26.0.2-ubuntu-jammy-20230126 bash
```
```console
$ apt update
$ apt install git build-essential wget unzip
$ wget https://github.com/metrico/libchdb/releases/latest/download/libchdb_arm64.zip
$ unzip libchdb_arm64.zip
$ mv libchdb.so /usr/lib/libchdb.so
$ iex
```
```elixir
iex> Mix.install [{:chdb, github: "ruslandoga/chdb"}]
iex> ChDB.query(["--query", "select 42 format CSV"])
{:ok, "42\n"}
```
