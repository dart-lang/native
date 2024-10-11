// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'transformer.dart';
export 'transformer.dart';

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
///     nullableChild = transformer.transformNullable(nullableChild);
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
///   Foo transformFoo(Foo node) {
///     // Typically this method would transform the children, but that's not
///     // always what you want to do.
///     node.transformChildren(this);
///
///     // The rest of this method can edit the node in-place and return it, or
///     // construct a new node and return that instead.
///     return node;
///   }
///   ```
/// 3. If you want to transform `Foo` specifically, but there's no
///    `transformFoo` method to override, add a `transformFoo` method to
///    [Transformation]. Assuming `Foo` extends `Bar`, `transformFoo` should
///    delegate to `transformBar`:
///   `Foo transformFoo(Foo node) => transformBar(node) as Foo;`
/// 4. Then add a `transform` method to `Foo` that invokes `transformFoo`:
///   ```dart
///   @override
///   AstNode transform(Transformation transformation) =>
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
  /// method that is specific to this type of node.
  ///
  /// This method should be implemented for a particular type of [AstNode] when
  /// there are [Transformation]s that need to transform that type specifically.
  AstNode transform(Transformation transformation) =>
      transformation.transformAstNode(this);

  /// Transform this node's children. This is the method that actually
  /// understands the structure of the node. It should invoke
  /// [Transformer.transform] etc on all the node's children.
  ///
  /// This method must be implemented if the node has children. The
  /// implementation should call `super.transformChildren(transformer);`.
  void transformChildren(Transformer transformer) {}
}
