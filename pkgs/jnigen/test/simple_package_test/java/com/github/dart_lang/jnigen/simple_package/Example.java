// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.simple_package;

import java.util.Arrays;

public class Example {
  public static final int ON = 1;
  public static final int OFF = 0;

  public static Aux aux;
  public static int num;

  static {
    aux = new Aux(true);
    num = 121;
  }

  public int whichExample() {
    return 0;
  }

  public static Aux getAux() {
    return aux;
  }

  public static int addInts(int a, int b) {
    return a + b;
  }

  public static Integer[] getArr() {
    return new Integer[] {1, 2, 3};
  }

  public static int addAll(Integer[] arr) {
    return Arrays.stream(arr).mapToInt(val -> val).sum();
  }

  public Example getSelf() {
    return this;
  }

  public int getNum() {
    return num;
  }

  public void setNum(int num) {
    this.num = num;
  }

  public static void throwException() {
    throw new RuntimeException("Hello");
  }

  public static class Aux {
    public boolean value;

    public Aux(boolean value) {
      this.value = value;
    }

    public boolean getValue() {
      return value;
    }

    public void setValue(boolean value) {
      this.value = value;
    }
  }
}
