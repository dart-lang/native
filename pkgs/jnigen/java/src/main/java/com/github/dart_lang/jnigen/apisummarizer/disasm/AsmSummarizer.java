// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.apisummarizer.disasm;

import static com.github.dart_lang.jnigen.apisummarizer.util.ExceptionUtil.wrapCheckedException;

import com.github.dart_lang.jnigen.apisummarizer.elements.ClassDecl;
import java.io.IOException;
import java.io.InputStream;
import java.util.List;
import java.util.Map;
import org.objectweb.asm.ClassReader;

public class AsmSummarizer {

  public static Map<String, ClassDecl> run(List<InputStream> inputStreams) {
    var visitor = new AsmClassVisitor();
    for (var inputStream : inputStreams) {
      var classReader = wrapCheckedException(ClassReader::new, inputStream);
      classReader.accept(visitor, 0);
      try {
        inputStream.close();
      } catch (IOException e) {
        throw new RuntimeException(e);
      }
    }
    return visitor.getVisited();
  }
}
