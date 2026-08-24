// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../code_generator.dart';
import '../../config_provider/config.dart';
import '../../context.dart';
import '../clang_bindings/clang_bindings.dart' as clang_types;
import '../utils.dart';
import 'api_availability.dart';

/// Parses a function declaration.
Func? parseFunctionDeclaration(Context context, clang_types.CXCursor cursor) {
  final config = context.config;
  final logger = context.logger;

  final funcUsr = cursor.usr();
  final funcName = cursor.spelling();

  final apiAvailability = ApiAvailability.fromCursor(cursor, context);
  if (apiAvailability.availability == Availability.none) {
    logger.info('Omitting deprecated function $funcName');
    return null;
  }

  final cachedFunc = context.bindingsIndex.getSeenFunc(funcUsr);
  if (cachedFunc != null) {
    return cachedFunc;
  }

  logger.fine('++++ Adding Function: ${cursor.completeStringRepr()}');

  final returnType = cursor.returnType().toCodeGenType(context);

  final (:parameters, :hasIncompleteStruct, :hasUnimplementedType) =
      parseParameters(context, cursor);

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
    // Returning null so that [addToBindings] function excludes this.
    return null;
  }

  if (returnType.isIncompleteCompound || hasIncompleteStruct) {
    logger.fine(
      '---- Removed Function, reason: Incomplete struct pass/return by '
      'value: ${cursor.completeStringRepr()}',
    );
    logger.warning(
      "Skipped Function '$funcName', Incomplete struct pass/return by "
      'value not supported.',
    );
    // Returning null so that [addToBindings] function excludes this.
    return null;
  }

  if (returnType.baseType is UnimplementedType || hasUnimplementedType) {
    logger.fine(
      '---- Removed Function, reason: unsupported return type or '
      'parameter type: ${cursor.completeStringRepr()}',
    );
    logger.warning(
      "Skipped Function '$funcName', function has unsupported return type "
      'or parameter type.',
    );
    // Returning null so that [addToBindings] function excludes this.
    return null;
  }

  // Look for any annotations on the function.
  final objCReturnsRetained = cursor.hasChildWithKind(
    clang_types.CXCursorKind.CXCursor_NSReturnsRetained,
  );

  final isVariadic = clang.clang_isFunctionTypeVariadic(cursor.type()) == 1;
  final func = Func(
    dartDoc: getCursorDocComment(
      context,
      cursor,
      indent: nesting.length + commentPrefix.length,
      availability: apiAvailability.dartDoc,
    ),
    usr: funcUsr,
    name: funcName,
    originalName: funcName,
    returnType: returnType,
    parameters: parameters.map((p) => p.clone()).toList(),
    varArgParameters: const [],
    objCReturnsRetained: objCReturnsRetained,
    loadFromNativeAsset: config.output.style is NativeExternalBindings,
    apiAvailability: apiAvailability,
    isVariadic: isVariadic,
  );
  context.bindingsIndex.addFuncToSeen(funcUsr, func);

  return func;
}

({
  List<Parameter> parameters,
  bool hasIncompleteStruct,
  bool hasUnimplementedType,
})
parseParameters(
  Context context,
  clang_types.CXCursor cursor, {
  String Function(String)? renameFn,
}) {
  final parameters = <Parameter>[];
  var incompleteStructParameter = false;
  var unimplementedParameterType = false;
  final totalArgs = clang.clang_Cursor_getNumArguments(cursor);
  for (var i = 0; i < totalArgs; i++) {
    final paramCursor = clang.clang_Cursor_getArgument(cursor, i);
    context.logger.finer(
      '===== parameter: ${paramCursor.completeStringRepr()}',
    );
    final paramType = paramCursor.toCodeGenType(context);
    if (paramType.isIncompleteCompound) {
      incompleteStructParameter = true;
    } else if (paramType.baseType is UnimplementedType) {
      context.logger.finer('Unimplemented type: ${paramType.baseType}');
      unimplementedParameterType = true;
    }
    final spelling = paramCursor.spelling();
    final name = spelling.isEmpty ? 'arg$i' : spelling;
    final objCConsumed = paramCursor.hasChildWithKind(
      clang_types.CXCursorKind.CXCursor_NSConsumed,
    );
    parameters.add(
      Parameter(
        originalName: spelling,
        name: name,
        type: paramType,
        objCConsumed: objCConsumed,
      ),
    );
  }
  return (
    parameters: parameters,
    hasIncompleteStruct: incompleteStructParameter,
    hasUnimplementedType: unimplementedParameterType,
  );
}
