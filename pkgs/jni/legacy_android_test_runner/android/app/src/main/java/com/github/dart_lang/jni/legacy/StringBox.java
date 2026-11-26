// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jni.legacy;

public class StringBox extends Box<String> {
  public StringBox(String value) {
    super(value);
  }

  public int length() {
    return getValue().length();
  }
}
