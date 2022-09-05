// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.apisummarizer.disasm;

import com.github.dart_lang.jnigen.apisummarizer.elements.JavaAnnotation;
import com.github.dart_lang.jnigen.apisummarizer.elements.Method;
import java.util.ArrayList;
import java.util.List;
import org.objectweb.asm.AnnotationVisitor;
import org.objectweb.asm.MethodVisitor;
import org.objectweb.asm.TypePath;

public class AsmMethodVisitor extends MethodVisitor implements AsmAnnotatedElementVisitor {
  Method method;
  List<String> paramNames = new ArrayList<>();

  protected AsmMethodVisitor(Method method) {
    super(AsmConstants.API);
    this.method = method;
  }

  @Override
  public void visitParameter(String name, int access) {
    paramNames.add(name);
  }

  @Override
  public void addAnnotation(JavaAnnotation annotation) {
    method.annotations.add(annotation);
  }

  @Override
  public AnnotationVisitor visitAnnotationDefault(String descriptor, boolean visible) {
    return AsmAnnotatedElementVisitor.super.visitAnnotationDefault(descriptor, visible);
  }

  @Override
  public AnnotationVisitor visitTypeAnnotation(
      int typeRef, TypePath typePath, String descriptor, boolean visible) {
    // TODO(#23): Collect annotation on type parameter
    return super.visitTypeAnnotation(typeRef, typePath, descriptor, visible);
  }

  @Override
  public AnnotationVisitor visitParameterAnnotation(
      int parameter, String descriptor, boolean visible) {
    // TODO(#23): collect and attach it to parameters
    return super.visitParameterAnnotation(parameter, descriptor, visible);
  }

  @Override
  public void visitEnd() {
    if (paramNames.size() == method.params.size()) {
      for (int i = 0; i < paramNames.size(); i++) {
        method.params.get(i).name = paramNames.get(i);
      }
    }
  }
}
