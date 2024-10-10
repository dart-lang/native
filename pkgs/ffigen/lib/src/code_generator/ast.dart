// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

import '../code_generator.dart';

/// Base interface of all AST nodes, including types, bindings, and other
/// elements.
///
/// Anything that we might want to transform should be an [AstNode]. Most things
/// that contain [AstNode]s should also be [AstNode]s (except for top level
/// objects like `Library` that are in charge of running the transformers, or
/// caching objects like `BindingsIndex` or `Writer`).
///
/// The AST and transformer infrastucture is pretty complicated, so here are the
/// common tasks you might need to do as a maintainer:
///
/// ## Creating a new type of [AstNode]
///
/// For example, adding a class `Foo` which extends `Bar`, which somewhere up
/// the heirarchy extends [AstNode]:
///
/// 1. Write your `Foo` class and extend `Bar`.
/// 2. If `Foo` has children (ie fields that are [AstNode]s), also add a
///    `transformChildren` method. Make sure to call `super.transformChildren`
///    so that `Bar`'s children are also transformed. If all `Foo`'s children
///    are inherited from `Bar`, it's not necessary to implement this method.
///   ```dart
///   @override
///   void transformChildren(Transformer transformer) {
///     super.transformChildren(transformer);
///     myChild = transformer.transform(myChild);
///     nonNullChild = transformer.transformNonNull(nonNullChild);
///     transformer.transformList(myChildList);
///   }
///   ```
///
/// Since there are many AstNodes that no one is ever going to need to
/// transform, we're using a lazy-loading policy for the `transformFoo` method.
/// When someone wants to write a [Transformation] that is specific to `Foo`,
/// that's when the `transformFoo` function will be added.
///
/// The steps are essentially the same to change an existing class to extend
/// [AstNode].
///
/// ## Creating a new [Transformation]
///
/// 1. Write the transformation as a class that extends [Transformation]. The
///    class may be stateful, but shouldn't care about the order that nodes are
///    transformed.
/// 2. Override the transform methods for whichever type you're interested in.
///   ```dart
///   @override
///   Foo? transformFoo(Foo node) {
///     // Typically this method would transform the children, but that's not
///     // always what you want to do.
///     node.transformChildren(this);
///
///     // The rest of this method can edit the node in-place and return it, or
///     // construct a new node and return that instead. It can also return null
///     // if the node should be deleted.
///     return node;
///   }
///   ```
/// 3. If you want to transform `Foo` specifically, but there's no
///    `transformFoo` method to override, add a `transformFoo` method to
///    [Transformation]. Assuming `Foo` extends `Bar`, `transformFoo` should
///    delegate to `transformBar`:
///   `Foo? transformFoo(Foo node) => transformBar(node) as Foo?;`
/// 4. Then add a `transform` method to `Foo` that invokes `transformFoo`:
///   ```dart
///   @override
///   AstNode? transform(Transformation transformation) =>
///       transformation.transformFoo(this);
///   ```
/// 5. Repeat 3 and 4 for `Bar` and any other ancestors as necessary.
///
/// ## Running a [Transformation]
///
/// 1. Construct the [Transformation] and wrap it in a [Transformer]:
///   `final transformer = Transformer(MyFancyTransformation(1, 2, 3));`
/// 2. Invoke the [Transformer] on the root nodes of the AST:
///   ```dart
///   someRootNode = transformer.transform(someRootNode);
///   transformer.transformList(listOfRootNodes);
///   ```
abstract class AstNode {
  const AstNode();

  /// Transform this node. All this method does is delegate to the transform
  /// method on the [Transformation] that is specific to this type of node.
  ///
  /// This method should be implemented for a particular type of [AstNode] when
  /// there are [Transformation]s that need to transform that type specifically.
  AstNode? transform(Transformation transformation,
          {required bool mustReturnNonNull}) =>
      transformation.transformAstNode(this,
          mustReturnNonNull: mustReturnNonNull);

