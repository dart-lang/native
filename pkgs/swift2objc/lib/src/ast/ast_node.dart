// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../visitor/visitor.dart';
export '../visitor/visitor.dart';

/// Base interface of all AST nodes, including types, bindings, and other
/// elements.
///
/// Anything that we might want to visit should be an [AstNode]. Most things
/// that contain [AstNode]s should also be [AstNode]s (except for top level
/// objects like `Library` that are in charge of running the visitors, or
/// caching objects like `BindingsIndex` or `Writer`).
///
/// The AST and visitor infrastucture is pretty complicated, so here are the
/// common tasks you might need to do as a maintainer:
///
/// ## Creating a new type of [AstNode]
///
/// For example, adding a class `Foo` which extends `Bar`, which somewhere up
/// the heirarchy extends [AstNode]:
///
/// 1. Write your `Foo` class and extend `Bar`.
/// 2. If `Foo` has children (ie fields that are [AstNode]s), override the
///    `visitChildren` method. Make sure to call `super.visitChildren`
///    so that `Bar`'s children are also visited. If all `Foo`'s children
///    are inherited from `Bar`, it's not necessary to implement this method.
///   ```dart
///   @override
///   void visitChildren(Visitor visitor) {
///     super.visitChildren(visitor);
///     visitor.visit(myChild);
///     visitor.visitAll(myChildList);
///   }
///   ```
///
/// Since there are many AstNodes that no one is ever going to need to visit,
/// we're using a lazy-loading policy for the `visitFoo` method. When someone
/// wants to write a [Visitation] that is specific to `Foo` (ie not covered by
/// `visitBar`), that's when the `visitFoo` function will be added.
///
/// The steps are essentially the same to change an existing class to extend
/// [AstNode].
///
/// ## Creating a new [Visitation]
///
/// 1. Write the visitation as a class that extends [Visitation]. The class may
///    be stateful, but shouldn't care about the order that nodes are visited.
///    This class may mutate the nodes, but shouldn't assume that all children
///    have finished being visited when processing the parent.
/// 2. Override the visit methods for whichever type you're interested in.
///   ```dart
///   @override
///   void visitFoo(Foo node) {
///     // Typically this method would visit the children, but that's not always
///     // what you want to do.
///     node.visitChildren(this);
///
///     // It's not necessarily true that all the children have finished being
///     // visited at this point.
///
///     // The rest of this method can edit the node in-place.
///   }
///   ```
/// 3. If you want to visit `Foo` specifically (and not its supertypes), but
///    there's no `visitFoo` method to override, add a `visitFoo` method to
///    [Visitation]. Assuming `Foo` extends `Bar`, `visitFoo` should delegate to
///    `visitBar`:
///   `void visitFoo(Foo node) => visitBar(node);`
/// 4. Then add a `visit` method to `Foo` that invokes `visitFoo`:
///   ```dart
///   @override
///   void visit(Visitation visitation) => visitation.visitFoo(this);
///   ```
/// 5. Repeat 3 and 4 for `Bar` and any other supertypes as necessary.
///
/// ## Running a [Visitation]
///
/// 1. Construct the [Visitation] and wrap it in a [Visitor]:
///   `final visitor = Visitor(MyFancyVisitation(1, 2, 3));`
/// 2. Invoke the [Visitor] on the root nodes of the AST:
///   ```dart
///   visitor.visit(someRootNode);
///   visitor.visitAll(listOfRootNodes);
///   ```
abstract class AstNode {
  const AstNode();

  /// Visit this node. All this method does is delegate to the visit method that
  /// is specific to this type of node.
  ///
  /// This method should be implemented for a particular type of [AstNode] only
  /// when there are [Visitation]s that need to visit that type specifically.
  void visit(Visitation visitation) => visitation.visitAstNode(this);

  /// Visit this node's children. This is the method that actually understands
  /// the structure of the node. It should invoke [Visitor.visit] etc on all the
  /// node's children.
  ///
  /// This method must be implemented if the node has children. The
  /// implementation should call `super.visitChildren(visitor);`.
  void visitChildren(Visitor visitor) {}
}
