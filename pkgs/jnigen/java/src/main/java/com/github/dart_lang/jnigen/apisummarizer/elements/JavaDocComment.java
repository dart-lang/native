// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.apisummarizer.elements;

public class JavaDocComment {
  // TODO(#28): Build a detailed tree representation of JavaDocComment
  // which can be processed by tools in other languages as well.
  public String comment;

  public JavaDocComment(String comment) {
    this.comment = comment;
  }
}
