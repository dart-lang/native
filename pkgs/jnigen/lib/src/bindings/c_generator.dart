// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../elements/elements.dart';
import 'visitor.dart';

/// JVM representation of type signatures.
///
/// https://docs.oracle.com/en/java/javase/18/docs/specs/jni/types.html#type-signatures
class Descriptor extends TypeVisitor<String> {
  const Descriptor();

  @override
  String visitArrayType(ArrayType node) {
    final inner = node.type.accept(this);
    return '[$inner';
  }

  @override
  String visitDeclaredType(DeclaredType node) {
    final internalName = node.binaryName.replaceAll('.', '/');
    return 'L$internalName;';
  }

  @override
  String visitPrimitiveType(PrimitiveType node) {
    return node.signature;
  }

  @override
  String visitTypeVar(TypeVar node) {
    // It should be possible to compute the erasure of a type
    // in parser itself.
    // TODO(#23): Use erasure of the type variable here.
    // This is just a (wrong) placeholder
    return super.visitTypeVar(node);
  }

  @override
  String visitWildcard(Wildcard node) {
    final extendsBound = node.extendsBound?.accept(this);
    return extendsBound ?? 'Ljava/lang/Object;';
  }

  @override
  String visitNonPrimitiveType(ReferredType node) {
    return "Ljava/lang/Object;";
  }
}

/// Generates JNI Method signatures.
///
/// https://docs.oracle.com/en/java/javase/18/docs/specs/jni/types.html#type-signatures
/// Also see: [Descriptor]
class MethodSignature extends Visitor<Method, String> {
  const MethodSignature();

  @override
  String visit(Method node) {
    final s = StringBuffer();
    s.write('(');
    s.write(node.params
        .map((param) => param.type)
        .accept(const Descriptor())
        .join());
    s.write(')');
    final returnType = node.returnType.accept(const Descriptor());
    s.write(returnType);
    return s.toString();
  }
}

class CFieldName extends Visitor<Field, String> {
  const CFieldName();

  @override
  String visit(Field node) {
    final className = node.classDecl.uniqueName;
    final fieldName = node.finalName;
    return '${className}__$fieldName';
  }
}

class CMethodName extends Visitor<Method, String> {
  const CMethodName();

  @override
  String visit(Method node) {
    final className = node.classDecl.uniqueName;
    final methodName = node.finalName;
    return '${className}__$methodName';
  }
}
