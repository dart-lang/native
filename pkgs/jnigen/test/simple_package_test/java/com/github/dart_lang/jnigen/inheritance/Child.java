// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.inheritance;

public class Child extends BaseClass<String> implements BaseInterface {
  @Override
  public String foo() {
    return "foo";
  }

  public String someMethod(String s) {
    return s;
  }
}
