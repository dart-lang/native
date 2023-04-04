// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.apisummarizer.disasm;

import static com.github.dart_lang.jnigen.apisummarizer.util.ExceptionUtil.wrapCheckedException;

import com.github.dart_lang.jnigen.apisummarizer.elements.ClassDecl;
import com.github.dart_lang.jnigen.apisummarizer.util.InputStreamProvider;
import java.util.ArrayList;
import java.util.List;
import org.objectweb.asm.ClassReader;

public class AsmSummarizer {

  public static List<ClassDecl> run(List<InputStreamProvider> inputProviders) {
    List<ClassDecl> parsed = new ArrayList<>();
    for (var provider : inputProviders) {
      var inputStream = provider.getInputStream();
      var classReader = wrapCheckedException(ClassReader::new, inputStream);
      var visitor = new AsmClassVisitor();
      classReader.accept(visitor, 0);
      parsed.addAll(visitor.getVisited());
      provider.close();
    }
    return parsed;
  }
}
