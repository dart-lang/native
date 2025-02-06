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
  public void visitTypeArgument() {
    assert (typeUsage.type instanceof TypeUsage.DeclaredType);
    var typeArg = new TypeUsage("?", TypeUsage.Kind.WILDCARD, new TypeUsage.Wildcard(null, null));
    ((TypeUsage.DeclaredType) typeUsage.type).params.add(typeArg);
  }

  @Override
  public SignatureVisitor visitTypeArgument(char wildcard) {
    assert (typeUsage.type instanceof TypeUsage.DeclaredType);
    var typeArg = new TypeUsage();
    typeArg.kind = TypeUsage.Kind.DECLARED;
    ((TypeUsage.DeclaredType) typeUsage.type).params.add(typeArg);
    if (wildcard != '=') {
      typeArg.kind = TypeUsage.Kind.WILDCARD;
      typeArg.type = new TypeUsage.Wildcard(null, null);
      typeArg.shorthand = "?";
      switch (wildcard) {
        case '+':
          {
            var extendsBound = new TypeUsage();
            ((TypeUsage.Wildcard) typeArg.type).extendsBound = extendsBound;
            typeArg = extendsBound;
            break;
          }
        case '-':
          {
            var superBound = new TypeUsage();
            ((TypeUsage.Wildcard) typeArg.type).superBound = superBound;
            typeArg = superBound;
            break;
          }
      }
    }
    return new AsmTypeUsageSignatureVisitor(typeArg);
  }

  @Override
  public void visitInnerClassType(String name) {
    typeUsage.shorthand += "." + name;
    var declaredType = ((TypeUsage.DeclaredType) typeUsage.type);
    declaredType.binaryName += "$" + name;
    declaredType.simpleName = name;
    declaredType.typeParamIndices.add(declaredType.params.size());
  }
}
