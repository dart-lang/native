// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "cpp_class_test.h"

Animal::Animal(int age) : age(age) {}

Animal::~Animal() {}

void Animal::speak() {}

int Animal::getAge() const { return age; }

int Animal::getCount() { return 42; }

void Animal::Animal_new() {}

void Animal::Animal_delete() {}

bool Animal::isMammalClass() const { return true; }

double Animal::getWeight(double multiplier) const {
  return age * 1.5 * multiplier;
}

int Animal::addAges(int otherAge, float scale) {
  return (age + otherAge) * scale;
}

int Animal::sum(int a, int b) { return a + b; }

extern "C" {
CPP_TEST_EXPORT Animal *createAnimalPointer(int age) { return new Animal(age); }

CPP_TEST_EXPORT int getAgeFromPointer(Animal *animal) {
  return animal != nullptr ? animal->age : -1;
}

CPP_TEST_EXPORT void setAgeFromPointer(Animal *animal, int age) {
  if (animal != nullptr) {
    animal->age = age;
  }
}

CPP_TEST_EXPORT Animal *globalAnimal = nullptr;

CPP_TEST_EXPORT int getGlobalAnimalAge() {
  return globalAnimal != nullptr ? globalAnimal->age : -1;
}

CPP_TEST_EXPORT void setGlobalAnimalAge(int age) {
  if (globalAnimal != nullptr) {
    globalAnimal->age = age;
  }
}

CPP_TEST_EXPORT AnimalOwner createAnimalOwner(Animal *animal, int id) {
  AnimalOwner owner;
  owner.animal = animal;
  owner.id = id;
  return owner;
}

CPP_TEST_EXPORT int getAnimalOwnerAge(const AnimalOwner *owner) {
  return (owner != nullptr && owner->animal != nullptr) ? owner->animal->age
                                                        : -1;
}

CPP_TEST_EXPORT void setAnimalOwnerAge(AnimalOwner *owner, int age) {
  if (owner != nullptr && owner->animal != nullptr) {
    owner->animal->age = age;
  }
}

CPP_TEST_EXPORT Animal *applyFactory(Animal *(*factory)(int age), int age) {
  return factory(age);
}

CPP_TEST_EXPORT int applyProcessor(int (*processor)(Animal *a),
                                   Animal *animal) {
  return processor(animal);
}

CPP_TEST_EXPORT void applyTransform(void (*transform)(Animal *a, int value),
                                    Animal *animal, int value) {
  transform(animal, value);
}
}
Animal Animal::copyAndAddAge(Animal other) const {
  return Animal(age + other.age);
}

bool Animal::haveSameAge(Animal a, Animal b) { return a.age == b.age; }
