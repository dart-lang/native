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

  /// Visits a child of the translation unit or, when [nested], of a C++
  /// namespace or record. Only the kinds in [_nestedDeclKinds] are surfaced
  /// from namespaces and records so far.
  // TODO(https://github.com/dart-lang/native/issues/3667): Dispatch VarDecl
  // and FunctionDecl when nested. They need an identity distinct from the
  // lookup symbol first.
  void cursorVisitor(clang_types.CXCursor cursor, {required bool nested}) {
    final kind = clang.clang_getCursorKind(cursor);
    if (nested && !_nestedDeclKinds.contains(kind)) {
      logger.finer('cursorVisitor: CursorKind not implemented');
      return;
    }
    final file = cursor.sourceFileName();
    if (file.isEmpty) return;
    if (!(headers[file] ??= context.config.input.include(Uri.file(file)))) {
      logger.finest(
        'cursorVisitor:(not included) ${cursor.completeStringRepr()}',
      );
      return;
    }
    void visitNested(clang_types.CXCursor scope) =>
        scope.visitChildren((child) => cursorVisitor(child, nested: true));
    try {
      logger.finest('cursorVisitor: ${cursor.completeStringRepr()}');
      switch (kind) {
        case clang_types.CXCursorKind.CXCursor_FunctionDecl:
          addToBindings(bindings, parseFunctionDeclaration(context, cursor));
          break;
        case clang_types.CXCursorKind.CXCursor_StructDecl:
        case clang_types.CXCursorKind.CXCursor_ClassDecl:
        case clang_types.CXCursorKind.CXCursor_UnionDecl:
          // A nested anonymous record is handled as a member of its parent
          // record, not as a binding of its own.
          final isAnonymous = clang.clang_Cursor_isAnonymous(cursor) != 0;
          if (!nested || (!isAnonymous && _mayParseNestedCompound(context))) {
            addToBindings(bindings, _getCodeGenTypeFromCursor(context, cursor));
          }
          if (!isAnonymous) visitNested(cursor);
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
          // Anonymous namespaces are private to their translation unit. Types
          // in them are still parsed on demand when an included function or
          // record refers to them.
          if (clang.clang_Cursor_isAnonymous(cursor) == 0) visitNested(cursor);
          break;
        case clang_types.CXCursorKind.CXCursor_LinkageSpec:
          cursor.visitChildren((child) => cursorVisitor(child, nested: nested));
          break;
        default:
          logger.finer('cursorVisitor: CursorKind not implemented');
      }
    } catch (e, s) {
      logger.severe(e);
      logger.severe(s);
      rethrow;
    }
  }

  translationUnitCursor.visitChildren(
    (cursor) => cursorVisitor(cursor, nested: false),
  );

  return bindings;
}

/// The cursor kinds surfaced from inside a C++ namespace or record.
const _nestedDeclKinds = {
  clang_types.CXCursorKind.CXCursor_Namespace,
  clang_types.CXCursorKind.CXCursor_LinkageSpec,
  clang_types.CXCursorKind.CXCursor_StructDecl,
  clang_types.CXCursorKind.CXCursor_ClassDecl,
  clang_types.CXCursorKind.CXCursor_UnionDecl,
  clang_types.CXCursorKind.CXCursor_EnumDecl,
};

/// Whether a nested record may be parsed.
///
/// With C++ class support on, records become `CppClass`es, which are still
/// named by their leaf name alone, so scoped ones would collide. They are
/// skipped until `CppClass` gets a qualified name.
bool _mayParseNestedCompound(Context context) => context.config.cpp == null;

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
