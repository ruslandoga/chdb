#include <assert.h>
#include <stdint.h>
#include <string.h>
#include <erl_nif.h>
#include <chdb.h>

static ERL_NIF_TERM am_nil;

static int
on_load(ErlNifEnv *env, void **priv, ERL_NIF_TERM info)
{
  am_nil = enif_make_atom(env, "nil");
  return 0;
}

static ERL_NIF_TERM
make_binary(ErlNifEnv *env, const char *bytes, size_t size)
{
  ERL_NIF_TERM bin;
  uint8_t *data = enif_make_new_binary(env, size, &bin);
  memcpy(data, bytes, size);
  return bin;
}

static ERL_NIF_TERM
query_nif(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
  unsigned int chdb_argc;
  if (!enif_get_list_length(env, argv[0], &chdb_argc))
    return enif_make_badarg(env);

  char *chdb_argv[chdb_argc];

  ERL_NIF_TERM head, tail;
  ERL_NIF_TERM list = argv[0];

  for (unsigned int i = 0; i < chdb_argc; i++)
  {
    if (!enif_get_list_cell(env, list, &head, &tail))
      return enif_make_badarg(env);

    ErlNifBinary arg;
    if (!enif_inspect_iolist_as_binary(env, head, &arg))
      return enif_make_badarg(env);

    chdb_argv[i] = (char *)arg.data;
    list = tail;
  }

  struct local_result_v2 *chdb_result = query_stable_v2(chdb_argc, chdb_argv);

  // TODO when does this happen?
  if (chdb_result == NULL)
    return am_nil;

  // TODO find out when it's set
  assert(chdb_result->error_message == NULL);

  ERL_NIF_TERM result = make_binary(env, chdb_result->buf, chdb_result->len);
  free_result_v2(chdb_result);
  return result;
}

static ErlNifFunc nif_funcs[] = {
    {"query_dirty_io_nif", 1, query_nif, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"query_dirty_cpu_nif", 1, query_nif, ERL_NIF_DIRTY_JOB_CPU_BOUND},
};

ERL_NIF_INIT(Elixir.ChDB, nif_funcs, on_load, NULL, NULL, NULL)
