// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../code_generator.dart';
import '../../code_generator/scope.dart';
import '../../config_provider/config_types.dart';
import '../../context.dart';
import '../clang_bindings/clang_bindings.dart' as clang_types;
import '../utils.dart';
import 'api_availability.dart';
import 'functiondecl_parser.dart';

/// Parses a C++ class declaration.
CppClass? parseClassDeclaration(Context context, clang_types.CXCursor cursor) {
  final config = context.config;
  final logger = context.logger;

  // If C++ support is not configured, skip all C++ class cursors immediately.
  if (config.cpp == null) return null;

  final usr = cursor.usr();

  final cachedClass = context.bindingsIndex.getSeenCppClass(usr);
  if (cachedClass != null) return cachedClass;

  cursor = context.cursorIndex.getDefinition(cursor);

  // Use the libclang API to detect anonymous classes reliably.
  final String className;
  if (clang.clang_Cursor_isAnonymous(cursor) == 0) {
    className = cursor.spelling();
  } else {
    logger.fine('Skipping anonymous C++ class.');
    return null;
  }

  if (className.isEmpty) {
    logger.fine('Skipping anonymous C++ class.');
    return null;
  }

  final apiAvailability = ApiAvailability.fromCursor(cursor, context);
  if (apiAvailability.availability == Availability.none) {
    logger.info('Omitting deprecated C++ class $className');
    return null;
  }

  final decl = Declaration(usr: usr, originalName: className);

  logger.fine(
    '++++ Adding C++ Class: Name: $className, ${cursor.completeStringRepr()}',
  );

  final cppClass = CppClass(
    usr: usr,
    dartDoc: getCursorDocComment(
      context,
      cursor,
      availability: apiAvailability.dartDoc,
    ),
    originalName: className,
    name: className,
    context: context,
    methods: <CppMethod>[],
    fields: <CppMember>[],
    bases: <CppClass>[],
  );

  context.bindingsIndex.addCppClassToSeen(usr, cppClass);

  cursor.visitChildren((child) {
    final kind = clang.clang_getCursorKind(child);
    if (kind == clang_types.CXCursorKind.CXCursor_CXXMethod) {
      _parseAnyMethod(
        context,
        child,
        decl,
        cppClass.methods,
        CppMethodKind.method,
      );
    } else if (kind == clang_types.CXCursorKind.CXCursor_Constructor) {
      _parseAnyMethod(
        context,
        child,
        decl,
        cppClass.methods,
        CppMethodKind.constructor,
      );
    }
  });

  // Parse public base classes (only public specifiers; non-public are ignored).
  cppClass.bases.addAll(_parsePublicBases(context, cursor));

  return cppClass;
}

/// Parses the direct public base classes of [cursor].
List<CppClass> _parsePublicBases(Context context, clang_types.CXCursor cursor) {
  final bases = <CppClass>[];

  cursor.visitChildren((child) {
    final kind = clang.clang_getCursorKind(child);
    if (kind != clang_types.CXCursorKind.CXCursor_CXXBaseSpecifier) return;

    final access = clang.clang_getCXXAccessSpecifier(child);
    if (access != clang_types.CX_CXXAccessSpecifier.CX_CXXPublic) return;

    final baseType = clang.clang_getCursorType(child);
    final baseDeclCursor = clang.clang_getTypeDeclaration(baseType);
    final baseUsr = baseDeclCursor.usr();

    final baseClass = context.bindingsIndex.getSeenCppClass(baseUsr);
    if (baseClass == null) {
      final parsed = parseClassDeclaration(context, baseDeclCursor);
      if (parsed != null) bases.add(parsed);
    } else {
      bases.add(baseClass);
    }
  });

  return bases;
}

void _parseAnyMethod(
  Context context,
  clang_types.CXCursor cursor,
  Declaration classDecl,
  List<CppMethod> methods,
  CppMethodKind kind,
) {
  final logger = context.logger;
  final methodName = cursor.spelling();
  final isStatic =
      kind == CppMethodKind.constructor ||
      clang.clang_CXXMethod_isStatic(cursor) != 0;
  final isConst =
      kind == CppMethodKind.method &&
      clang.clang_CXXMethod_isConst(cursor) != 0;

  final parameters = _parseParameters(context, cursor, classDecl);
  if (parameters == null) {
    logger.fine(
      '  ---- Skipping method $methodName due to unsupported parameter type',
    );
    return;
  }

  final returnType = clang
      .clang_getCursorResultType(cursor)
      .toCodeGenType(context);
  if (returnType.baseType is UnimplementedType) {
    logger.fine(
      '  ---- Skipping method $methodName due to unsupported return type',
    );
    return;
  } else if (returnType.isIncompleteCompound) {
    logger.fine(
      '  ---- Skipping method $methodName, incomplete struct returned by value',
    );
    return;
  }

  final className = classDecl.originalName;
  final symbol = switch (kind) {
    CppMethodKind.constructor => '${className}_new',
    CppMethodKind.method => '${className}_$methodName',
  };

  logger.fine('  ++++ ${kind.name}: $methodName (const=$isConst)');
  methods.add(
    CppMethod(
      name: Symbol(symbol, SymbolKind.method),
      originalName: methodName,
      returnType: returnType,
      parameters: parameters,
      isConstant: isConst,
      isStatic: isStatic,
      kind: kind,
    ),
  );
}

List<Parameter>? _parseParameters(
  Context context,
  clang_types.CXCursor cursor,
  Declaration classDecl,
) {
  final logger = context.logger;
  final parsed = parseParameters(context, cursor);
  if (parsed.hasIncompleteStruct || parsed.hasUnimplementedType) {
    logger.fine('  Unsupported parameter type');
    return null;
  }
  return parsed.parameters;
}
