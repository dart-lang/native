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
  final cppClasses = config.cpp?.classes;
  if (cppClasses == null) return null;

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

  final methods = <CppMethod>[];

  cursor.visitChildren((child) {
    final kind = clang.clang_getCursorKind(child);
    if (kind == clang_types.CXCursorKind.CXCursor_CXXMethod) {
      _parseAnyMethod(context, child, decl, methods, CppMethodKind.method);
    } else if (kind == clang_types.CXCursorKind.CXCursor_Constructor) {
      _parseAnyMethod(context, child, decl, methods, CppMethodKind.constructor);
    } else if (kind == clang_types.CXCursorKind.CXCursor_Destructor) {
      _parseAnyMethod(context, child, decl, methods, CppMethodKind.destructor);
    }
  });

  final cppClass = CppClass(
    usr: usr,
    dartDoc: getCursorDocComment(
      context,
      cursor,
      availability: apiAvailability.dartDoc,
    ),
    originalName: className,
    name: cppClasses.rename(decl),
    context: context,
    methods: methods,
    fields: <CppMember>[],
  );

  context.bindingsIndex.addCppClassToSeen(usr, cppClass);

  return cppClass;
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

  final parameters = kind == CppMethodKind.destructor
      ? <Parameter>[]
      : _parseParameters(context, cursor, classDecl);
  if (parameters == null) {
    logger.fine(
      '  ---- Skipping method $methodName due to unsupported parameter type',
    );
    return;
  }

  final className = context.config.cpp!.classes.rename(classDecl);
  final symbol = switch (kind) {
    CppMethodKind.constructor => '${className}_new',
    CppMethodKind.destructor => '${className}_delete',
    CppMethodKind.method => '${className}_$methodName',
  };

  logger.fine('  ++++ ${kind.name}: $methodName (const=$isConst)');
  methods.add(
    CppMethod(
      name: Symbol(symbol, SymbolKind.method),
      originalName: methodName,
      returnType: clang
          .clang_getCursorResultType(cursor)
          .toCodeGenType(context),
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
  var i = 0;
  final parsed = parseParameters(
    context,
    cursor,
    renameFn: (paramName) => paramName.isEmpty ? 'arg${i++}' : paramName,
  );
  if (parsed.hasIncompleteStruct || parsed.hasUnimplementedType) {
    logger.fine('  Unsupported parameter type');
    return null;
  }
  return parsed.parameters;
}
