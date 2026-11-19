// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.regressions;

public class R630<T, S> {
  public T value;
  private final S outerOnly;

  public R630(T value, S outerOnly) {
    this.value = value;
    this.outerOnly = outerOnly;
  }

  public <S extends Number> S echoOuter(S value) {
    return value;
  }

  public S getOuterOnly() {
    return outerOnly;
  }

  public class Inner<T, U> {
    public T value;
    private final U innerOnly;

    public Inner(T value, U innerOnly) {
      this.value = value;
      this.innerOnly = innerOnly;
    }

    public <S extends Number> Inner(T[] values, S index, U innerOnly) {
      this(values[index.intValue()], innerOnly);
    }

    public Object getOuterValue() {
      return R630.this.value;
    }

    public <U extends Number> U echoInner(U value) {
      return value;
    }

    public <S extends Number> S echoOuter(S value) {
      return value;
    }

    public U getInnerOnly() {
      return innerOnly;
    }

    public S getOuterOnly() {
      return R630.this.outerOnly;
    }

    public class Deep<S> {
      public final S value;

      public Deep(S value) {
        this.value = value;
      }

      public U getInnerOnly() {
        return Inner.this.innerOnly;
      }

      public Object getOuterOnly() {
        return R630.this.outerOnly;
      }
    }
  }
}
