#include "cpp_class_test.h"

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

}
