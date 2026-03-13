// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.inheritance;

public class GenericBase<T, U> {
  public T field;
  public U field2;

  public T method(T arg) {
    return arg;
  }

  public U method2(U arg) {
    return arg;
  }
}
