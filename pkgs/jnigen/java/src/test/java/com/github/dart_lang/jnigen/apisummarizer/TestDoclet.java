// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.apisummarizer;

import com.github.dart_lang.jnigen.apisummarizer.doclet.SummarizerDocletBase;
import com.github.dart_lang.jnigen.apisummarizer.elements.ClassDecl;
import java.util.List;
import jdk.javadoc.doclet.DocletEnvironment;

public class TestDoclet extends SummarizerDocletBase {
  @Override
  public boolean run(DocletEnvironment docletEnvironment) {
    return super.run(docletEnvironment);
  }

  public static List<ClassDecl> getClassDecls() {
    return types;
  }
}
