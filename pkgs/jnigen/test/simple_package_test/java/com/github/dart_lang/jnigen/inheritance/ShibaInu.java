// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.inheritance;

import com.github.dart_lang.jnigen.annotations.NotNull;
import com.github.dart_lang.jnigen.annotations.Nullable;

public class ShibaInu implements Dog, Furry {
  @Override
  @NotNull
  public String eat(@NotNull String food) {
    return "Shiba eating " + food;
  }

  @Override
  @Nullable
  public String giveBirth(boolean success) {
    return success ? "Baby Shiba" : null;
  }

  @Override
  public int walk(int steps) {
    return steps;
  }

  @Override
  @NotNull
  public String bark() {
    return "Woof!";
  }

  @Override
  @NotNull
  public String groom() {
    return "Grooming Shiba";
  }
}
