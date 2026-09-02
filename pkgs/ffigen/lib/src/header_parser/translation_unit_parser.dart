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

/// Recurses into a C++ namespace or record, surfacing the enum, struct and
/// union declarations nested inside it.
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
    if (!_isNestedDeclScope(kind)) {
      // Bail out before logging: `completeStringRepr` computes the cursor's
      // USR, which is not meaningful for every kind found in a namespace or
      // record (e.g. destructors).
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
    try {
      logger.finest('nestedDeclCursorVisitor: ${cursor.completeStringRepr()}');
      switch (kind) {
        case clang_types.CXCursorKind.CXCursor_EnumDecl:
          addToBindings(bindings, _getCodeGenTypeFromCursor(context, cursor));
          break;
        case clang_types.CXCursorKind.CXCursor_UnionDecl:
        case clang_types.CXCursorKind.CXCursor_StructDecl:
          // Anonymous records are handled as members of their parent record,
          // not as bindings of their own.
          if (clang.clang_Cursor_isAnonymous(cursor) == 0 &&
              _mayParseNestedCompound(context, cursor)) {
            addToBindings(bindings, _getCodeGenTypeFromCursor(context, cursor));
          }
          _visitScopeForNestedDecls(context, cursor, bindings, headers);
          break;
        default:
          // A namespace, a record or an `extern "C"` block: recurse to find
          // the declarations nested deeper.
          _visitScopeForNestedDecls(context, cursor, bindings, headers);
      }
    } catch (e, s) {
      logger.severe(e);
      logger.severe(s);
      rethrow;
    }
  });
}

/// Whether the nested struct or union at [cursor] may be parsed at all.
///
/// Parsing a record also parses its methods and every type they mention, so a
/// record nested in a system header would drag in an unbounded amount of the
/// C++ standard library. `Input.include` admits transitively included headers
/// by default, so those are refused here rather than left to the AST visitors,
/// which run after parsing. Enums are leaves and need no such guard.
///
/// With C++ class support on, a record is parsed as a `CppClass` instead,
/// which names itself and its method symbols after the leaf name alone. Two
/// records sharing a leaf name across scopes would be indistinguishable, and
/// the generated glue would name the type unqualified, so scoped records are
/// left to the change that gives `CppClass` its qualified name.
bool _mayParseNestedCompound(Context context, clang_types.CXCursor cursor) =>
    context.config.cpp == null && !cursor.isInSystemHeader();

/// Whether [_visitScopeForNestedDecls] descends into cursors of [kind], or
/// generates bindings for them.
bool _isNestedDeclScope(int kind) => switch (kind) {
  clang_types.CXCursorKind.CXCursor_Namespace ||
  clang_types.CXCursorKind.CXCursor_LinkageSpec ||
  clang_types.CXCursorKind.CXCursor_UnionDecl ||
  clang_types.CXCursorKind.CXCursor_ClassDecl ||
  clang_types.CXCursorKind.CXCursor_StructDecl ||
  clang_types.CXCursorKind.CXCursor_EnumDecl => true,
  _ => false,
};

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
