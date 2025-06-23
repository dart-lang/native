// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.apisummarizer.elements;

import java.util.HashMap;
import java.util.Map;

public class JavaAnnotation {
  public String binaryName;
  public Map<String, Object> properties = new HashMap<>();

  public JavaAnnotation() {}

  public JavaAnnotation(String binaryName) {
    this.binaryName = binaryName;
  }

  public static final JavaAnnotation nonNull = new JavaAnnotation("androidx.annotation.NonNull");

  public static class EnumVal {
    public String enumClass;
    public String value;

    public EnumVal(String enumClass, String value) {
      this.enumClass = enumClass;
      this.value = value;
    }
  }
}
