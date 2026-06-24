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

double Animal::getWeight(double multiplier) const { return age * 1.5 * multiplier; }

int Animal::addAges(int otherAge, float scale) { return (age + otherAge) * scale; }

int Animal::sum(int a, int b) { return a + b; }

