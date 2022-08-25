// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jni_gen.apisummarizer.disasm;

import com.github.dart_lang.jni_gen.apisummarizer.elements.Field;
import com.github.dart_lang.jni_gen.apisummarizer.elements.JavaAnnotation;
import org.objectweb.asm.AnnotationVisitor;
import org.objectweb.asm.FieldVisitor;

public class AsmFieldVisitor extends FieldVisitor implements AsmAnnotatedElementVisitor {
  Field field;

  public AsmFieldVisitor(Field field) {
    super(AsmConstants.API);
    this.field = field;
  }

  @Override
  public void addAnnotation(JavaAnnotation annotation) {
    field.annotations.add(annotation);
  }

  @Override
  public AnnotationVisitor visitAnnotation(String descriptor, boolean visible) {
    return AsmAnnotatedElementVisitor.super.visitAnnotationDefault(descriptor, visible);
  }
}
