defmodule ChDB.Nif do
  @moduledoc false
  @on_load :load_nif
  @compile {:autoload, false}

  def load_nif do
    path = :filename.join(:code.priv_dir(:chdb), ~c"chdb_nif")
    :erlang.load_nif(path, 0)
  end

  def query_nif(_argv), do: :erlang.nif_error(:not_loaded)
end
