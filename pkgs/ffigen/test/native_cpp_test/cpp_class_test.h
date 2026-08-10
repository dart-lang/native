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
};
