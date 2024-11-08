// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.apisummarizer.disasm;

import com.github.dart_lang.jnigen.apisummarizer.elements.Method;
import com.github.dart_lang.jnigen.apisummarizer.elements.TypeUsage;
import java.util.ArrayList;
import java.util.List;
import org.objectweb.asm.AnnotationVisitor;
import org.objectweb.asm.MethodVisitor;
import org.objectweb.asm.TypePath;
import org.objectweb.asm.TypeReference;

public class AsmMethodVisitor extends MethodVisitor {
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
  public AnnotationVisitor visitAnnotation(String descriptor, boolean visible) {
    var annotation = TypeUtils.annotationFromDescriptor(descriptor);
    method.annotations.add(annotation);
    return new AsmAnnotationVisitor(annotation);
  }

  @Override
  public AnnotationVisitor visitTypeAnnotation(
      int typeRef, TypePath typePath, String descriptor, boolean visible) {
    var typeReference = new TypeReference(typeRef);
    var annotation = TypeUtils.annotationFromDescriptor(descriptor);
    TypeUsage.ReferredType startingType = null;
    switch (typeReference.getSort()) {
      case TypeReference.METHOD_TYPE_PARAMETER:
        {
          var index = typeReference.getTypeParameterIndex();
          method.typeParams.get(index).annotations.add(annotation);
          break;
        }
      case TypeReference.METHOD_TYPE_PARAMETER_BOUND:
        {
          var typeParamIndex = typeReference.getTypeParameterIndex();
          var index = typeReference.getTypeParameterBoundIndex();
          startingType = method.typeParams.get(typeParamIndex).bounds.get(index).type;
          break;
        }
      case TypeReference.METHOD_RETURN:
        {
          startingType = method.returnType.type;
          break;
        }
      case TypeReference.METHOD_RECEIVER:
        {
          // Not sure what this is.
          break;
        }
      case TypeReference.METHOD_FORMAL_PARAMETER:
        {
          var index = typeReference.getFormalParameterIndex();
          startingType = method.params.get(index).type.type;
          break;
        }
      case TypeReference.THROWS:
        {
          // Ignore this as Dart does not have an equivalent to `throws`.
          break;
        }
    }
    if (startingType != null) {
      TypeUtils.moveToTypePath(startingType, typePath).annotations.add(annotation);
    }
    return super.visitTypeAnnotation(typeRef, typePath, descriptor, visible);
  }

  @Override
  public AnnotationVisitor visitParameterAnnotation(
      int parameter, String descriptor, boolean visible) {
    var annotation = TypeUtils.annotationFromDescriptor(descriptor);
    method.params.get(parameter).annotations.add(annotation);
    return new AsmAnnotationVisitor(annotation);
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
