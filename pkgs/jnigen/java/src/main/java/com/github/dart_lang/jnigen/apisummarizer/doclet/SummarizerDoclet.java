// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.apisummarizer.doclet;

import com.github.dart_lang.jnigen.apisummarizer.Main;
import jdk.javadoc.doclet.DocletEnvironment;

public class SummarizerDoclet extends SummarizerDocletBase {
  @Override
  public boolean run(DocletEnvironment docletEnvironment) {
    var result = super.run(docletEnvironment);
    Main.writeAll(types);
    return result;
  }
}
