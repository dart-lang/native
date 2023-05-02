// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.simple_package;

import java.io.*;
import java.util.*;

public class Exceptions {
  public Exceptions() {}
  // constructor throwing exception
  public Exceptions(float x) {
    throw new IllegalArgumentException("Float is not a serious type");
  }

  public Exceptions(int a, int b, int c, int d, int e, int f) {
    throw new IllegalArgumentException("Too many arguments, but none in your favor");
  }

  public static Object staticObjectMethod() {
    throw new RuntimeException(":-/");
  }

  public static int staticIntMethod() {
    throw new RuntimeException("\\-:");
  }

  public static Object[] staticObjectArrayMethod() {
    throw new RuntimeException(":-/[]");
  }

  public static int[] staticIntArrayMethod() {
    throw new RuntimeException("\\-:[]");
  }

  public Object objectMethod() {
    throw new RuntimeException("['--']");
  }

  public int intMethod() {
    throw new RuntimeException("[-_-]");
  }

  public Object[] objectArrayMethod() {
    throw new RuntimeException(":-/[]");
  }

  public int[] intArrayMethod() {
    throw new RuntimeException("\\-:[]");
  }

  public int throwNullPointerException() {
    Random random = null;
    return random.nextInt();
  }

  public InputStream throwFileNotFoundException() throws IOException {
    return new FileInputStream("/dev/nulll/59613/287");
  }

  public FileInputStream throwClassCastException() {
    InputStream x = System.in;
    return (FileInputStream) x;
  }

  public int throwArrayIndexException() {
    int[] nums = {1, 2};
    return nums[4];
  }

  public int throwArithmeticException() {
    int x = 10;
    int y = 100 - 100 + 1 - 1;
    return x / y;
  }

  public static void throwLoremIpsum() {
    throw new RuntimeException("Lorem Ipsum");
  }
}
