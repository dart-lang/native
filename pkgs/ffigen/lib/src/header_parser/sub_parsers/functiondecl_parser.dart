// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../code_generator.dart';
import '../../config_provider/config.dart';
import '../../config_provider/config_types.dart';
import '../../context.dart';
import '../../strings.dart';
import '../clang_bindings/clang_bindings.dart' as clang_types;
import '../utils.dart';
import 'api_availability.dart';

/// Parses a function declaration.
void parseFunctionDeclaration(Context context, clang_types.CXCursor cursor) {
  final config = context.config;
  final logger = context.logger;

  final funcUsr = cursor.usr();
  final funcName = cursor.spelling();

  final apiAvailability = ApiAvailability.fromCursor(cursor, context);
  if (apiAvailability.availability == Availability.none) {
    logger.info('Omitting deprecated function $funcName');
    return;
  }

  final decl = Declaration(usr: funcUsr, originalName: funcName);
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

    parameters.add(
      Parameter(
        originalName: paramName,
        name: config.functions.renameMember(decl, paramName),
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
    return;
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
    return;
  }

  if (returnType.baseType is UnimplementedType || unimplementedParameterType) {
    logger.fine(
      '---- Removed Function, reason: unsupported return type or '
      'parameter type: ${cursor.completeStringRepr()}',
    );
    logger.warning(
      "Skipped Function '$funcName', function has unsupported return type "
      'or parameter type.',
    );
    return;
  }

  // Look for any annotations on the function.
  final objCReturnsRetained = cursor.hasChildWithKind(
    clang_types.CXCursorKind.CXCursor_NSReturnsRetained,
  );

  // Initialized with a single value with no prefix and empty var args.
  var varArgFunctions = <VarArgFunction?>[null];
  if (config.functions.varArgs.containsKey(funcName)) {
    if (clang.clang_isFunctionTypeVariadic(cursor.type()) == 1) {
      varArgFunctions = config.functions.varArgs[funcName]!;
    } else {
      logger.warning(
        'Skipping variadic-argument config for function '
        "'$funcName' since its not variadic.",
      );
    }
  }

  for (final vaFunc in varArgFunctions) {
    var usr = funcUsr;
    if (vaFunc != null) usr += '$synthUsrChar vaFunc: ${vaFunc.postfix}';
    context.bindingsIndex.fillBinding(
      Func(
        dartDoc: getCursorDocComment(
          context,
          cursor,
          indent: nesting.length + commentPrefix.length,
          availability: apiAvailability.dartDoc,
        ),
        usr: usr,
        name: config.functions.rename(decl) + (vaFunc?.postfix ?? ''),
        originalName: funcName,
        returnType: returnType,
        parameters: parameters,
        varArgParameters: [
          for (final ta in vaFunc?.types ?? const <Type>[])
            Parameter(type: ta, name: 'va', objCConsumed: false),
        ],
        exposeSymbolAddress: config.functions.includeSymbolAddress(decl),
        exposeFunctionTypedefs: config.functions.includeTypedef(decl),
        isLeaf: config.functions.isLeaf(decl),
        objCReturnsRetained: objCReturnsRetained,
        loadFromNativeAsset: config.ffiNativeConfig.enabled,
      ),
    );
  }
}
