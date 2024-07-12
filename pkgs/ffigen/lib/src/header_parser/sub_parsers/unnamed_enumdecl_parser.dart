// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/header_parser/data.dart';
import 'package:ffigen/src/header_parser/includer.dart';
import 'package:logging/logging.dart';

import '../clang_bindings/clang_bindings.dart' as clang_types;
import '../utils.dart';

final _logger = Logger('ffigen.header_parser.unnamed_enumdecl_parser');

/// Saves unnamed enums.
List<Constant> saveUnNamedEnum(clang_types.CXCursor cursor) {
  final addedConstants = <Constant>[];
  cursor.visitChildren((child) {
    try {
      _logger
          .finest('  unnamedenumCursorVisitor: ${child.completeStringRepr()}');
      switch (clang.clang_getCursorKind(child)) {
        case clang_types.CXCursorKind.CXCursor_EnumConstantDecl:
          if (shouldIncludeUnnamedEnumConstant(child.usr(), child.spelling())) {
            addedConstants.add(_addUnNamedEnumConstant(child));
          }
          break;
        case clang_types.CXCursorKind.CXCursor_UnexposedAttr:
          // Ignore.
          break;
        default:
          _logger.severe('Invalid enum constant.');
      }
    } catch (e, s) {
      _logger.severe(e);
      _logger.severe(s);
      rethrow;
    }
  });
  return addedConstants;
}

/// Adds the parameter to func in functiondecl_parser.dart.
Constant _addUnNamedEnumConstant(clang_types.CXCursor cursor) {
  _logger.fine(
      '++++ Adding Constant from unnamed enum: ${cursor.completeStringRepr()}');
  final constant = Constant(
    usr: cursor.usr(),
    originalName: cursor.spelling(),
    name: config.unnamedEnumConstants.renameUsingConfig(
      cursor.spelling(),
    ),
    rawType: 'int',
    rawValue: clang.clang_getEnumConstantDeclValue(cursor).toString(),
  );
  bindingsIndex.addUnnamedEnumConstantToSeen(cursor.usr(), constant);
  unnamedEnumConstants.add(constant);
  return constant;
}
