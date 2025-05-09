// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.regressions;

// Regression test for https://github.com/dart-lang/native/issues/693.
public class R693<T extends R693<T>> {
  T foo() {
    return null;
  }

  public static class Child extends R693<Child> {
    Child foo() {
      return new Child();
    }
  }
}
