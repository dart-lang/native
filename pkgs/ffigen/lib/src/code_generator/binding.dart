// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'ast.dart';
import 'binding_string.dart';
import 'writer.dart';

/// Base class for all Bindings.
///
/// Do not extend directly, use [LookUpBinding] or [NoLookUpBinding].
abstract class Binding extends AstNode {
  /// Holds the Unified Symbol Resolution string obtained from libclang.
  final String usr;

  /// The name as it was in C.
  final String originalName;

  /// Binding name to generate, may get changed to resolve name conflicts.
  String name;

  final String? dartDoc;
  final bool isInternal;

  Binding({
    required this.usr,
    required this.originalName,
    required this.name,
    this.dartDoc,
    this.isInternal = false,
  });

  /// Get all dependencies, including itself and save them in [dependencies].
  void addDependencies(Set<Binding> dependencies);

  /// Converts a Binding to its actual string representation.
  ///
  /// Note: This does not print the typedef dependencies.
  /// Must call getTypedefDependencies first.
  BindingString toBindingString(Writer w);

  /// Returns the Objective C bindings, if any.
  BindingString? toObjCBindingString(Writer w) => null;

  /// Sort members of this binding, if possible. For example, sort the methods
  /// of a ObjCInterface.
  void sort() {}

  /// Whether these bindings should be generated.
  bool get generateBindings => true;

  @override
  AstNode? transform(Transformation transformation) =>
      transformation.transformBinding(this);
}

/// Base class for bindings which look up symbols in dynamic library.
abstract class LookUpBinding extends Binding {
  LookUpBinding({
    String? usr,
    String? originalName,
    required super.name,
    super.dartDoc,
    super.isInternal,
  }) : super(
          usr: usr ?? name,
          originalName: originalName ?? name,
        );

  @override
  AstNode? transform(Transformation transformation) =>
      transformation.transformLookUpBinding(this);
}

/// Base class for bindings which don't look up symbols in dynamic library.
abstract class NoLookUpBinding extends Binding {
  NoLookUpBinding({
    String? usr,
    String? originalName,
    required super.name,
    super.dartDoc,
    super.isInternal,
  }) : super(
          usr: usr ?? name,
          originalName: originalName ?? name,
        );

  @override
  AstNode? transform(Transformation transformation) =>
      transformation.transformNoLookUpBinding(this);
}
