// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../visitor/ast.dart';

import 'binding.dart';
import 'binding_string.dart';
import 'utils.dart';
import 'writer.dart';

/// A simple Constant.
///
/// Expands to -
/// ```dart
/// const <type> <name> = <rawValue>;
/// ```
///
/// Example -
/// ```dart
/// const int name = 10;
/// ```
class Constant extends NoLookUpBinding {
  /// The rawType is pasted as it is. E.g 'int', 'String', 'double'
  final String rawType;

  /// The rawValue is pasted as it is.
  ///
  /// Put quotes if type is a string.
  final String rawValue;

  Constant({
    super.usr,
    super.originalName,
    required super.name,
    super.dartDoc,
    required this.rawType,
    required this.rawValue,
  });

  @override
  BindingString toBindingString(Writer w) {
    final s = StringBuffer();
    final constantName = name;

    s.write(makeDartDoc(dartDoc));
    s.write('\nconst $rawType $constantName = $rawValue;\n\n');

    return BindingString(
      type: BindingStringType.constant,
      string: s.toString(),
    );
  }

  @override
  void visit(Visitation visitation) => visitation.visitConstant(this);
}

/// A [Constant] defined by an unnamed enum.
class UnnamedEnumConstant extends Constant {
  UnnamedEnumConstant({
    super.usr,
    super.originalName,
    required super.name,
    super.dartDoc,
    required super.rawType,
    required super.rawValue,
  });

  @override
  void visit(Visitation visitation) =>
      visitation.visitUnnamedEnumConstant(this);
}

/// A [Constant] defined by a macro.
class MacroConstant extends Constant {
  MacroConstant({
    super.usr,
    super.originalName,
    required super.name,
    super.dartDoc,
    required super.rawType,
    required super.rawValue,
  });

  @override
  void visit(Visitation visitation) => visitation.visitMacroConstant(this);
}
