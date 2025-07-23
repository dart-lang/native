// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../code_generator.dart';
import '../../config_provider/config_types.dart';
import '../../context.dart';
import '../clang_bindings/clang_bindings.dart' as clang_types;
import '../utils.dart';
import 'api_availability.dart';

/// Parses a function declaration.
List<Func> parseFunctionDeclaration(
  Context context,
  clang_types.CXCursor cursor,
) {
  final config = context.config;
  final logger = context.logger;

  /// Multiple values are since there may be more than one instance of the
  /// same base C function with different variadic arguments.
  final funcs = <Func>[];

  final funcUsr = cursor.usr();
  final funcName = cursor.spelling();

  final apiAvailability = ApiAvailability.fromCursor(cursor, context);
  if (apiAvailability.availability == Availability.none) {
    logger.info('Omitting deprecated function $funcName');
    return funcs;
  }

  final decl = Declaration(usr: funcUsr, originalName: funcName);
  final cachedFunc = context.bindingsIndex.getSeenFunc(funcUsr);
  if (cachedFunc != null) {
    funcs.add(cachedFunc);
  } else {
    logger.fine('++++ Adding Function: ${cursor.completeStringRepr()}');

    final returnType = cursor.returnType().toCodeGenType(context);

    final parameters = <Parameter>[];
    var incompleteStructParameter = false;
    var unimplementedParameterType = false;
    final totalArgs = clang.clang_Cursor_getNumArguments(cursor);
    for (var i = 0; i < totalArgs; i++) {
      final paramCursor = clang.clang_Cursor_getArgument(cursor, i);

      logger.finer('===== parameter: ${paramCursor.completeStringRepr()}');

      final paramType = paramCursor.toCodeGenType(context);
      if (paramType.isIncompleteCompound) {
        incompleteStructParameter = true;
      } else if (paramType.baseType is UnimplementedType) {
        logger.finer('Unimplemented type: ${paramType.baseType}');
        unimplementedParameterType = true;
      }

      final paramName = paramCursor.spelling();
      final objCConsumed = paramCursor.hasChildWithKind(
        clang_types.CXCursorKind.CXCursor_NSConsumed,
      );

      /// If [paramName] is null or empty, its set to `arg$i` by code_generator.
      parameters.add(
        Parameter(
          originalName: paramName,
          name: config.functionDecl.renameMember(decl, paramName),
          type: paramType,
          objCConsumed: objCConsumed,
        ),
      );
    }

    if (clang.clang_Cursor_isFunctionInlined(cursor) != 0 &&
        clang.clang_Cursor_getStorageClass(cursor) !=
            clang_types.CX_StorageClass.CX_SC_Extern) {
      logger.fine(
        '---- Removed Function, reason: inline function: '
        '${cursor.completeStringRepr()}',
      );
      logger.warning(
        "Skipped Function '$funcName', inline functions are not supported.",
      );
      // Returning empty so that [addToBindings] function excludes this.
      return funcs;
    }

    if (returnType.isIncompleteCompound || incompleteStructParameter) {
      logger.fine(
        '---- Removed Function, reason: Incomplete struct pass/return by '
        'value: ${cursor.completeStringRepr()}',
      );
      logger.warning(
        "Skipped Function '$funcName', Incomplete struct pass/return by "
        'value not supported.',
      );
      // Returning null so that [addToBindings] function excludes this.
      return funcs;
    }

    if (returnType.baseType is UnimplementedType ||
        unimplementedParameterType) {
      logger.fine(
        '---- Removed Function, reason: unsupported return type or '
        'parameter type: ${cursor.completeStringRepr()}',
      );
      logger.warning(
        "Skipped Function '$funcName', function has unsupported return type "
        'or parameter type.',
      );
      // Returning null so that [addToBindings] function excludes this.
      return funcs;
    }

    // Look for any annotations on the function.
    final objCReturnsRetained = cursor.hasChildWithKind(
      clang_types.CXCursorKind.CXCursor_NSReturnsRetained,
    );

    // Initialized with a single value with no prefix and empty var args.
    var varArgFunctions = [VarArgFunction('', [])];
    if (config.varArgFunctions.containsKey(funcName)) {
      if (clang.clang_isFunctionTypeVariadic(cursor.type()) == 1) {
        varArgFunctions = config.varArgFunctions[funcName]!;
      } else {
        logger.warning(
          'Skipping variadic-argument config for function '
          "'$funcName' since its not variadic.",
        );
      }
    }
    for (final vaFunc in varArgFunctions) {
      funcs.add(
        Func(
          dartDoc: getCursorDocComment(
            context,
            cursor,
            indent: nesting.length + commentPrefix.length,
            availability: apiAvailability.dartDoc,
          ),
          usr: funcUsr + vaFunc.postfix,
          name: config.functionDecl.rename(decl) + vaFunc.postfix,
          originalName: funcName,
          returnType: returnType,
          parameters: parameters,
          varArgParameters: vaFunc.types
              .map((ta) => Parameter(type: ta, name: 'va', objCConsumed: false))
              .toList(),
          exposeSymbolAddress: config.functionDecl.shouldIncludeSymbolAddress(
            decl,
          ),
          exposeFunctionTypedefs: config.shouldExposeFunctionTypedef(decl),
          isLeaf: config.isLeafFunction(decl),
          objCReturnsRetained: objCReturnsRetained,
          ffiNativeConfig: config.ffiNativeConfig,
        ),
      );
    }
    context.bindingsIndex.addFuncToSeen(funcUsr, funcs.last);
  }

  return funcs;
}
