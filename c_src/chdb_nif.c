#include <erl_nif.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "chdb.h"

static ERL_NIF_TERM make_atom(ErlNifEnv* env, const char* atom_name) {
  ERL_NIF_TERM atom;

  if (enif_make_existing_atom(env, atom_name, &atom, ERL_NIF_LATIN1)) {
    return atom;
  }

  return enif_make_atom(env, atom_name);
}
static ERL_NIF_TERM make_binary(ErlNifEnv* env, const void* bytes,
                                unsigned int size) {
  ErlNifBinary blob;
  ERL_NIF_TERM term;

  if (!enif_alloc_binary(size, &blob)) {
    return make_atom(env, "out_of_memory");
  }

  memcpy(blob.data, bytes, size);
  term = enif_make_binary(env, &blob);
  enif_release_binary(&blob);

  return term;
}

ERL_NIF_TERM query_nif(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
  unsigned int argument_list_length = 0;
  ERL_NIF_TERM eos = enif_make_int(env, 0);

  ERL_NIF_TERM list;
  ERL_NIF_TERM head;
  ERL_NIF_TERM tail;

  if (!enif_get_list_length(env, argv[0], &argument_list_length)) {
    return enif_make_badarg(env);
  }

  list = argv[0];
  char* argument_list[argument_list_length + 1];

  for (unsigned int i = 0; i < argument_list_length; i++) {
    enif_get_list_cell(env, list, &head, &tail);
    ErlNifBinary bin;

    if (!enif_inspect_iolist_as_binary(env, enif_make_list2(env, head, eos),
                                       &bin)) {
      return enif_make_badarg(env);
    }

    argument_list[i] = enif_alloc(bin.size + 1);
    memcpy(argument_list[i], bin.data, bin.size);
    argument_list[i][bin.size] = '\0';
    list = tail;
  }

  argument_list[argument_list_length] = NULL;

  struct local_result* result =
      query_stable(argument_list_length, argument_list);

  for (unsigned int i = 0; i < argument_list_length; i++) {
    enif_free(argument_list[i]);
  }

  if (result == NULL) {
    return enif_make_tuple2(env, make_atom(env, "error"),
                            make_atom(env, "query_failed"));
  }

  ERL_NIF_TERM output = make_binary(env, result->buf, result->len);
  return enif_make_tuple2(env, make_atom(env, "ok"), output);
}

static ErlNifFunc nif_funcs[] = {
    {"query_nif", 1, query_nif, ERL_NIF_DIRTY_JOB_IO_BOUND},
};

ERL_NIF_INIT(Elixir.ChDB.Nif, nif_funcs, NULL, NULL, NULL, NULL);
