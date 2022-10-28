// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.apisummarizer.disasm;

import static com.github.dart_lang.jnigen.apisummarizer.util.ExceptionUtil.wrapCheckedException;

import com.github.dart_lang.jnigen.apisummarizer.elements.ClassDecl;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;
import org.objectweb.asm.ClassReader;

public class AsmSummarizer {

  public static List<ClassDecl> run(ArrayList<InputStream> inputs) {
    return inputs.stream()
        .map(input -> wrapCheckedException(ClassReader::new, input))
        .flatMap(
            reader -> {
              var visitor = new AsmClassVisitor();
              reader.accept(visitor, 0);
              return visitor.getVisited().stream();
            })
        .collect(Collectors.toList());
  }
}
