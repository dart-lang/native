// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:test/test.dart';

import '../test_util/callback_types.dart';
import 'bindings.dart';

void registerTests(String groupName, TestRunnerCallback test) {
  group(groupName, () {
    if (!Platform.isAndroid && !Platform.isLinux && !Platform.isMacOS) {
      return;
    }

    test('Stub inheritance and polymorphism', () {
      final c = C();
      final a = A();

      // C extends D, and A.takeD accepts D.
      // This should work because C implements D.
      a.takeD(c);

      // Verify D is a stub
      expect(D.type.signature, equals('Lcom/example/D;'));

      // Verify isA works
      expect(c.isA(D.type), isTrue);
      expect(c.isA(C.type), isTrue);
    });

    test('Stub method params and returns', () {
      final a = A();
      final b = a.b;

      // Verify B is a stub
      expect(B.type.signature, equals('Lcom/example/B;'));

      // Verify we can pass it back
      a.takeB(b);

      expect(b?.isA(B.type), isTrue);
    });
  });
}
