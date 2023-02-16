// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.apisummarizer.disasm;

import com.github.dart_lang.jnigen.apisummarizer.elements.TypeUsage;
import java.util.ArrayList;
import org.objectweb.asm.signature.SignatureVisitor;

public class AsmTypeUsageSignatureVisitor extends SignatureVisitor {
  private final TypeUsage typeUsage;

  public AsmTypeUsageSignatureVisitor(TypeUsage typeUsage) {
    super(AsmConstants.API);
    this.typeUsage = typeUsage;
  }

  @Override
  public void visitBaseType(char descriptor) {
    typeUsage.kind = TypeUsage.Kind.PRIMITIVE;
    var name = "";
    switch (descriptor) {
      case 'Z':
        name = "boolean";
        break;
      case 'B':
        name = "byte";
        break;
      case 'C':
        name = "char";
        break;
      case 'D':
        name = "double";
        break;
      case 'F':
        name = "float";
        break;
      case 'I':
        name = "int";
        break;
      case 'J':
        name = "long";
        break;
      case 'L':
        name = "object";
        break;
      case 'S':
        name = "short";
        break;
      case 'V':
        name = "void";
        break;
    }
    typeUsage.shorthand = name;
    typeUsage.type = new TypeUsage.PrimitiveType(name);
  }

  @Override
  public SignatureVisitor visitArrayType() {
    typeUsage.kind = TypeUsage.Kind.ARRAY;
    typeUsage.shorthand = "java.lang.Object[]";
    var elementType = new TypeUsage();
    typeUsage.type = new TypeUsage.Array(elementType);
    return new AsmTypeUsageSignatureVisitor(elementType);
  }

  @Override
  public void visitTypeVariable(String name) {
    typeUsage.kind = TypeUsage.Kind.TYPE_VARIABLE;
    typeUsage.shorthand = name;
    typeUsage.type = new TypeUsage.TypeVar(name);
  }

  @Override
  public void visitClassType(String name) {
    typeUsage.kind = TypeUsage.Kind.DECLARED;
    typeUsage.shorthand = name.substring(0, name.length()).replace('/', '.');
    var components = name.split("[/$]");
    var simpleName = components[components.length - 1];
    typeUsage.type = new TypeUsage.DeclaredType(typeUsage.shorthand, simpleName, new ArrayList<>());
  }

  @Override
  public SignatureVisitor visitTypeArgument(char wildcard) {
    // TODO(#141) support wildcards
    // TODO(#144) support extend/super clauses
    assert (typeUsage.type instanceof TypeUsage.DeclaredType);
    var typeArg = new TypeUsage();
    ((TypeUsage.DeclaredType) typeUsage.type).params.add(typeArg);
    return new AsmTypeUsageSignatureVisitor(typeArg);
  }

  @Override
  public void visitInnerClassType(String name) {
    super.visitInnerClassType(name);
    // TODO(#139) support nested generic classes
  }
}
