// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.interfaces;

public class MyInterfaceConsumer {
  public static <T> void consumeOnAnotherThread(
      MyInterface<T> myInterface, String s, int a, boolean b, char c, double d, T t) {
    var thread = new Thread(() -> consumeOnSameThread(myInterface, s, a, b, c, d, t));
    thread.start();
  }

  public static <T> void consumeOnSameThread(
      MyInterface<T> myInterface, String s, int a, boolean b, char c, double d, T t) {
    String result = myInterface.stringCallback(s);
    myInterface.voidCallback(result);
    myInterface.manyPrimitives(a, b, c, d);
    myInterface.varCallback(t);
  }
}
