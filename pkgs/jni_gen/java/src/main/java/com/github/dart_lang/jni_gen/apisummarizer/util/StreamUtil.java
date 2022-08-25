// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jni_gen.apisummarizer.util;

import java.util.Arrays;
import java.util.List;
import java.util.function.Function;
import java.util.stream.Collectors;

public class StreamUtil {
  public static <T, R> List<R> map(List<T> list, Function<T, R> function) {
    return list.stream().map(function).collect(Collectors.toList());
  }

  public static <T, R> List<R> map(T[] array, Function<T, R> function) {
    return Arrays.stream(array).map(function).collect(Collectors.toList());
  }
}
