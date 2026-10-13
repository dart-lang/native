// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

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
    Animal* animal;
    int id;
};

extern "C" {
    Animal* createAnimalPointer(int age);
    int getAgeFromPointer(Animal* animal);
    void setAgeFromPointer(Animal* animal, int age);
    extern Animal* globalAnimal;
    int getGlobalAnimalAge();
    void setGlobalAnimalAge(int age);
    AnimalOwner createAnimalOwner(Animal* animal, int id);
    int getAnimalOwnerAge(const AnimalOwner* owner);
    void setAnimalOwnerAge(AnimalOwner* owner, int age);
}