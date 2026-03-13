// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.inheritance;

import com.github.dart_lang.jnigen.annotations.NotNull;
import com.github.dart_lang.jnigen.annotations.Nullable;

public class GenericSubclass<T, U> extends GenericBase<@NotNull T, @Nullable U> {
  @Override
  public T method(T arg) {
    return arg;
  }

  @Override
  public U method2(U arg) {
    return arg;
  }

  public @Nullable T methodReturningNullableT(@NotNull T arg) {
    return arg;
  }

  public @NotNull U methodReturningNotNullU(@Nullable U arg) {
    return (U) arg;
  }
}
