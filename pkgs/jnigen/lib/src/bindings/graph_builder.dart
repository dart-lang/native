// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

import 'package:path/path.dart' as p;

import '../config/config.dart';
import '../elements/elements.dart';
import '../transformers/graph.dart' as graph;
import 'visitor.dart';

/// This creates the user-facing graph used for transformations like renaming,
/// excluding, and adding extra methods.
class GraphBuilder extends ElementVisitor<Classes, graph.Bindings>
    with TopLevelVisitor {
  @override
  final stage = GenerationStage.graphBuilder;

  final Config config;

  GraphBuilder(this.config);

  @override
  graph.Bindings visit(Classes node) {
    final classes = <String, graph.Class>{};
    final visiting = <String>{};
    final classNodeBuilder = _ClassNodeBuilder(classes, visiting);
    for (final classDecl in node.decls.values) {
      if (!classes.containsKey(classDecl.binaryName)) {
        classDecl.accept(classNodeBuilder);
      }
    }
    final files = LinkedHashMap<String, graph.DartFile>(
        equals: p.equals, hashCode: p.hash);
    final fileNodeBuilder = _FileNodeBuilder(classes);
    for (final MapEntry(key: path, value: file) in node.files.entries) {
      files[path] = file.accept(fileNodeBuilder);
    }
    return graph.Bindings(node, classes, files);
  }
}

class _ClassNodeBuilder extends ElementVisitor<ClassDecl, void> {
  final Map<String, graph.Class> classes;
  final Set<String> visiting;

  _ClassNodeBuilder(this.classes, this.visiting);

  @override
  void visit(ClassDecl node) {
    // First visit the outer-class, the superclass, and the super-interfaces of
    // this class to maintain topological ordering.
    if (classes.containsKey(node.binaryName) ||
        visiting.contains(node.binaryName)) {
      return;
    }
    visiting.add(node.binaryName);
    node.outerClass?.accept(this);
    if (node.superclass case final DeclaredType superType) {
      if (!superType.classDecl.isImported) {
        superType.classDecl.accept(this);
      }
    }
    for (final interface in node.interfaces) {
      if (interface case final DeclaredType superInterface) {
        if (!superInterface.classDecl.isImported) {
          superInterface.classDecl.accept(this);
        }
      }
    }
    final properties = Map.fromEntries(node.fields
        .map((field) => MapEntry(field.name, graph.Property(field))));
    final methods = <String, graph.Method>{};
    final methodNodeBuilder = _MethodNodeBuilder();
    for (final method in node.methods) {
      methods[method.javaSig] = method.accept(methodNodeBuilder);
    }
    classes[node.binaryName] = graph.Class(node, properties, methods)
      ..enclosingClass = node.outerClassBinaryName == null
          ? null
          : classes[node.outerClassBinaryName!];
    visiting.remove(node.binaryName);
  }
}

class _FileNodeBuilder extends ElementVisitor<DartFile, graph.DartFile> {
  final Map<String, graph.Class> allClasses;

  _FileNodeBuilder(this.allClasses);

  @override
  graph.DartFile visit(DartFile node) {
    final classes = <String, graph.Class>{};
    for (final binaryName in node.classes.keys) {
      classes[binaryName] = allClasses[binaryName]!;
    }
    return graph.DartFile(node, classes);
  }
}

class _MethodNodeBuilder extends ElementVisitor<Method, graph.Method> {
  @override
  graph.Method visit(Method node) {
    final parameters = UnmodifiableListView(
        node.params.map(graph.MethodParameter.new).toList());
    return graph.Method(node, parameters);
  }
}
