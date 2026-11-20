// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#if defined(_WIN32)
#define CPP_TEST_EXPORT __declspec(dllexport)
#else
#define CPP_TEST_EXPORT
#endif

class Animal {
public:
  int age;
  Animal(int age);
  ~Animal();
  void speak();
  int getAge() const;
  static int getCount();
  static void Animal_new();
  static void Animal_delete();

  bool isMammalClass() const;
  double getWeight(double multiplier) const;
  int addAges(int otherAge, float scale);
  static int sum(int a, int b);
  Animal copyAndAddAge(Animal other) const;
  static bool haveSameAge(Animal a, Animal b);
};

struct AnimalOwner {
  Animal *animal;
  int id;
};

extern "C" {
CPP_TEST_EXPORT Animal *createAnimalPointer(int age);
CPP_TEST_EXPORT int getAgeFromPointer(Animal *animal);
CPP_TEST_EXPORT void setAgeFromPointer(Animal *animal, int age);
extern CPP_TEST_EXPORT Animal *globalAnimal;
CPP_TEST_EXPORT int getGlobalAnimalAge();
CPP_TEST_EXPORT void setGlobalAnimalAge(int age);
CPP_TEST_EXPORT AnimalOwner createAnimalOwner(Animal *animal, int id);
CPP_TEST_EXPORT int getAnimalOwnerAge(const AnimalOwner *owner);
CPP_TEST_EXPORT void setAnimalOwnerAge(AnimalOwner *owner, int age);

// Function pointer args/returns: Animal* in function pointer signatures.
CPP_TEST_EXPORT Animal *applyFactory(Animal *(*factory)(int age), int age);
CPP_TEST_EXPORT int applyProcessor(int (*processor)(Animal *a), Animal *animal);
CPP_TEST_EXPORT void applyTransform(void (*transform)(Animal *a, int value),
                                    Animal *animal, int value);
}