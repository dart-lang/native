// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.apisummarizer.disasm;

import static org.objectweb.asm.Opcodes.*;
import static org.objectweb.asm.Type.ARRAY;
import static org.objectweb.asm.Type.OBJECT;

import com.github.dart_lang.jnigen.apisummarizer.elements.DeclKind;
import com.github.dart_lang.jnigen.apisummarizer.elements.JavaAnnotation;
import com.github.dart_lang.jnigen.apisummarizer.elements.TypeUsage;
import com.github.dart_lang.jnigen.apisummarizer.util.SkipException;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import org.objectweb.asm.Type;
import org.objectweb.asm.TypePath;

class TypeUtils {

  public static String simpleName(Type type) {
    var internalName = type.getInternalName();
    if (type.getInternalName().length() == 1) {
      return type.getClassName();
    }
    var components = internalName.split("[/$]");
    if (components.length == 0) {
      throw new SkipException("Cannot derive simple name: " + internalName);
    }
    return components[components.length - 1];
  }

  public static TypeUsage typeUsage(Type type) {
    var usage = new TypeUsage();
    usage.shorthand = type.getClassName();
    switch (type.getSort()) {
      case OBJECT:
        usage.kind = TypeUsage.Kind.DECLARED;
        usage.type =
            new TypeUsage.DeclaredType(
                type.getInternalName().replace('/', '.'), TypeUtils.simpleName(type), null);
        break;
      case ARRAY:
        usage.kind = TypeUsage.Kind.ARRAY;
        usage.type = new TypeUsage.Array(TypeUtils.typeUsage(type.getElementType()));
        break;
      default:
        usage.kind = TypeUsage.Kind.PRIMITIVE;
        usage.type = new TypeUsage.PrimitiveType(type.getClassName());
    }
    return usage;
  }

  public static Set<String> access(int access) {
    var result = new HashSet<String>();
    for (var ac : acc.entrySet()) {
      if ((ac.getValue() & access) != 0) {
        result.add(ac.getKey());
      }
    }
    return result;
  }

  private static final Map<String, Integer> acc = new HashMap<>();

  static {
    // TODO(https://github.com/dart-lang/native/issues/1079): Once we're no longer using doclet,
    // send the bitmask instead.
    acc.put("static", ACC_STATIC);
    acc.put("private", ACC_PRIVATE);
    acc.put("protected", ACC_PROTECTED);
    acc.put("public", ACC_PUBLIC);
    acc.put("abstract", ACC_ABSTRACT);
    acc.put("final", ACC_FINAL);
    acc.put("native", ACC_NATIVE);
    acc.put("bridge", ACC_BRIDGE);
    acc.put("synthetic", ACC_SYNTHETIC);
  }

  static JavaAnnotation annotationFromDescriptor(String descriptor) {
    var annotation = new JavaAnnotation();
    var aType = Type.getType(descriptor);
    annotation.binaryName = aType.getClassName();
    return annotation;
  }

  static DeclKind declKind(int access) {
    if ((access & ACC_ENUM) != 0) return DeclKind.ENUM;
    if ((access & ACC_INTERFACE) != 0) return DeclKind.INTERFACE;
    if ((access & ACC_ANNOTATION) != 0) return DeclKind.ANNOTATION_TYPE;
    return DeclKind.CLASS;
  }

  static String defaultParamName(Type type) {
    switch (type.getSort()) {
      case ARRAY:
        return defaultParamName(type.getElementType()) + 's';
      case OBJECT:
        return unCapitalize(simpleName(type));
      case Type.METHOD:
        throw new SkipException("unexpected method type" + type);
      default: // Primitive type
        var typeCh = type.getInternalName().charAt(0);
        return String.valueOf(Character.toLowerCase(typeCh));
    }
  }

  static TypeUsage.ReferredType moveToTypePath(
      TypeUsage.ReferredType startingType, TypePath typePath) {
    if (typePath == null) {
      return startingType;
    }
    var currentType = startingType;
    int nestingLevel = 0;
    for (int i = 0; i < typePath.getLength(); ++i) {
      var step = typePath.getStep(i);
      switch (step) {
        case TypePath.ARRAY_ELEMENT:
          {
            currentType = ((TypeUsage.Array) currentType).elementType.type;
            nestingLevel = 0;
            break;
          }
        case TypePath.INNER_TYPE:
          {
            ++nestingLevel;
            break;
          }
        case TypePath.WILDCARD_BOUND:
          {
            var wildcard = ((TypeUsage.Wildcard) currentType);
            var extendsBound = wildcard.extendsBound;
            var superBound = wildcard.superBound;
            currentType = (extendsBound == null ? superBound : extendsBound).type;
            nestingLevel = 0;
            break;
          }
        case TypePath.TYPE_ARGUMENT:
          {
            var declared = ((TypeUsage.DeclaredType) currentType);
            var startingIndex =
                nestingLevel == 0 ? 0 : declared.typeParamIndices.get(nestingLevel - 1);
            currentType = declared.params.get(startingIndex + typePath.getStepArgument(i)).type;
            nestingLevel = 0;
            break;
          }
      }
    }
    return currentType;
  }

  private static String unCapitalize(String s) {
    var first = Character.toLowerCase(s.charAt(0));
    if (s.length() == 1) {
      return String.valueOf(first);
    }
    return first + s.substring(1);
  }
}
