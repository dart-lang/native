// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../config/config.dart';
import '../elements/elements.dart';
import 'visitor.dart';

/// A [Visitor] that identifies which excluded classes should be generated as
/// stubs.
///
/// A class is a stub if it is excluded but referenced by an included class.
class StubCollector extends Visitor<Classes, void> with TopLevelVisitor {
  @override
  final GenerationStage stage = GenerationStage.stubCollector;

  final Config config;

  StubCollector(this.config);

  @override
  void visit(Classes node) {
    if (!config.generateStubs) {
      node.decls.removeWhere((binaryName, classDecl) => classDecl.isExcluded);
      return;
    }
    final stubFinder = _StubFinder();
    for (final classDecl in node.decls.values) {
      if (!classDecl.isExcluded) {
        classDecl.accept(stubFinder);
      }
    }

    // Mark collected classes as stubs and remove other excluded classes.
    node.decls.removeWhere((binaryName, classDecl) {
      if (classDecl.isExcluded) {
        if (stubFinder.referencedExcludedClasses.contains(classDecl)) {
          classDecl.isStub = true;
          return false;
        }
        return true;
      }
      return false;
    });
  }
}

class _StubFinder extends Visitor<ClassDecl, void> {
  final Set<ClassDecl> referencedExcludedClasses = {};
  final _TypeStubFinder typeStubFinder;

  _StubFinder() : typeStubFinder = _TypeStubFinder();

  @override
  void visit(ClassDecl node) {
    typeStubFinder.finder = this;

    node.superclass?.accept(typeStubFinder);
    for (final interface in node.interfaces) {
      interface.accept(typeStubFinder);
    }

    for (final method in node.methods) {
      method.returnType.accept(typeStubFinder);
      for (final param in method.params) {
        param.type.accept(typeStubFinder);
      }
    }

    for (final field in node.fields) {
      field.type.accept(typeStubFinder);
    }
  }
}

class _TypeStubFinder extends TypeVisitor<void> {
  late _StubFinder finder;

  @override
  void visitDeclaredType(DeclaredType node) {
    if (node.classDecl.isExcluded) {
      finder.referencedExcludedClasses.add(node.classDecl);
    }
    for (final param in node.params) {
      param.accept(this);
    }
  }

  @override
  void visitArrayType(ArrayType node) {
    node.elementType.accept(this);
  }

  @override
  void visitWildcard(Wildcard node) {
    node.extendsBound?.accept(this);
    node.superBound?.accept(this);
  }

  @override
  void visitTypeVar(TypeVar node) {
    // Type variables are not classes.
  }

  @override
  void visitPrimitiveType(PrimitiveType node) {
    // Primitive types are not classes.
  }

  @override
  void visitNonPrimitiveType(ReferredType node) {
    // Fallback for other referred types.
  }
}
