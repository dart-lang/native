// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../code_generator.dart';
import '../../config_provider/config_types.dart';
import '../../context.dart';
import '../clang_bindings/clang_bindings.dart' as clang_types;
import '../utils.dart';
import 'api_availability.dart';

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
    className = usr.split('@').last;
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
      _parseMethod(context, child, decl, methods);
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

void _parseMethod(
  Context context,
  clang_types.CXCursor cursor,
  Declaration classDecl,
  List<CppMethod> methods,
) {
  final logger = context.logger;
  final methodName = cursor.spelling();

  final isStatic = clang.clang_CXXMethod_isStatic(cursor) != 0;
  if (isStatic) {
    logger.fine('  ---- Skipping static C++ method: $methodName');
    return;
  }

  final isConst = clang.clang_CXXMethod_isConst(cursor) != 0;
  final returnType = clang
      .clang_getCursorResultType(cursor)
      .toCodeGenType(context);

  final parameters = _parseParameters(context, cursor, classDecl);
  if (parameters == null) {
    logger.fine(
      '  ---- Skipping method $methodName due to unsupported parameter type',
    );
    return;
  }

  logger.fine('  ++++ Method: $methodName (const=$isConst)');
  methods.add(
    CppMethod(
      name: methodName,
      originalName: methodName,
      returnType: returnType,
      parameters: parameters,
      isConstant: isConst,
      isStatic: isStatic,
      kind: CppMethodKind.method,
    ),
  );
}

List<Parameter>? _parseParameters(
  Context context,
  clang_types.CXCursor cursor,
  Declaration classDecl,
) {
  final logger = context.logger;
  final parameters = <Parameter>[];
  final totalArgs = clang.clang_Cursor_getNumArguments(cursor);

  for (var i = 0; i < totalArgs; i++) {
    final paramCursor = clang.clang_Cursor_getArgument(cursor, i);
    final paramType = paramCursor.toCodeGenType(context);

    if (paramType.isIncompleteCompound ||
        paramType.baseType is UnimplementedType) {
      logger.fine('  Unsupported parameter type: ${paramType.baseType}');
      return null;
    }

    final paramName = paramCursor.spelling();
    final resolvedName = paramName.isEmpty ? 'arg$i' : paramName;

    parameters.add(
      Parameter(
        originalName: resolvedName,
        name: resolvedName,
        type: paramType,
        objCConsumed: false,
      ),
    );
  }

  return parameters;
}
