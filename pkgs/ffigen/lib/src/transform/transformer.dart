// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';

import 'ast.dart';

/// Wrapper around [Transformation] to be used by callers.
final class Transformer {
  Transformer(this._transformation) {
    _transformation.transformer = this;
  }

  final Transformation _transformation;
  final _seen = <AstNode, AstNode>{};

  /// Transforms a node.
  ///
  /// Returns the result of the transformation, which may be a new node, or the
  /// same node edited in-place.
  ///
  /// Usage: `myNode = transformer.transform(myNode);`
  T transform<T extends AstNode>(T node) {
    if (_seen.containsKey(node)) return _seen[node] as T;
    final result = node.transform(_transformation) as T;
    _seen[node] = result;
    _seen[result] = result; // For idempotence.
    return result;
  }

  /// Transforms a nullable node.
  ///
  /// Returns null if and only if the node is null.
  ///
  /// Usage: `myNullableNode = transformer.transformNullable(myNullableNode);`
  T? transformNullable<T extends AstNode>(T? node) =>
      node == null ? null : transform(node);

  /// Helper method for transforming a list of nodes.
  ///
  /// Usage: `transformer.transformList(nodeList);`
  void transformList<T extends AstNode>(List<T> nodeList) {
    for (var i = 0; i < nodeList.length; ++i) {
      nodeList[i] = transform(nodeList[i]);
    }
  }

  /// Helper method for transforming a map with nodes as values.
  ///
  /// Usage: `transformer.transformMap(nodeMap);`
  void transformMap<K, V extends AstNode>(Map<K, V> nodeMap) {
    for (final k in nodeMap.keys) {
      nodeMap[k] = transform(nodeMap[k]!);
    }
  }
}

/// Base class for all AST transformations.
///
/// Callers should wrap their [Transformation] in a [Transformer] and invoke
/// its methods, instead of interacting directly with the [Transformation].
///
/// The `transformFoo` methods in this class should reflect the inheritance
/// heirarchy of all AstNodes. Eg `transformChild` should default to calling
/// `transformBase` which should default to calling `transformAstNode`.
///
/// Implementers should implement the specific transform methods for each node
/// type they care about. Any transform methods not implemented will default to
/// calling `node.transformChildren`, which transforms the node's children but
/// otherwise doesn't alter the node itself.
abstract class Transformation {
  late final Transformer transformer;

  Type transformType(Type node) => transformAstNode(node) as Type;

  BindingType transformBindingType(BindingType node) =>
      transformType(node) as BindingType;

  Binding transformBinding(Binding node) => transformAstNode(node) as Binding;

  LookUpBinding transformLookUpBinding(LookUpBinding node) =>
      transformBinding(node) as LookUpBinding;

  NoLookUpBinding transformNoLookUpBinding(NoLookUpBinding node) =>
      transformBinding(node) as NoLookUpBinding;

  NoLookUpBinding transformLibraryImport(NoLookUpBinding node) =>
      transformBinding(node) as NoLookUpBinding;

  /// Default behavior for all transform methods.
  AstNode transformAstNode(AstNode node) =>
      node..transformChildren(transformer);
}
