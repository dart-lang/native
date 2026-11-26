// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jni.legacy;

public enum Color {
  RED(1),
  GREEN(2),
  BLUE(3);

  private final int code;

  Color(int code) {
    this.code = code;
  }

  public int getCode() {
    return code;
  }
}
