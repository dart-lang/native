#include <memory>
#include "cpp_filter_rename_test.h"

#if defined(_WIN32)
#define FFIGEN_EXPORT __declspec(dllexport)
#else
#define FFIGEN_EXPORT
#endif

extern "C" {

FFIGEN_EXPORT void MyClass_myMethod(MyClass* self) {
  self->myMethod();
}

FFIGEN_EXPORT void MyWidget_delete(MyClass* self) {
  delete self;
}

FFIGEN_EXPORT void OtherClass_method(OtherClass* self) {
  self->method();
}

FFIGEN_EXPORT void OtherClass_delete(OtherClass* self) {
  delete self;
}

}
