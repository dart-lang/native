// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.interfaces;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

public class StringConverterConsumer {
  public static Integer consumeOnSameThread(StringConverter stringConverter, String s) {
    long id = Thread.currentThread().getId();
    System.out.println("J: Currently on " + id);
    try {
      return stringConverter.parseToInt(s);
    } catch (StringConversionException e) {
      return -1;
    }
  }

  public static Future<Integer> consumeOnAnotherThread(StringConverter stringConverter, String s) {
    long id = Thread.currentThread().getId();
    System.out.println("J again: Currently on " + id);
    ExecutorService executor = Executors.newSingleThreadExecutor();
    return executor.submit(() -> consumeOnSameThread(stringConverter, s));
  }
}
