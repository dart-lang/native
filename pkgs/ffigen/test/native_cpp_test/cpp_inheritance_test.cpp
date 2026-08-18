// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "cpp_inheritance_test.h"

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

Shape::Shape(double x, double y) : x_(x), y_(y) {}
Shape::~Shape() {}
double Shape::getX() const { return x_; }
double Shape::getY() const { return y_; }

Drawable::Drawable() : drawCount_(0) {}
Drawable::~Drawable() {}
int Drawable::draw() const { return 42; }

Circle::Circle(double x, double y, double radius)
    : Shape(x, y), radius_(radius) {}

double Circle::area() const {
    return M_PI * radius_ * radius_;
}

ColoredCircle::ColoredCircle(double x, double y, double radius, int color)
    : Circle(x, y, radius), Drawable(), color_(color) {}

int ColoredCircle::getColor() const { return color_; }

Square::Square(double x, double y, double side)
    : Shape(x, y), side_(side) {}

double Square::getX() const { return Shape::getX() + side_; }

double Square::area() const { return side_ * side_; }

int AccessBase::value() const { return v_; }
PublicDerived::PublicDerived() {}
ProtectedDerived::ProtectedDerived() {}
PrivateDerived::PrivateDerived() {}

OverloadBase::OverloadBase() {}
OverloadBase::~OverloadBase() {}
int OverloadBase::getValue(int x) { return x * 2; }
double OverloadBase::getValueDouble(double x) { return x * 3.0; }

OverloadDerived::OverloadDerived() {}
int OverloadDerived::getValue(int x) { return x * 10; }

DiamondBase::DiamondBase() {}
DiamondBase::~DiamondBase() {}
int DiamondBase::baseVal() const { return 42; }
int DiamondBase::virtVal() const { return 100; }

DiamondLeft::DiamondLeft() {}
int DiamondLeft::virtVal() const { return 200; }
DiamondRight::DiamondRight() {}
DiamondDerived::DiamondDerived() {}
