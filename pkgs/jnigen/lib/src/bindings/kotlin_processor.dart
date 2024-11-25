// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../elements/elements.dart';
import 'visitor.dart';

/// A [Visitor] that adds the the information from Kotlin's metadata to the Java
/// classes and methods.
class KotlinProcessor extends Visitor<Classes, void> {
  @override
  void visit(Classes node) {
    final classProcessor = _KotlinClassProcessor();
    for (final classDecl in node.decls.values) {
      classDecl.accept(classProcessor);
    }
  }
}

class _KotlinClassProcessor extends Visitor<ClassDecl, void> {
  @override
  void visit(ClassDecl node) {
    if (node.kotlinClass == null && node.kotlinPackage == null) {
      return;
    }
    // This [ClassDecl] is actually a Kotlin class.
    // Matching methods and functions from the metadata.
    final functions = <String, KotlinFunction>{};
    final kotlinFunctions =
        (node.kotlinClass?.functions ?? node.kotlinPackage?.functions)!;
    for (final function in kotlinFunctions) {
      final signature = function.name + function.descriptor;
      functions[signature] = function;
    }
    for (final method in node.methods) {
      final signature = method.name + method.descriptor!;
      if (functions.containsKey(signature)) {
        method.accept(_KotlinMethodProcessor(functions[signature]!));
      }
    }
  }
}

class _KotlinMethodProcessor extends Visitor<Method, void> {
  final KotlinFunction function;

  _KotlinMethodProcessor(this.function);

  @override
  void visit(Method node) {
    if (function.isSuspend) {
      const kotlinContinutationType = 'kotlin.coroutines.Continuation';
      assert(node.params.isNotEmpty &&
          node.params.last.type.kind == Kind.declared &&
          node.params.last.type.name == kotlinContinutationType);
      var continuationType =
          (node.params.last.type.type as DeclaredType).params.firstOrNull;
      if (continuationType != null &&
          continuationType.kind == Kind.wildcard &&
          (continuationType.type as Wildcard).superBound != null) {
        continuationType = (continuationType.type as Wildcard).superBound!;
      }
      node.asyncReturnType = continuationType == null
          ? TypeUsage.object
          : continuationType.clone();
    }
  }
}
