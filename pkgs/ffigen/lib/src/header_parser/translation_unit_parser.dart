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

/// Parses the translation unit and returns the generated bindings.
Set<Binding> parseTranslationUnit(
  Context context,
  clang_types.CXCursor translationUnitCursor,
) {
  final bindings = <Binding>{};
  final logger = context.logger;

  translationUnitCursor.visitChildren((cursor) {
    try {
      if (shouldIncludeRootCursor(context, cursor.sourceFileName())) {
        logger.finest('rootCursorVisitor: ${cursor.completeStringRepr()}');
        switch (clang.clang_getCursorKind(cursor)) {
          case clang_types.CXCursorKind.CXCursor_FunctionDecl:
            bindings.addAll(parseFunctionDeclaration(context, cursor));
            break;
          case clang_types.CXCursorKind.CXCursor_StructDecl:
          case clang_types.CXCursorKind.CXCursor_UnionDecl:
          case clang_types.CXCursorKind.CXCursor_EnumDecl:
          case clang_types.CXCursorKind.CXCursor_ObjCInterfaceDecl:
          case clang_types.CXCursorKind.CXCursor_TypedefDecl:
            addToBindings(bindings, _getCodeGenTypeFromCursor(context, cursor));
            break;
          case clang_types.CXCursorKind.CXCursor_ObjCCategoryDecl:
            addToBindings(
              bindings,
              parseObjCCategoryDeclaration(context, cursor),
            );
            break;
          case clang_types.CXCursorKind.CXCursor_ObjCProtocolDecl:
            addToBindings(
              bindings,
              parseObjCProtocolDeclaration(context, cursor),
            );
            break;
          case clang_types.CXCursorKind.CXCursor_MacroDefinition:
            saveMacroDefinition(context, cursor);
            break;
          case clang_types.CXCursorKind.CXCursor_VarDecl:
            addToBindings(bindings, parseVarDeclaration(context, cursor));
            break;
          default:
            logger.finer('rootCursorVisitor: CursorKind not implemented');
        }
      } else {
        logger.finest(
          'rootCursorVisitor:(not included) ${cursor.completeStringRepr()}',
        );
      }
    } catch (e, s) {
      logger.severe(e);
      logger.severe(s);
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

/// True if a cursor should be included based on headers config, used on root
/// declarations.
bool shouldIncludeRootCursor(Context context, String sourceFile) {
  // Handle empty string in case of system headers or macros.
  if (sourceFile.isEmpty) {
    return false;
  }

  // Add header to seen if it's not.
  if (!context.bindingsIndex.isSeenHeader(sourceFile)) {
    context.bindingsIndex.addHeaderToSeen(
      sourceFile,
      context.config.headers.include(Uri.file(sourceFile)),
    );
  }

  return context.bindingsIndex.getSeenHeaderStatus(sourceFile)!;
}
