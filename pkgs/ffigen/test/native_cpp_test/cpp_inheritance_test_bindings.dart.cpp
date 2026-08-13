#include <memory>
#include "cpp_inheritance_test.h"

#if defined(_WIN32)
#define FFIGEN_EXPORT __declspec(dllexport)
#else
#define FFIGEN_EXPORT
#endif

extern "C" {

FFIGEN_EXPORT int AccessBase_value(const AccessBase* self) {
  return self->value();
}

FFIGEN_EXPORT void AccessBase_delete(AccessBase* self) {
  delete self;
}

FFIGEN_EXPORT Circle* Circle_new(double x, double y, double radius) {
  return new Circle(x, y, radius);
}

FFIGEN_EXPORT double Circle_area(const Circle* self) {
  return self->area();
}

FFIGEN_EXPORT double Circle_getX(const Circle* self) {
  return static_cast<const Shape*>(self)->getX();
}

FFIGEN_EXPORT double Circle_getY(const Circle* self) {
  return static_cast<const Shape*>(self)->getY();
}

FFIGEN_EXPORT void Circle_delete(Circle* self) {
  delete self;
}

FFIGEN_EXPORT ColoredCircle* ColoredCircle_new(double x, double y, double radius, int color) {
  return new ColoredCircle(x, y, radius, color);
}

FFIGEN_EXPORT int ColoredCircle_getColor(const ColoredCircle* self) {
  return self->getColor();
}

FFIGEN_EXPORT double ColoredCircle_area(const ColoredCircle* self) {
  return static_cast<const Circle*>(self)->area();
}

FFIGEN_EXPORT double ColoredCircle_getX(const ColoredCircle* self) {
  return static_cast<const Circle*>(self)->getX();
}

FFIGEN_EXPORT double ColoredCircle_getY(const ColoredCircle* self) {
  return static_cast<const Circle*>(self)->getY();
}

FFIGEN_EXPORT int ColoredCircle_draw(const ColoredCircle* self) {
  return static_cast<const Drawable*>(self)->draw();
}

FFIGEN_EXPORT void ColoredCircle_delete(ColoredCircle* self) {
  delete self;
}

FFIGEN_EXPORT DiamondBase* DiamondBase_new() {
  return new DiamondBase();
}

FFIGEN_EXPORT int DiamondBase_baseVal(const DiamondBase* self) {
  return self->baseVal();
}

FFIGEN_EXPORT int DiamondBase_virtVal(const DiamondBase* self) {
  return self->virtVal();
}

FFIGEN_EXPORT void DiamondBase_delete(DiamondBase* self) {
  delete self;
}

FFIGEN_EXPORT DiamondDerived* DiamondDerived_new() {
  return new DiamondDerived();
}

FFIGEN_EXPORT int DiamondDerived_virtVal(const DiamondDerived* self) {
  return static_cast<const DiamondLeft*>(self)->virtVal();
}

FFIGEN_EXPORT int DiamondDerived_baseVal(const DiamondDerived* self) {
  return static_cast<const DiamondLeft*>(self)->baseVal();
}

FFIGEN_EXPORT void DiamondDerived_delete(DiamondDerived* self) {
  delete self;
}

FFIGEN_EXPORT DiamondLeft* DiamondLeft_new() {
  return new DiamondLeft();
}

FFIGEN_EXPORT int DiamondLeft_virtVal(const DiamondLeft* self) {
  return self->virtVal();
}

FFIGEN_EXPORT int DiamondLeft_baseVal(const DiamondLeft* self) {
  return static_cast<const DiamondBase*>(self)->baseVal();
}

FFIGEN_EXPORT void DiamondLeft_delete(DiamondLeft* self) {
  delete self;
}

FFIGEN_EXPORT DiamondRight* DiamondRight_new() {
  return new DiamondRight();
}

FFIGEN_EXPORT int DiamondRight_baseVal(const DiamondRight* self) {
  return static_cast<const DiamondBase*>(self)->baseVal();
}

FFIGEN_EXPORT int DiamondRight_virtVal(const DiamondRight* self) {
  return static_cast<const DiamondBase*>(self)->virtVal();
}

FFIGEN_EXPORT void DiamondRight_delete(DiamondRight* self) {
  delete self;
}

FFIGEN_EXPORT Drawable* Drawable_new() {
  return new Drawable();
}

FFIGEN_EXPORT int Drawable_draw(const Drawable* self) {
  return self->draw();
}

FFIGEN_EXPORT void Drawable_delete(Drawable* self) {
  delete self;
}

FFIGEN_EXPORT OverloadBase* OverloadBase_new() {
  return new OverloadBase();
}

FFIGEN_EXPORT int OverloadBase_getValue(OverloadBase* self, int x) {
  return self->getValue(x);
}

FFIGEN_EXPORT double OverloadBase_getValueDouble(OverloadBase* self, double x) {
  return self->getValueDouble(x);
}

FFIGEN_EXPORT void OverloadBase_delete(OverloadBase* self) {
  delete self;
}

FFIGEN_EXPORT OverloadDerived* OverloadDerived_new() {
  return new OverloadDerived();
}

FFIGEN_EXPORT int OverloadDerived_getValue(OverloadDerived* self, int x) {
  return self->getValue(x);
}

FFIGEN_EXPORT double OverloadDerived_getValueDouble(OverloadDerived* self, double x) {
  return static_cast<OverloadBase*>(self)->getValueDouble(x);
}

FFIGEN_EXPORT void OverloadDerived_delete(OverloadDerived* self) {
  delete self;
}

FFIGEN_EXPORT PrivateDerived* PrivateDerived_new() {
  return new PrivateDerived();
}

FFIGEN_EXPORT void PrivateDerived_delete(PrivateDerived* self) {
  delete self;
}

FFIGEN_EXPORT ProtectedDerived* ProtectedDerived_new() {
  return new ProtectedDerived();
}

FFIGEN_EXPORT void ProtectedDerived_delete(ProtectedDerived* self) {
  delete self;
}

FFIGEN_EXPORT PublicDerived* PublicDerived_new() {
  return new PublicDerived();
}

FFIGEN_EXPORT int PublicDerived_value(const PublicDerived* self) {
  return static_cast<const AccessBase*>(self)->value();
}

FFIGEN_EXPORT void PublicDerived_delete(PublicDerived* self) {
  delete self;
}

FFIGEN_EXPORT Shape* Shape_new(double x, double y) {
  return new Shape(x, y);
}

FFIGEN_EXPORT double Shape_getX(const Shape* self) {
  return self->getX();
}

FFIGEN_EXPORT double Shape_getY(const Shape* self) {
  return self->getY();
}

FFIGEN_EXPORT void Shape_delete(Shape* self) {
  delete self;
}

FFIGEN_EXPORT Square* Square_new(double x, double y, double side) {
  return new Square(x, y, side);
}

FFIGEN_EXPORT double Square_getX(const Square* self) {
  return self->getX();
}

FFIGEN_EXPORT double Square_area(const Square* self) {
  return self->area();
}

FFIGEN_EXPORT double Square_getY(const Square* self) {
  return static_cast<const Shape*>(self)->getY();
}

FFIGEN_EXPORT void Square_delete(Square* self) {
  delete self;
}

}
