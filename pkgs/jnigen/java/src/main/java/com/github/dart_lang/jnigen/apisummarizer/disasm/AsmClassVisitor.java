// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.apisummarizer.disasm;

import com.github.dart_lang.jnigen.apisummarizer.elements.*;
import com.github.dart_lang.jnigen.apisummarizer.util.SkipException;
import com.github.dart_lang.jnigen.apisummarizer.util.StreamUtil;
import java.util.*;
import java.util.stream.Collectors;
import org.objectweb.asm.*;
import org.objectweb.asm.signature.SignatureReader;

public class AsmClassVisitor extends ClassVisitor implements AsmAnnotatedElementVisitor {
  private static Param param(
      Type type, String name, @SuppressWarnings("SameParameterValue") String signature) {
    var param = new Param();
    param.name = name;
    param.type = TypeUtils.typeUsage(type, signature);
    return param;
  }

  public List<ClassDecl> getVisited() {
    return visited;
  }

  List<ClassDecl> visited = new ArrayList<>();
  Stack<ClassDecl> visiting = new Stack<>();

  /// Actual access for the inner classes as originally defined.
  Map<String, Integer> actualAccess = new HashMap<>();

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
    var type = Type.getObjectType(name);
    current.binaryName = name.replace('/', '.');
    current.modifiers = TypeUtils.access(actualAccess.getOrDefault(current.binaryName, access));
    current.declKind = TypeUtils.declKind(access);
    current.superclass = TypeUtils.typeUsage(Type.getObjectType(superName), null);
    current.interfaces =
        StreamUtil.map(interfaces, i -> TypeUtils.typeUsage(Type.getObjectType(i), null));
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
    var alreadyVisitedInnerClass =
        visited.stream()
            .filter(decl -> decl.binaryName.equals(binaryName))
            .collect(Collectors.toList());
    // If the order of visit is outer first inner second.
    // We still want to correct the modifiers.
    if (!alreadyVisitedInnerClass.isEmpty()) {
      alreadyVisitedInnerClass.get(0).modifiers = TypeUtils.access(access);
    }
  }

  @Override
  public FieldVisitor visitField(
      int access, String name, String descriptor, String signature, Object value) {
    if (name.contains("$")) {
      return null;
    }

    var field = new Field();
    field.name = name;
    field.type = TypeUtils.typeUsage(Type.getType(descriptor), signature);
    field.defaultValue = value;
    field.modifiers = TypeUtils.access(access);
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
      params.add(param(pt, paramName, null));
    }
    method.returnType = TypeUtils.typeUsage(type.getReturnType(), signature);
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
    return super.visitAnnotation(descriptor, visible);
  }

  @Override
  public void addAnnotation(JavaAnnotation annotation) {
    peekVisiting().annotations.add(annotation);
  }

  @Override
  public AnnotationVisitor visitAnnotationDefault(String descriptor, boolean visible) {
    return super.visitAnnotation(descriptor, visible);
  }

  @Override
  public AnnotationVisitor visitTypeAnnotation(
      int typeRef, TypePath typePath, String descriptor, boolean visible) {
    return super.visitTypeAnnotation(typeRef, typePath, descriptor, visible);
  }

  @Override
  public void visitEnd() {
    visited.add(popVisiting());
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
