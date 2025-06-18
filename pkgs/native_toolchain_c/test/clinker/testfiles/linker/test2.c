#include <stdio.h>

#if _WIN32
#define FFI_EXPORT __declspec(dllexport)
#else
#define FFI_EXPORT
#endif

FFI_EXPORT void my_other_func()
{
  printf("42+1");
}
