#pragma once
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

struct local_result {
  char* buf;
  size_t len;
  void* _vec;  // std::vector<char> *, for freeing
};

struct local_result* query_stable(int argc, char** argv);
void free_result(struct local_result* result);

#ifdef __cplusplus
}
#endif
