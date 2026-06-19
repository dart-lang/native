#include "cpp_class_test.h"

#if !defined(__OBJC__) && !defined(__OBJC_BOOL_DEFINED) && !defined(OBJC_BOOL_DEFINED)
typedef bool BOOL;
#endif

extern "C" {

Animal* Animal_new(int age) {
  return new Animal(age);
}

void Animal_delete(Animal* self) {
  delete self;
}

void Animal_speak(Animal* self) {
  self->speak();
}

int Animal_getAge(const Animal* self) {
  return self->getAge();
}

int Animal_getCount() {
  return Animal::getCount();
}

void Animal_Animal_new() {
  Animal::Animal_new();
}

void Animal_Animal_delete() {
  Animal::Animal_delete();
}

BOOL Animal_isMammalClass(const Animal* self) {
  return self->isMammalClass();
}

double Animal_getWeight(const Animal* self, double multiplier) {
  return self->getWeight(multiplier);
}

int Animal_addAges(Animal* self, int otherAge, float scale) {
  return self->addAges(otherAge, scale);
}

int Animal_sum(int a, int b) {
  return Animal::sum(a, b);
}

}
