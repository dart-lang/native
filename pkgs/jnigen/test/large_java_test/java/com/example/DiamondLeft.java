// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;

public interface DiamondLeft extends BaseInterface {
  int LEFT_FIELD = 1;
  void leftMethod();
  @Override
  default void baseMethod() {}
}
