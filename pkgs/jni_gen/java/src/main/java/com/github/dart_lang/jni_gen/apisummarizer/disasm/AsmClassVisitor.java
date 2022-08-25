// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jni_gen.apisummarizer.disasm;

import static org.objectweb.asm.Opcodes.ACC_PROTECTED;
import static org.objectweb.asm.Opcodes.ACC_PUBLIC;

import com.github.dart_lang.jni_gen.apisummarizer.elements.*;
import com.github.dart_lang.jni_gen.apisummarizer.util.SkipException;
import com.github.dart_lang.jni_gen.apisummarizer.util.StreamUtil;
import java.util.*;
import org.objectweb.asm.*;

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
    current.binaryName = type.getClassName();
    current.modifiers = TypeUtils.access(access);
    current.parentName = TypeUtils.parentName(type);
    current.packageName = TypeUtils.packageName(type);
    current.declKind = TypeUtils.declKind(access);
    current.simpleName = TypeUtils.simpleName(type);
    current.superclass = TypeUtils.typeUsage(Type.getObjectType(superName), null);
    current.interfaces =
        StreamUtil.map(interfaces, i -> TypeUtils.typeUsage(Type.getObjectType(i), null));
    super.visit(version, access, name, signature, superName, interfaces);
  }

  private static boolean isPrivate(int access) {
    return ((access & ACC_PUBLIC) == 0) && ((access & ACC_PROTECTED) == 0);
  }

  @Override
  public FieldVisitor visitField(
      int access, String name, String descriptor, String signature, Object value) {
    if (name.contains("$") || isPrivate(access)) {
      return null;
    }
    var field = new Field();
    field.name = name;
    field.type = TypeUtils.typeUsage(Type.getType(descriptor), signature);
    field.defaultValue = value;
    field.modifiers = TypeUtils.access(access);
    peekVisiting().fields.add(field);
    return new AsmFieldVisitor(field);
  }

  @Override
  public MethodVisitor visitMethod(
      int access, String name, String descriptor, String signature, String[] exceptions) {
    var method = new Method();
    if (name.contains("$") || isPrivate(access)) {
      return null;
    }
    method.name = name;
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
    peekVisiting().methods.add(method);
    return new AsmMethodVisitor(method);
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
