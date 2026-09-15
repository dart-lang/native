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
import 'sub_parsers/typedefdecl_parser.dart';
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
  final headers = <String, bool>{};

  void rootCursorVisitor(clang_types.CXCursor cursor) {
    final file = cursor.sourceFileName();
    if (file.isEmpty) return;
    if (headers[file] ??= context.config.input.include(Uri.file(file))) {
      try {
        logger.finest('rootCursorVisitor: ${cursor.completeStringRepr()}');
        switch (clang.clang_getCursorKind(cursor)) {
          case clang_types.CXCursorKind.CXCursor_FunctionDecl:
            addToBindings(bindings, parseFunctionDeclaration(context, cursor));
            break;
          case clang_types.CXCursorKind.CXCursor_StructDecl:
          case clang_types.CXCursorKind.CXCursor_ClassDecl:
          case clang_types.CXCursorKind.CXCursor_UnionDecl:
            addToBindings(bindings, _getCodeGenTypeFromCursor(context, cursor));
            _visitScopeForNestedDecls(context, cursor, bindings, headers);
            break;
          case clang_types.CXCursorKind.CXCursor_EnumDecl:
          case clang_types.CXCursorKind.CXCursor_ObjCInterfaceDecl:
            addToBindings(bindings, _getCodeGenTypeFromCursor(context, cursor));
            break;
          case clang_types.CXCursorKind.CXCursor_TypedefDecl:
            addToBindings(bindings, parseTypedefDeclaration(context, cursor));
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
          case clang_types.CXCursorKind.CXCursor_Namespace:
            _visitScopeForNestedDecls(context, cursor, bindings, headers);
            break;
          case clang_types.CXCursorKind.CXCursor_LinkageSpec:
            cursor.visitChildren(rootCursorVisitor);
            break;
          default:
            logger.finer('rootCursorVisitor: CursorKind not implemented');
        }
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
  }

  translationUnitCursor.visitChildren(rootCursorVisitor);

  return bindings;
}

/// Recurses into a C++ namespace or record, surfacing the enum, struct, class
/// and union declarations nested inside it.
// TODO: Dispatch VarDecl, FunctionDecl, etc. here for fuller C++ namespace
// support.
void _visitScopeForNestedDecls(
  Context context,
  clang_types.CXCursor scopeCursor,
  Set<Binding> bindings,
  Map<String, bool> headers,
) {
  final logger = context.logger;
  if (clang.clang_Cursor_isAnonymous(scopeCursor) != 0) {
    logger.fine('Skipping anonymous scope.');
    return;
  }
  scopeCursor.visitChildren((cursor) {
    final kind = clang.clang_getCursorKind(cursor);
    if (!_nestedDeclKinds.contains(kind)) {
      // Filter before logging: `completeStringRepr` calls `usr()`, which
      // asserts that the USR is free of `synthUsrChar` (`~`), and destructor
      // USRs contain it.
      logger.finer('nestedDeclCursorVisitor: CursorKind not implemented');
      return;
    }
    final file = cursor.sourceFileName();
    if (file.isEmpty) return;
    if (!(headers[file] ??= context.config.input.include(Uri.file(file)))) {
      logger.finest(
        'nestedDeclCursorVisitor:(not included) ${cursor.completeStringRepr()}',
      );
      return;
    }
    logger.finest('nestedDeclCursorVisitor: ${cursor.completeStringRepr()}');
    switch (kind) {
      case clang_types.CXCursorKind.CXCursor_EnumDecl:
        addToBindings(bindings, _getCodeGenTypeFromCursor(context, cursor));
        break;
      case clang_types.CXCursorKind.CXCursor_StructDecl:
      case clang_types.CXCursorKind.CXCursor_ClassDecl:
      case clang_types.CXCursorKind.CXCursor_UnionDecl:
        // Anonymous records are handled as members of their parent record,
        // not as bindings of their own.
        if (clang.clang_Cursor_isAnonymous(cursor) == 0 &&
            _mayParseNestedCompound(context, cursor)) {
          addToBindings(bindings, _getCodeGenTypeFromCursor(context, cursor));
        }
        _visitScopeForNestedDecls(context, cursor, bindings, headers);
        break;
      default:
        // A namespace or an `extern "C"` block.
        _visitScopeForNestedDecls(context, cursor, bindings, headers);
    }
  });
}

/// The cursor kinds [_visitScopeForNestedDecls] descends into or generates
/// bindings for.
const _nestedDeclKinds = {
  clang_types.CXCursorKind.CXCursor_Namespace,
  clang_types.CXCursorKind.CXCursor_LinkageSpec,
  clang_types.CXCursorKind.CXCursor_StructDecl,
  clang_types.CXCursorKind.CXCursor_ClassDecl,
  clang_types.CXCursorKind.CXCursor_UnionDecl,
  clang_types.CXCursorKind.CXCursor_EnumDecl,
};

/// Whether the nested record at [cursor] may be parsed.
///
/// Records in system headers are skipped: parsing one also parses its methods
/// and their types, which for the C++ standard library is unbounded, and
/// `Input.include` admits transitively included headers by default.
///
/// With C++ class support on, records become `CppClass`es, which are still
/// named by their leaf name alone, so scoped ones would collide. They are
/// skipped until `CppClass` gets a qualified name.
bool _mayParseNestedCompound(Context context, clang_types.CXCursor cursor) =>
    context.config.cpp == null && !cursor.isInSystemHeader();

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
  void visitor(clang_types.CXCursor cursor) {
    try {
      if (clang.clang_getCursorKind(cursor) ==
          clang_types.CXCursorKind.CXCursor_LinkageSpec) {
        cursor.visitChildren(visitor);
      } else {
        context.cursorIndex.saveDefinition(cursor);
      }
    } catch (e, s) {
      logger.severe(e);
      logger.severe(s);
      rethrow;
    }
  }

  translationUnitCursor.visitChildren(visitor);
}
