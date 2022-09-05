// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.apisummarizer.disasm;

import com.github.dart_lang.jnigen.apisummarizer.elements.JavaAnnotation;
import org.objectweb.asm.AnnotationVisitor;
import org.objectweb.asm.Type;

// This interface removes some repetitive code using default methods

public interface AsmAnnotatedElementVisitor {
  void addAnnotation(JavaAnnotation annotation);

  default AnnotationVisitor visitAnnotationDefault(String descriptor, boolean visible) {
    var annotation = new JavaAnnotation();
    var aType = Type.getType(descriptor);
    annotation.binaryName = aType.getClassName();
    annotation.simpleName = TypeUtils.simpleName(aType);
    addAnnotation(annotation);
    return new AsmAnnotationVisitor(annotation);
  }
}
