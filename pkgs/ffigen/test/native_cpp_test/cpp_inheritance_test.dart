// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';
import 'cpp_inheritance_test_bindings.dart';

void main() {
  group('C++ Inheritance', () {
    test('Single inheritance - Circle implements Shape', () {
      final circle = Circle(10.0, 20.0, 5.0);

      // Polymorphic interface conformance in Dart
      expect(circle, isA<Shape>());

      // Own methods
      expect(circle.area(), closeTo(78.5398, 0.001));

      // Inherited methods from Shape
      expect(circle.getX(), 10.0);
      expect(circle.getY(), 20.0);

      circle.dispose();
    });

    test('Multiple inheritance - ColoredCircle', () {
      final coloredCircle = ColoredCircle(1.0, 2.0, 3.0, 0xFF00FF);

      // Polymorphic interface conformance
      expect(coloredCircle, isA<Circle>());
      expect(coloredCircle, isA<Shape>());
      expect(coloredCircle, isA<Drawable>());

      // Own method
      expect(coloredCircle.getColor(), 0xFF00FF);

      // Inherited from Circle
      expect(coloredCircle.area(), closeTo(28.2743, 0.001));

      // Inherited from Shape (transitive)
      expect(coloredCircle.getX(), 1.0);
      expect(coloredCircle.getY(), 2.0);

      // Inherited from Drawable (multiple inheritance branch)
      expect(coloredCircle.draw(), 42);

      coloredCircle.dispose();
    });

    test('Virtual method override - Square overrides getX', () {
      final square = Square(5.0, 10.0, 4.0);

      expect(square, isA<Shape>());
      expect(square.area(), 16.0);
      expect(square.getY(), 10.0);

      // Overridden getX() returns x + side = 5.0 + 4.0 = 9.0
      expect(square.getX(), 9.0);

      square.dispose();
    });

    test('Polymorphic delegation via interface types', () {
      final shapes = <Shape>[Circle(0.0, 0.0, 1.0), Square(10.0, 20.0, 5.0)];

      expect(shapes[0].getX(), 0.0);
      expect(shapes[1].getX(), 15.0); // 10 + 5 via virtual override

      for (final shape in shapes) {
        shape.dispose();
      }
    });

    test('Access specifier filtering - Public vs Private/Protected base', () {
      // PublicDerived inherits public AccessBase -> implements AccessBase
      final publicDerived = PublicDerived();
      expect(publicDerived, isA<AccessBase>());
      expect(publicDerived.value(), 99);
      publicDerived.dispose();

      // ProtectedDerived and PrivateDerived do NOT implement AccessBase
      final protectedDerived = ProtectedDerived();
      expect(protectedDerived, isNot(isA<AccessBase>()));
      protectedDerived.dispose();

      final privateDerived = PrivateDerived();
      expect(privateDerived, isNot(isA<AccessBase>()));
      privateDerived.dispose();
    });

    test('Throw StateError on inherited methods after dispose', () {
      final circle = Circle(1.0, 2.0, 3.0);
      circle.dispose();

      expect(circle.getX, throwsStateError);
      expect(circle.getY, throwsStateError);
      expect(circle.area, throwsStateError);
    });

    test('Overload handling - OverloadDerived overrides & inherits', () {
      final overload = OverloadDerived();
      expect(overload, isA<OverloadBase>());

      // Overridden getValue(int): 5 * 10 = 50
      expect(overload.getValue(5), 50);

      // Inherited getValueDouble(double): 5.0 * 3.0 = 15.0
      expect(overload.getValueDouble(5.0), closeTo(15.0, 0.001));

      overload.dispose();
    });

    test('Diamond inheritance - DiamondDerived inherits from both sides', () {
      final d = DiamondDerived();

      // DiamondDerived implements both DiamondLeft and DiamondRight
      expect(d, isA<DiamondLeft>());
      expect(d, isA<DiamondRight>());
      // And transitively implements DiamondBase through each branch
      expect(d, isA<DiamondBase>());

      // baseVal() is delegated through DiamondLeft (first direct base),
      // which itself dispatches through C++ — no ambiguity.
      expect(d.baseVal(), 42);

      d.dispose();
    });
  });
}
