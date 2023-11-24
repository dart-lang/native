// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;

public class Example {
  public static final boolean staticFinalField = true;

  public Example(int instanceField) {
    this.instanceField = instanceField;
  }

  public static String staticField = "hello";

  public static String getStaticField() {
    return staticField;
  }

  public int instanceField;

  public int getInstanceField() {
    return instanceField;
  }

  protected int overrideableMethod(int x, int y) {}

  int defaultAccessNotVisible();

  private int privateAccessNotVisible();

  public static class Aux extends Example {
    public static int nothing = 0;

    public static Example getAnExample() {
      return new Example();
    }
  }
}
