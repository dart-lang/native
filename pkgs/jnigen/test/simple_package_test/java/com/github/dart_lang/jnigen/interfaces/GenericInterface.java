// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.interfaces;

import java.util.Map;

public interface GenericInterface<T> {
  <U> U[] genericArrayOf(U element);

  T[] arrayOf(T element);

  <U> Map<T, U> mapOf(T key, U value);

  <U> U firstOfGenericArray(U[] array);

  T firstOfArray(T[] array);

  <U> T firstKeyOf(Map<T, U> map);

  <U> U firstValueOf(Map<T, U> map);
}
