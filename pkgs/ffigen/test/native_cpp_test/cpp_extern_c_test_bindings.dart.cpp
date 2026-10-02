#include <memory>
#include "cpp_extern_c_test.h"

#if defined(_WIN32)
#define FFIGEN_EXPORT __declspec(dllexport)
#else
#define FFIGEN_EXPORT
#endif

extern "C" {

FFIGEN_EXPORT int ffigen_applyTwice(int (*fn)(int), int x) {
  return applyTwice(fn, x);
}

FFIGEN_EXPORT int ffigen_nestedCpp(int x) {
  return nestedCpp(x);
}

FFIGEN_EXPORT int ffigen_outside(double d) {
  return outside(d);
}

FFIGEN_EXPORT decltype(&outsideCounter) ffigen_outsideCounter() {
  return &outsideCounter;
}

}
