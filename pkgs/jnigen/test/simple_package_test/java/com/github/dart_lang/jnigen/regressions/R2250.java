// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.regressions;

public interface R2250<T> {
  public void foo(T t);

  public interface Child extends R2250 {}
}
