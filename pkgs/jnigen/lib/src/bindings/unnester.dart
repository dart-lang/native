// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../elements/elements.dart';
import 'visitor.dart';

/// A [Visitor] that processes nested classes.
///
/// Nested classes are not supported in Dart. So this "unnests" them into
/// separate classes.
class Unnester extends Visitor<Classes, void> {
  const Unnester();

  @override
  void visit(Classes node) {
    final classProcessor = _ClassUnnester();
    for (final classDecl in node.decls.values) {
      classDecl.accept(classProcessor);
    }
  }
}

class _ClassUnnester extends Visitor<ClassDecl, void> {
  final processed = <ClassDecl>{};

  @override
  void visit(ClassDecl node) {
    if (processed.contains(node)) return;
    processed.add(node);
    // We need to visit the ancestors first.
    node.parent?.accept(this);

    // Add type params of outer classes to the nested classes.
    final allTypeParams = <TypeParam>[];
    if (!node.isStatic) {
      allTypeParams.addAll(node.parent?.allTypeParams ?? []);
    }
    allTypeParams.addAll(node.typeParams);
    node.allTypeParams = allTypeParams;

    if (node.isNested && !node.isStatic) {
      const methodProcessor = _MethodUnnester();
      for (final method in node.methods) {
        method.accept(methodProcessor);
      }
    }
  }
}

class _MethodUnnester extends Visitor<Method, void> {
  const _MethodUnnester();

  @override
  void visit(Method node) {
    assert(!node.classDecl.isStatic);
    assert(node.classDecl.isNested);
    // TODO(#319): Unnest the methods in APISummarizer itself.
    // For now the nullity of [node.descriptor] identifies if the doclet
    // backend was used and the method would potentially need "unnesting".
    if ((node.isCtor || node.isStatic) && node.descriptor == null) {
      // Non-static nested classes take an instance of their outer class as the
      // first parameter.
      //
      // This is not accounted for by the **doclet** summarizer, so we
      // manually add it as the first parameter.
      final parentTypeParamCount = node.classDecl.allTypeParams.length -
          node.classDecl.typeParams.length;
      final parentTypeParams = [
        for (final typeParam
            in node.classDecl.allTypeParams.take(parentTypeParamCount)) ...[
          TypeUsage(
              shorthand: typeParam.name, kind: Kind.typeVariable, typeJson: {})
            ..type = TypeVar(name: typeParam.name),
        ]
      ];
      final parentType = DeclaredType(
        binaryName: node.classDecl.parent!.binaryName,
        params: parentTypeParams,
      )..classDecl = node.classDecl.parent!;
      final parentTypeUsage = TypeUsage(
          shorthand: parentType.binaryName, kind: Kind.declared, typeJson: {})
        ..type = parentType;
      final param = Param(name: '\$parent', type: parentTypeUsage);
      // Make the list modifiable.
      if (node.params.isEmpty) node.params = [];
      node.params.insert(0, param);
    }
  }
}
