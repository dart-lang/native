// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:logging/logging.dart';

import '../../code_generator.dart';
import '../../config_provider/config_types.dart';
import '../clang_bindings/clang_bindings.dart' as clang_types;
import '../data.dart';
import '../utils.dart';
import 'api_availability.dart';

final _logger = Logger('ffigen.header_parser.unnamed_enumdecl_parser');

/// Saves unnamed enums.
List<Constant> saveUnNamedEnum(clang_types.CXCursor cursor) {
  final addedConstants = <Constant>[];
  cursor.visitChildren((child) {
    try {
      _logger.finest(
        '  unnamedenumCursorVisitor: ${child.completeStringRepr()}',
      );
      switch (clang.clang_getCursorKind(child)) {
        case clang_types.CXCursorKind.CXCursor_EnumConstantDecl:
          final value = _addUnNamedEnumConstant(child);
          if (value != null) {
            addedConstants.add(value);
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
Constant? _addUnNamedEnumConstant(clang_types.CXCursor cursor) {
  final apiAvailability = ApiAvailability.fromCursor(cursor);
  if (apiAvailability.availability == Availability.none) {
    _logger.info('Omitting deprecated unnamed enum value ${cursor.spelling()}');
    return null;
  }

  _logger.fine(
    '++++ Adding Constant from unnamed enum: ${cursor.completeStringRepr()}',
  );
  final constant = UnnamedEnumConstant(
    usr: cursor.usr(),
    originalName: cursor.spelling(),
    name: config.unnamedEnumConstants.rename(
      Declaration(usr: cursor.usr(), originalName: cursor.spelling()),
    ),
    dartDoc: apiAvailability.dartDoc,
    rawType: 'int',
    rawValue: clang.clang_getEnumConstantDeclValue(cursor).toString(),
  );
  bindingsIndex.addUnnamedEnumConstantToSeen(cursor.usr(), constant);
  unnamedEnumConstants.add(constant);
  return constant;
}