  /// Transform this node's children. This is the method that actually
  /// understands the structure of the node. It should invoke
  /// [Transformer.transform] or [Transformer.transformList] on all the node's
  /// children.
  ///
  /// This method must be implemented if the node has children.
  void transformChildren(Transformer transformer) {}
}

/// Wrapper around [Transformation] to be used by callers.
final class Transformer {
  Transformer(this._transformation) {
    _transformation._transformer = this;
  }

  final Transformation _transformation;
  final _seen = <(AstNode, bool), AstNode?>{};

  T? _transform<T extends AstNode>(T node, {required bool mustReturnNonNull}) {
    final key = (node, mustReturnNonNull);
    if (_seen.containsKey(key)) return _seen[key] as T?;
    final result =
        node.transform(_transformation, mustReturnNonNull: mustReturnNonNull);
    _seen[key] = result;
    if (result != null) {
      _seen[(result, mustReturnNonNull)] = result; // For idempotence.
    }
    return result as T?;
  }

  /// Transform a node. This is the main entrypoint for the transformation.
  ///
  /// Returns the result of the transformation, which may be a new node, or the
  /// same node. Returns null if the node is to be deleted. Callers are
  /// responsible for handling this case sensibly.
  ///
  /// Usage: `myNode = transformer.transform(myNode);`
  T? transform<T extends AstNode>(T? node) =>
      node == null ? null : _transform(node, mustReturnNonNull: false);

  T transformNonNull<T extends AstNode>(T node) =>
      _transform(node, mustReturnNonNull: true)!;

  /// Helper method for transforming a list of nodes.
  ///
  /// Replaces the contents of the list with the non-null transformed nodes.
  ///
  /// Usage: `transformer.transformList(myList);`
  void transformList<T extends AstNode>(List<T> nodeList) {
    final result = nodeList.map(transform).nonNulls.toList();
    nodeList.clear();
    nodeList.addAll(result);
  }
}

/// Base class for all AST transformations.
///
/// Callers should wrap their [Transformation] in a [Transformer] and invoke
/// its methods, instead of interacting directly with the [Transformation].
///
/// The set of `transformFoo` methods in this class should generally reflect the
/// inheritance heirarchy of all AstNodes. Eg `transformChild` should default
/// to calling `transformBase` which should default to calling
/// `transformAstNode`.
///
/// Implementers should implement the specific transform methods for each node
/// type they care about. Any transform methods not implemented will default to
/// calling `node.transformChildren`, which transforms the node's children but
/// otherwise doesn't alter the node itself.
abstract class Transformation {
  late final Transformer _transformer;

  Type? transformType(Type node, {required bool mustReturnNonNull}) =>
      transformAstNode(node, mustReturnNonNull: mustReturnNonNull) as Type?;

  BindingType? transformBindingType(BindingType node,
          {required bool mustReturnNonNull}) =>
      transformType(node, mustReturnNonNull: mustReturnNonNull) as BindingType?;

  Binding? transformBinding(Binding node, {required bool mustReturnNonNull}) =>
      transformAstNode(node, mustReturnNonNull: mustReturnNonNull) as Binding?;

  LookUpBinding? transformLookUpBinding(LookUpBinding node,
          {required bool mustReturnNonNull}) =>
      transformBinding(node, mustReturnNonNull: mustReturnNonNull)
          as LookUpBinding?;

  NoLookUpBinding? transformNoLookUpBinding(NoLookUpBinding node,
          {required bool mustReturnNonNull}) =>
      transformBinding(node, mustReturnNonNull: mustReturnNonNull)
          as NoLookUpBinding?;

  NoLookUpBinding? transformLibraryImport(NoLookUpBinding node,
          {required bool mustReturnNonNull}) =>
      transformBinding(node, mustReturnNonNull: mustReturnNonNull)
          as NoLookUpBinding?;

  /// Default behavior for all transform methods.
  AstNode? transformAstNode(AstNode node, {required bool mustReturnNonNull}) =>
      node..transformChildren(_transformer);
}
