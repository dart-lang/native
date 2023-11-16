// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.apisummarizer.doclet;

import com.sun.source.util.DocTrees;
import javax.lang.model.util.Elements;
import javax.lang.model.util.Types;
import jdk.javadoc.doclet.DocletEnvironment;

/** Class to hold utility classes initialized from DocletEnvironment. */
public class AstEnv {
  public final Types types;
  public final Elements elements;
  public final DocTrees trees;

  public AstEnv(Types types, Elements elements, DocTrees trees) {
    this.types = types;
    this.elements = elements;
    this.trees = trees;
  }

  public static AstEnv fromEnvironment(DocletEnvironment env) {
    return new AstEnv(env.getTypeUtils(), env.getElementUtils(), env.getDocTrees());
  }
}
