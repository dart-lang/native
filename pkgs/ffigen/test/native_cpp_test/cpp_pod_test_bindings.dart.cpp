#include <memory>
#include "cpp_pod_test.h"

#if defined(_WIN32)
#define FFIGEN_EXPORT __declspec(dllexport)
#else
#define FFIGEN_EXPORT
#endif

extern "C" {

FFIGEN_EXPORT NonPodCounter* NonPodCounter_new(int start) {
  return new NonPodCounter(start);
}

FFIGEN_EXPORT int NonPodCounter_next(NonPodCounter* self) {
  return self->next();
}

FFIGEN_EXPORT void NonPodCounter_delete(NonPodCounter* self) {
  delete self;
}

}
