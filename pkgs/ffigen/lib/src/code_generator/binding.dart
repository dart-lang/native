// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../config_provider/config_types.dart' show Declaration;
import '../visitor/ast.dart';

import 'binding_string.dart';
import 'writer.dart';

/// Base class for all Bindings.
///
/// Do not extend directly, use [LookUpBinding] or [NoLookUpBinding].
abstract class Binding extends AstNode implements Declaration {
  /// Holds the Unified Symbol Resolution string obtained from libclang.
  @override
  final String usr;

  /// The name as it was in C.
  @override
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

  @override
  void visit(Visitation visitation) => visitation.visitBinding(this);
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
  void visit(Visitation visitation) => visitation.visitLookUpBinding(this);
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
  void visit(Visitation visitation) => visitation.visitNoLookUpBinding(this);

  /// Returns whether this type is imported from package:objective_c.
  bool get isObjCImport => false;
}
