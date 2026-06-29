#include "cpp_class_test.h"
#include "finalizer_test_subject.h"

#if defined(_WIN32)
#define FFIGEN_EXPORT __declspec(dllexport)
#else
#define FFIGEN_EXPORT
#endif

extern "C" {

FFIGEN_EXPORT Animal* Animal_new(int age) {
  return new Animal(age);
}

FFIGEN_EXPORT void Animal_delete(Animal* self) {
  delete self;
}

FFIGEN_EXPORT void Animal_speak(Animal* self) {
  self->speak();
}

FFIGEN_EXPORT int Animal_getAge(const Animal* self) {
  return self->getAge();
}

FFIGEN_EXPORT int Animal_getCount() {
  return Animal::getCount();
}

FFIGEN_EXPORT void Animal_Animal_new() {
  Animal::Animal_new();
}

FFIGEN_EXPORT void Animal_Animal_delete() {
  Animal::Animal_delete();
}

FFIGEN_EXPORT bool Animal_isMammalClass(const Animal* self) {
  return self->isMammalClass();
}

FFIGEN_EXPORT double Animal_getWeight(const Animal* self, double multiplier) {
  return self->getWeight(multiplier);
}

FFIGEN_EXPORT int Animal_addAges(Animal* self, int otherAge, float scale) {
  return self->addAges(otherAge, scale);
}

FFIGEN_EXPORT int Animal_sum(int a, int b) {
  return Animal::sum(a, b);
}

FFIGEN_EXPORT FinalizerTestSubject* FinalizerTestSubject_new(int * counter) {
  return new FinalizerTestSubject(counter);
}

FFIGEN_EXPORT void FinalizerTestSubject_delete(FinalizerTestSubject* self) {
  delete self;
}

}
