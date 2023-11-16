// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.apisummarizer.disasm;

import static org.objectweb.asm.Opcodes.*;
import static org.objectweb.asm.Type.ARRAY;
import static org.objectweb.asm.Type.OBJECT;

import com.github.dart_lang.jnigen.apisummarizer.elements.DeclKind;
import com.github.dart_lang.jnigen.apisummarizer.elements.TypeUsage;
import com.github.dart_lang.jnigen.apisummarizer.util.SkipException;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import org.objectweb.asm.Type;

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

  public static TypeUsage typeUsage(Type type, @SuppressWarnings("unused") String signature) {
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
        usage.type = new TypeUsage.Array(TypeUtils.typeUsage(type.getElementType(), null));
        break;
      default:
        usage.kind = TypeUsage.Kind.PRIMITIVE;
        usage.type = new TypeUsage.PrimitiveType(type.getClassName());
    }
    // TODO(#23): generics
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
    acc.put("static", ACC_STATIC);
    acc.put("private", ACC_PRIVATE);
    acc.put("protected", ACC_PROTECTED);
    acc.put("public", ACC_PUBLIC);
    acc.put("abstract", ACC_ABSTRACT);
    acc.put("final", ACC_FINAL);
    acc.put("native", ACC_NATIVE);
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

  private static String unCapitalize(String s) {
    var first = Character.toLowerCase(s.charAt(0));
    if (s.length() == 1) {
      return String.valueOf(first);
    }
    return first + s.substring(1);
  }
}
