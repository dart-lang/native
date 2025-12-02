// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';
import '../context.dart';
import 'clang_bindings/clang_bindings.dart' as clang_types;
import 'sub_parsers/functiondecl_parser.dart';
import 'sub_parsers/macro_parser.dart';
import 'sub_parsers/objccategorydecl_parser.dart';
import 'sub_parsers/objcprotocoldecl_parser.dart';
import 'sub_parsers/var_parser.dart';
import 'type_extractor/extractor.dart';
import 'utils.dart';

/// Parses the translation units and adds all the bindings to the context's
/// bindingsIndex.
void parseTranslationUnits(
  Context context,
  List<clang_types.CXCursor> translationUnitCursors,
) {
  final headers = <String, bool>{};
  for (final translationUnitCursor in translationUnitCursors) {
    _parseTranslationUnits(context, translationUnitCursor, headers);
  }
}

void _parseTranslationUnit(
  Context context,
  List<clang_types.CXCursor> translationUnitCursors,
  Map<String, bool> headers,
) {
  final logger = context.logger;
  translationUnitCursor.visitChildren((cursor) {
    final file = cursor.sourceFileName();
    if (file.isEmpty) return;
    if (headers[file] ??= context.config.shouldIncludeHeader(Uri.file(file))) {
      try {
        final entry = context.bindingsIndex.getOrInsert(cursor.usr());
        entry.bindings ??= _parseCursor(context, entry.definition ?? cursor);
      } catch (e, s) {
        logger.severe(e);
        logger.severe(s);
        rethrow;
      }
    } else {
      logger.finest(
        'rootCursorVisitor:(not included) ${cursor.completeStringRepr()}',
      );
    }
  });
}

List<Binding> _parseCursor(Context context, clang_types.CXCursor cursor) {
  logger.finest('rootCursorVisitor: ${cursor.completeStringRepr()}');
  switch (clang.clang_getCursorKind(cursor)) {
    case clang_types.CXCursorKind.CXCursor_FunctionDecl:
      return parseFunctionDeclaration(context, cursor);
    case clang_types.CXCursorKind.CXCursor_StructDecl:
    case clang_types.CXCursorKind.CXCursor_UnionDecl:
    case clang_types.CXCursorKind.CXCursor_EnumDecl:
    case clang_types.CXCursorKind.CXCursor_ObjCInterfaceDecl:
    case clang_types.CXCursorKind.CXCursor_TypedefDecl:
      return [_getCodeGenTypeFromCursor(context, cursor)];
    case clang_types.CXCursorKind.CXCursor_ObjCCategoryDecl:
      return [parseObjCCategoryDeclaration(context, cursor)];
    case clang_types.CXCursorKind.CXCursor_ObjCProtocolDecl:
      return [parseObjCProtocolDeclaration(context, cursor)];
    case clang_types.CXCursorKind.CXCursor_MacroDefinition:
      // TODO: Return a binding?
      saveMacroDefinition(context, cursor);
      return [];
    case clang_types.CXCursorKind.CXCursor_VarDecl:
      return [parseVarDeclaration(context, cursor)];
    default:
      logger.finer('rootCursorVisitor: CursorKind not implemented');
  }
  return [];
}

BindingType? _getCodeGenTypeFromCursor(
  Context context,
  clang_types.CXCursor cursor,
) {
  final t = getCodeGenType(context, cursor.type());
  return t is BindingType ? t : null;
}

/// Visits all cursors and builds a map of usr and [clang_types.CXCursor].
void buildUsrCursorDefinitionMap(
  Context context,
  clang_types.CXCursor translationUnitCursor,
) {
  final logger = context.logger;
  translationUnitCursor.visitChildren((cursor) {
    try {
      context.cursorIndex.saveDefinition(cursor);
    } catch (e, s) {
      logger.severe(e);
      logger.severe(s);
      rethrow;
    }
  });
}
