// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.apisummarizer.disasm;

import com.github.dart_lang.jnigen.apisummarizer.elements.Field;
import org.objectweb.asm.AnnotationVisitor;
import org.objectweb.asm.FieldVisitor;
import org.objectweb.asm.TypePath;

public class AsmFieldVisitor extends FieldVisitor {
  Field field;

  public AsmFieldVisitor(Field field) {
    super(AsmConstants.API);
    this.field = field;
  }

  @Override
  public AnnotationVisitor visitAnnotation(String descriptor, boolean visible) {
    var annotation = TypeUtils.annotationFromDescriptor(descriptor);
    field.annotations.add(annotation);
    return new AsmAnnotationVisitor(annotation);
  }

  @Override
  public AnnotationVisitor visitTypeAnnotation(
      int typeRef, TypePath typePath, String descriptor, boolean visible) {
    var annotation = TypeUtils.annotationFromDescriptor(descriptor);
    TypeUtils.moveToTypePath(field.type.type, typePath).annotations.add(annotation);
    return super.visitTypeAnnotation(typeRef, typePath, descriptor, visible);
  }
}
