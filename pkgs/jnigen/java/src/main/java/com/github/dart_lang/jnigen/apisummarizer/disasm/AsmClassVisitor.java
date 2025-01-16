// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.apisummarizer.disasm;

import static org.objectweb.asm.Opcodes.ACC_ENUM;

import com.github.dart_lang.jnigen.apisummarizer.elements.*;
import com.github.dart_lang.jnigen.apisummarizer.util.SkipException;
import com.github.dart_lang.jnigen.apisummarizer.util.StreamUtil;
import java.util.*;
import org.objectweb.asm.*;
import org.objectweb.asm.signature.SignatureReader;

public class AsmClassVisitor extends ClassVisitor {
  private static Param param(Type type, String name) {
    var param = new Param();
    param.name = name;
    param.type = TypeUtils.typeUsage(type);
    return param;
  }

  public Map<String, ClassDecl> getVisited() {
    return visited;
  }

  Map<String, ClassDecl> visited = new LinkedHashMap<>();
  Stack<ClassDecl> visiting = new Stack<>();

  /// Actual access for the inner classes as originally defined.
  Map<String, Integer> actualAccess = new HashMap<>();
  Map<String, String> outerClass = new HashMap<>();

  public AsmClassVisitor() {
    super(AsmConstants.API);
  }

  @Override
  public void visit(
      int version,
      int access,
      String name,
      String signature,
      String superName,
      String[] interfaces) {
    var current = new ClassDecl();
    visiting.push(current);
    current.binaryName = name.replace('/', '.');
    current.modifiers = TypeUtils.access(actualAccess.getOrDefault(current.binaryName, access));
    current.outerClassBinaryName = outerClass.getOrDefault(current.binaryName, null);
    current.declKind = TypeUtils.declKind(access);
    current.superclass = TypeUtils.typeUsage(Type.getObjectType(superName));
    current.interfaces =
        StreamUtil.map(interfaces, i -> TypeUtils.typeUsage(Type.getObjectType(i)));
    if (signature != null) {
      var reader = new SignatureReader(signature);
      reader.accept(new AsmClassSignatureVisitor(current));
    }
    super.visit(version, access, name, signature, superName, interfaces);
  }

  @Override
  public void visitInnerClass(String name, String outerName, String innerName, int access) {
    var binaryName = name.replace('/', '.');
    actualAccess.put(binaryName, access);
    if (outerName != null) {
      var outerClassBinaryName = outerName.replace('/', '.');
      outerClass.put(binaryName, outerClassBinaryName);
    }
    if (visited.containsKey(binaryName)) {
      // If the order of visit is outerClass-first, innerClass-second then only
      // correct the modifiers.
      visited.get(binaryName).modifiers = TypeUtils.access(access);
      visited.get(binaryName).outerClassBinaryName = outerClass.get(binaryName);
    }
    super.visitInnerClass(name, outerName, innerName, access);
  }

  @Override
  public FieldVisitor visitField(
      int access, String name, String descriptor, String signature, Object value) {
    if (name.contains("$")) {
      return null;
    }

    var field = new Field();
    field.name = name;
    field.type = TypeUtils.typeUsage(Type.getType(descriptor));
    field.defaultValue = value;
    field.modifiers = TypeUtils.access(access);
    if ((access & ACC_ENUM) != 0) {
      field.type.type.annotations.add(JavaAnnotation.nonNull);
      peekVisiting().values.add(name);
    }
    if (signature != null) {
      var reader = new SignatureReader(signature);
      reader.accept(new AsmTypeUsageSignatureVisitor(field.type));
    }
    peekVisiting().fields.add(field);
    return new AsmFieldVisitor(field);
  }

  @Override
  public MethodVisitor visitMethod(
      int access, String name, String descriptor, String signature, String[] exceptions) {
    var method = new Method();
    if (name.contains("$")) {
      return null;
    }
    method.name = name;
    method.descriptor = descriptor;
    var type = Type.getType(descriptor);
    var params = new ArrayList<Param>();
    var paramTypes = type.getArgumentTypes();
    var paramNames = new HashMap<String, Integer>();
    for (var pt : paramTypes) {
      var paramName = TypeUtils.defaultParamName(pt);
      if (paramNames.containsKey(paramName)) {
        var nth = paramNames.get(paramName);
        paramNames.put(paramName, nth + 1);
        paramName = paramName + nth;
      } else {
        paramNames.put(paramName, 1);
      }
      params.add(param(pt, paramName));
    }
    method.returnType = TypeUtils.typeUsage(type.getReturnType());
    method.modifiers = TypeUtils.access(access);
    method.params = params;
    if (signature != null) {
      var reader = new SignatureReader(signature);
      reader.accept(new AsmMethodSignatureVisitor(method));
    }
    peekVisiting().methods.add(method);
    return new AsmMethodVisitor(method);
  }

  @Override
  public AnnotationVisitor visitAnnotation(String descriptor, boolean visible) {
    if (descriptor.equals("Lkotlin/Metadata;")) {
      return new KotlinMetadataAnnotationVisitor(peekVisiting());
    }
    var annotation = TypeUtils.annotationFromDescriptor(descriptor);
    peekVisiting().annotations.add(annotation);
    return new AsmAnnotationVisitor(annotation);
  }

  @Override
  public AnnotationVisitor visitTypeAnnotation(
      int typeRef, TypePath typePath, String descriptor, boolean visible) {
    var typeReference = new TypeReference(typeRef);
    var annotation = TypeUtils.annotationFromDescriptor(descriptor);
    TypeUsage.ReferredType startingType = null;
    switch (typeReference.getSort()) {
      case TypeReference.CLASS_TYPE_PARAMETER:
        {
          var index = typeReference.getTypeParameterIndex();
          peekVisiting().typeParams.get(index).annotations.add(annotation);
          break;
        }
      case TypeReference.CLASS_TYPE_PARAMETER_BOUND:
        {
          var typeParamIndex = typeReference.getTypeParameterIndex();
          var index = typeReference.getTypeParameterBoundIndex();
          startingType = peekVisiting().typeParams.get(typeParamIndex).bounds.get(index).type;
          break;
        }
      case TypeReference.CLASS_EXTENDS:
        {
          var index = typeReference.getSuperTypeIndex();
          if (index == -1) {
            startingType = peekVisiting().superclass.type;
          } else {
            startingType = peekVisiting().interfaces.get(index).type;
          }
          break;
        }
    }
    if (startingType != null) {
      TypeUtils.moveToTypePath(startingType, typePath).annotations.add(annotation);
    }
    return super.visitTypeAnnotation(typeRef, typePath, descriptor, visible);
  }

  @Override
  public void visitEnd() {
    var classToAdd = popVisiting();
    visited.put(classToAdd.binaryName, classToAdd);
    super.visitEnd();
  }

  private ClassDecl peekVisiting() {
    try {
      return visiting.peek();
    } catch (EmptyStackException e) {
      throw new SkipException("Error: stack was empty when visitEnd was called.");
    }
  }

  private ClassDecl popVisiting() {
    try {
      return visiting.pop();
    } catch (EmptyStackException e) {
      throw new SkipException("Error: stack was empty when visitEnd was called.");
    }
  }
}
