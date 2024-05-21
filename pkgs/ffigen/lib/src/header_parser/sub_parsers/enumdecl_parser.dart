// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/header_parser/data.dart';
import 'package:ffigen/src/header_parser/sub_parsers/unnamed_enumdecl_parser.dart';
import 'package:logging/logging.dart';

import '../clang_bindings/clang_bindings.dart' as clang_types;
import '../includer.dart';
import '../utils.dart';

final _logger = Logger('ffigen.header_parser.enumdecl_parser');

/// Parses an enum declaration.
EnumClass? parseEnumDeclaration(
  clang_types.CXCursor cursor, {
  /// Option to ignore declaration filter (Useful in case of extracting
  /// declarations when they are passed/returned by an included function.)
  bool ignoreFilter = false,
}) {
  // Parse the cursor definition instead, if this is a forward declaration.
  cursor = cursorIndex.getDefinition(cursor);

  final enumUsr = cursor.usr();
  final String enumName;
  // Only set name using USR if the type is not Anonymous (i.e not inside
  // any typedef and declared inplace inside another type).
  if (clang.clang_Cursor_isAnonymous(cursor) == 0) {
    // This gives the significant name, i.e name of the enum if defined or
    // name of the first typedef declaration that refers to it.
    enumName = enumUsr.split('@').last;
  } else {
    enumName = '';
  }

  if (enumName.isEmpty) {
    _logger.fine('Saving anonymous enum.');
    saveUnNamedEnum(cursor);
  } else if (ignoreFilter || shouldIncludeEnumClass(enumUsr, enumName)) {
    _logger.fine('++++ Adding Enum: ${cursor.completeStringRepr()}');
    final enumClass = EnumClass(
      usr: enumUsr,
      dartDoc: getCursorDocComment(cursor),
      originalName: enumName,
      name: config.enumClassDecl.renameUsingConfig(enumName),
    );
    cursor.visitChildren((clang_types.CXCursor child) {
      try {
        _logger.finest('  enumCursorVisitor: ${child.completeStringRepr()}');
        switch (clang.clang_getCursorKind(child)) {
          case clang_types.CXCursorKind.CXCursor_EnumConstantDecl:
            enumClass.enumConstants.add(
              EnumConstant(
                  dartDoc: getCursorDocComment(
                    child,
                    nesting.length + commentPrefix.length,
                  ),
                  originalName: child.spelling(),
                  name: config.enumClassDecl.renameMemberUsingConfig(
                    enumClass.originalName,
                    child.spelling(),
                  ),
                  value: clang.clang_getEnumConstantDeclValue(child)),
            );
            break;
          case clang_types.CXCursorKind.CXCursor_UnexposedAttr:
            // Ignore.
            break;
          default:
            _logger.fine('invalid enum constant');
        }
      } catch (e, s) {
        _logger.severe(e);
        _logger.severe(s);
        rethrow;
      }
    });
    return enumClass;
  }
  return null;
}
