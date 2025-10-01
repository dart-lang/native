// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../config_provider/config_types.dart' show Declaration;
import '../visitor/ast.dart';
import 'binding_string.dart';
import 'scope.dart';
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

  Symbol _symbol;
  Symbol get symbol => _symbol;
  set symbol(Symbol newSymbol) {
    assert(!_symbol.isFilled);
    _symbol = newSymbol;
  }

  String get name => _symbol.name;

  final String? dartDoc;
  final bool isInternal;

  /// Whether these bindings should be generated.
  ///
  /// Set by MarkBindingsVisitation.
  bool generateBindings = true;

  Binding({
    required this.usr,
    required this.originalName,
    required String name,
    this.dartDoc,
    this.isInternal = false,
  }) : _symbol = Symbol(name);

  /// Converts a Binding to its actual string representation.
  ///
  /// Note: This does not print the typedef dependencies.
  /// Must call getTypedefDependencies first.
  BindingString toBindingString(Writer w);

  /// Returns the Objective C bindings, if any.
  BindingString? toObjCBindingString(Writer w) => null;

  @override
  void visit(Visitation visitation) => visitation.visitBinding(this);

  @override
  void visitChildren(Visitor visitor) {
    super.visitChildren(visitor);
    visitor.visit(_symbol);
  }

  /// Returns whether this type is imported from package:objective_c.
  bool get isObjCImport => false;
}

/// Base class for bindings which look up symbols in dynamic library.
abstract class LookUpBinding extends Binding {
  LookUpBinding({
    String? usr,
    String? originalName,
    required super.name,
    super.dartDoc,
    super.isInternal,
  }) : super(usr: usr ?? name, originalName: originalName ?? name);

  @override
  void visit(Visitation visitation) => visitation.visitLookUpBinding(this);

  bool get loadFromNativeAsset;
}

/// Base class for bindings which don't look up symbols in dynamic library.
abstract class NoLookUpBinding extends Binding {
  NoLookUpBinding({
    String? usr,
    String? originalName,
    required super.name,
    super.dartDoc,
    super.isInternal,
  }) : super(usr: usr ?? name, originalName: originalName ?? name);

  @override
  void visit(Visitation visitation) => visitation.visitNoLookUpBinding(this);
}
