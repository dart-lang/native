// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.interfaces;

public class StringConverterConsumer {

  public static int consumeOnSameThread(StringConverter stringConverter, String s) {
    try {
      return stringConverter.parseToInt(s);
    } catch (StringConversionException e) {
      return -1;
    }
  }
}
