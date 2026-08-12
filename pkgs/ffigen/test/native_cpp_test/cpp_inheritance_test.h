// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

class Shape {
public:
    Shape(double x, double y);
    virtual ~Shape();
    virtual double getX() const;
    double getY() const;

private:
    double x_;
    double y_;
};

class Drawable {
public:
    Drawable();
    virtual ~Drawable();
    virtual int draw() const;

private:
    int drawCount_;
};

class Circle : public Shape {
public:
    Circle(double x, double y, double radius);
    double area() const;

private:
    double radius_;
};

class ColoredCircle : public Circle, public Drawable {
public:
    ColoredCircle(double x, double y, double radius, int color);
    int getColor() const;

private:
    int color_;
};

class Square : public Shape {
public:
    Square(double x, double y, double side);
    double getX() const override; // override of Shape::getX
    double area() const;

private:
    double side_;
};

class AccessBase {
public:
    int value() const;
private:
    int v_ = 99;
};

class PublicDerived  : public    AccessBase { public: PublicDerived(); };
class ProtectedDerived : protected AccessBase { public: ProtectedDerived(); };
class PrivateDerived   : private   AccessBase { public: PrivateDerived(); };

class OverloadBase {
public:
    OverloadBase();
    virtual ~OverloadBase();
    int getValue(int x);
    double getValueDouble(double x);
};

class OverloadDerived : public OverloadBase {
public:
    OverloadDerived();
    int getValue(int x);
};

class DiamondBase {
public:
    DiamondBase();
    virtual ~DiamondBase();
    int baseVal() const;
};

class DiamondLeft : public DiamondBase {
public:
    DiamondLeft();
};

class DiamondRight : public DiamondBase {
public:
    DiamondRight();
};

class DiamondDerived : public DiamondLeft, public DiamondRight {
public:
    DiamondDerived();
};
