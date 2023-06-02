// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.apisummarizer.disasm;

import com.github.dart_lang.jnigen.apisummarizer.elements.JavaAnnotation;
import java.util.ArrayList;
import java.util.List;
import org.objectweb.asm.AnnotationVisitor;
import org.objectweb.asm.Type;

public class AsmAnnotationVisitor extends AnnotationVisitor {

  JavaAnnotation annotation;

  protected AsmAnnotationVisitor(JavaAnnotation annotation) {
    super(AsmConstants.API);
    this.annotation = annotation;
  }

  @Override
  public void visit(String name, Object value) {
    annotation.properties.put(name, value);
  }

  @Override
  public void visitEnum(String name, String descriptor, String value) {
    annotation.properties.put(
        name, new JavaAnnotation.EnumVal(Type.getType(descriptor).getClassName(), value));
  }

  @Override
  public AnnotationVisitor visitAnnotation(String name, String descriptor) {
    var type = Type.getType(descriptor);
    var nested = new JavaAnnotation();
    nested.binaryName = type.getClassName();
    annotation.properties.put(name, nested);
    return new AsmAnnotationVisitor(nested);
  }

  @Override
  public AnnotationVisitor visitArray(String name) {
    List<Object> list = new ArrayList<>();
    annotation.properties.put(name, list);
    return new AnnotationArrayVisitor(list);
  }

  public static class AnnotationArrayVisitor extends AnnotationVisitor {
    List<Object> list;

    protected AnnotationArrayVisitor(List<Object> list) {
      super(AsmConstants.API);
      this.list = list;
    }

    @Override
    public void visit(String unused, Object value) {
      list.add(value);
    }

    @Override
    public void visitEnum(String unused, String descriptor, String value) {
      var type = Type.getType(descriptor);
      list.add(new JavaAnnotation.EnumVal(type.getClassName(), value));
    }

    @Override
    public AnnotationVisitor visitAnnotation(String unused, String descriptor) {
      var type = Type.getType(descriptor);
      var nested = new JavaAnnotation();
      nested.binaryName = type.getClassName();
      list.add(nested);
      return new AsmAnnotationVisitor(nested);
    }

    @Override
    public AnnotationVisitor visitArray(String unused) {
      List<Object> nested = new ArrayList<>();
      list.add(nested);
      return new AnnotationArrayVisitor(nested);
    }
  }
}
