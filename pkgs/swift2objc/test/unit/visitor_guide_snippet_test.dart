// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// dart format width=74

import 'package:logging/logging.dart';
import 'package:swift2objc/src/ast/ast_node.dart';
import 'package:swift2objc/src/context.dart';
import 'package:test/test.dart';

class Foo extends AstNode {
  Foo(this.myChild, this.myChildList);

  final AstNode myChild;
  final List<AstNode> myChildList;

  // snippet-start#visit_children
  @override
  void visitChildren(Visitor visitor) {
    super.visitChildren(visitor);
    visitor.visit(myChild);
    visitor.visitAll(myChildList);
  }
  // snippet-end#visit_children

  // snippet-start#visit_dispatch
  @override
  void visit(Visitation visitation) => visitation.visitFoo(this);
  // snippet-end#visit_dispatch
}

class Bar extends AstNode {}

abstract class ExampleVisitation extends Visitation {
  void visitFoo(Foo node);
}

extension on Visitation {
  void visitFoo(Foo node) => (this as ExampleVisitation).visitFoo(node);
}

class MyVisitation extends ExampleVisitation {
  final visitedNodes = <AstNode>[];

  // snippet-start#visit_foo
  @override
  void visitFoo(Foo node) {
    // Typically this method would visit the children, but that's not always
    // what you want to do.
    node.visitChildren(visitor);

    // It's not necessarily true that all the children have finished being
    // visited at this point.

    // The rest of this method can edit the node in-place.
  }
  // snippet-end#visit_foo

  @override
  void visitAstNode(AstNode node) {
    visitedNodes.add(node);
    super.visitAstNode(node);
  }
}

void runVisitor(
  Visitor visitor,
  AstNode someRootNode,
  List<AstNode> listOfRootNodes,
) {
  // snippet-start#run_visitor
  visitor.visit(someRootNode);
  visitor.visitAll(listOfRootNodes);
  // snippet-end#run_visitor
}

void main() {
  test('visitor guide snippets compile and execute', () {
    final context = Context(Logger.root);
    final visitation = MyVisitation();
    final visitor = Visitor(context, visitation);

    final child1 = Bar();
    final child2 = Bar();
    final child3 = Bar();
    final rootFoo = Foo(child1, [child2, child3]);

    final otherRoot1 = Bar();
    final otherRoot2 = Bar();

    runVisitor(visitor, rootFoo, [otherRoot1, otherRoot2]);

    expect(visitation.visitedNodes, [
      child1,
      child2,
      child3,
      otherRoot1,
      otherRoot2,
    ]);
  });
}
