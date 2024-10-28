// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:logging/logging.dart';

import '../code_generator.dart';
import 'clang_bindings/clang_bindings.dart' as clang_types;
import 'data.dart';
import 'sub_parsers/functiondecl_parser.dart';
import 'sub_parsers/macro_parser.dart';
import 'sub_parsers/objcinterfacedecl_parser.dart';
import 'sub_parsers/objcprotocoldecl_parser.dart';
import 'sub_parsers/typedefdecl_parser.dart';
import 'sub_parsers/var_parser.dart';
import 'type_extractor/extractor.dart';
import 'utils.dart';

final _logger = Logger('ffigen.header_parser.translation_unit_parser');

/// Parses the translation unit and returns the generated bindings.
Set<Binding> parseTranslationUnit(clang_types.CXCursor translationUnitCursor) {
  final bindings = <Binding>{};

  translationUnitCursor.visitChildren((cursor) {
    try {
      if (shouldIncludeRootCursor(cursor.sourceFileName())) {
        _logger.finest('rootCursorVisitor: ${cursor.completeStringRepr()}');
        switch (clang.clang_getCursorKind(cursor)) {
          case clang_types.CXCursorKind.CXCursor_FunctionDecl:
            bindings.addAll(parseFunctionDeclaration(cursor));
            break;
          case clang_types.CXCursorKind.CXCursor_StructDecl:
          case clang_types.CXCursorKind.CXCursor_UnionDecl:
          case clang_types.CXCursorKind.CXCursor_EnumDecl:
          case clang_types.CXCursorKind.CXCursor_ObjCInterfaceDecl:
            addToBindings(bindings, _getCodeGenTypeFromCursor(cursor));
            break;
          case clang_types.CXCursorKind.CXCursor_ObjCCategoryDecl:
            addToBindings(bindings, parseObjCCategoryDeclaration(cursor));
            break;
          case clang_types.CXCursorKind.CXCursor_ObjCProtocolDecl:
            addToBindings(bindings, parseObjCProtocolDeclaration(cursor));
            break;
          case clang_types.CXCursorKind.CXCursor_MacroDefinition:
            saveMacroDefinition(cursor);
            break;
          case clang_types.CXCursorKind.CXCursor_VarDecl:
            addToBindings(bindings, parseVarDeclaration(cursor));
            break;
          case clang_types.CXCursorKind.CXCursor_TypedefDecl:
            addToBindings(bindings, parseTypedefDeclaration(cursor));
            break;
          default:
            _logger.finer('rootCursorVisitor: CursorKind not implemented');
        }
      } else {
        _logger.finest(
            'rootCursorVisitor:(not included) ${cursor.completeStringRepr()}');
      }
    } catch (e, s) {
      _logger.severe(e);
      _logger.severe(s);
      rethrow;
    }
  });

  return bindings;
}

/// Adds to binding if unseen and not null.
void addToBindings(Set<Binding> bindings, Binding? b) {
  if (b != null) {
    // This is a set, and hence will not have duplicates.
    bindings.add(b);
  }
}

BindingType? _getCodeGenTypeFromCursor(clang_types.CXCursor cursor) {
  final t = getCodeGenType(cursor.type());
  return t is BindingType ? t : null;
}

/// Visits all cursors and builds a map of usr and [clang_types.CXCursor].
void buildUsrCursorDefinitionMap(clang_types.CXCursor translationUnitCursor) {
  translationUnitCursor.visitChildren((cursor) {
    try {
      cursorIndex.saveDefinition(cursor);
    } catch (e, s) {
      _logger.severe(e);
      _logger.severe(s);
      rethrow;
    }
  });
}

/// True if a cursor should be included based on headers config, used on root
/// declarations.
bool shouldIncludeRootCursor(String sourceFile) {
  // Handle empty string in case of system headers or macros.
  if (sourceFile.isEmpty) {
    return false;
  }

  // Add header to seen if it's not.
  if (!bindingsIndex.isSeenHeader(sourceFile)) {
    bindingsIndex.addHeaderToSeen(
        sourceFile, config.shouldIncludeHeader(Uri.file(sourceFile)));
  }

  return bindingsIndex.getSeenHeaderStatus(sourceFile)!;
}
