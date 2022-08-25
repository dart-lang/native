// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jni_gen.apisummarizer.util;

// Generic skip exception when the code cannot decide how to handle an element.
// The caller in some above layer can catch this and skip to appropriate extent.
public class SkipException extends RuntimeException {
  public SkipException(String message) {
    super(message);
  }
}
