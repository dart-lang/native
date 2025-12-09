// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../code_generator.dart';
import '../../config_provider/config.dart';
import '../../config_provider/config_types.dart';
import '../../context.dart';
import '../clang_bindings/clang_bindings.dart' as clang_types;
import '../utils.dart';

/// Parses a global variable
Binding? parseVarDeclaration(Context context, clang_types.CXCursor cursor) {
  final logger = context.logger;
  final config = context.config;
  final nativeOutputStyle = config.output.style is NativeExternalBindings;
  final bindingsIndex = context.bindingsIndex;
  final name = cursor.spelling();
  final usr = cursor.usr();

  if (bindingsIndex.isSeenGlobalVar(usr)) {
    return bindingsIndex.getSeenGlobalVar(usr);
  }
  if (bindingsIndex.isSeenVariableConstant(usr)) {
    return bindingsIndex.getSeenVariableConstant(usr);
  }

  final decl = Declaration(usr: usr, originalName: name);
  final cType = cursor.type();

  // Try to evaluate as a constant first.
  if (cType.isConstQualified) {
    final evalResult = clang.clang_Cursor_Evaluate(cursor);
    final evalKind = clang.clang_EvalResult_getKind(evalResult);
    Constant? constant;

    switch (evalKind) {
      case clang_types.CXEvalResultKind.CXEval_Int:
        final value = clang.clang_EvalResult_getAsLongLong(evalResult);
        constant = Constant(
          usr: usr,
          originalName: name,
          name: config.globals.rename(decl),
          dartDoc: getCursorDocComment(context, cursor),
          rawType: 'int',
          rawValue: value.toString(),
        );
        break;
      case clang_types.CXEvalResultKind.CXEval_Float:
        final value = clang.clang_EvalResult_getAsDouble(evalResult);
        constant = Constant(
          usr: usr,
          originalName: name,
          name: config.globals.rename(decl),
          dartDoc: getCursorDocComment(context, cursor),
          rawType: 'double',
          rawValue: writeDoubleAsString(value),
        );
        break;
      case clang_types.CXEvalResultKind.CXEval_StrLiteral:
        final value = clang.clang_EvalResult_getAsStr(evalResult);
        final rawValue = getWrittenStringRepresentation(name, value, context);
        constant = Constant(
          usr: usr,
          originalName: name,
          name: config.globals.rename(decl),
          dartDoc: getCursorDocComment(context, cursor),
          rawType: 'String',
          rawValue: "'$rawValue'",
        );
        break;
    }
    clang.clang_EvalResult_dispose(evalResult);

    if (constant != null) {
      logger.fine(
        '++++ Adding Constant from Global: ${cursor.completeStringRepr()}',
      );
      bindingsIndex.addVariableConstantToSeen(usr, constant);
      return constant;
    }
  }

  logger.fine('++++ Adding Global: ${cursor.completeStringRepr()}');

  final type = cType.toCodeGenType(
    context,
    // Native fields can be arrays, but if we use the lookup based method of
    // reading fields there's no way to turn a Pointer into an array.
    supportNonInlineArray: nativeOutputStyle,
  );
  if (type.baseType is UnimplementedType) {
    logger.fine(
      '---- Removed Global, reason: unsupported type: '
      '${cursor.completeStringRepr()}',
    );
    logger.warning("Skipped global variable '$name', type not supported.");
    return null;
  }

  final global = Global(
    originalName: name,
    name: config.globals.rename(decl),
    usr: usr,
    type: type,
    dartDoc: getCursorDocComment(context, cursor),
    exposeSymbolAddress: config.globals.includeSymbolAddress(decl),
    constant: cType.isConstQualified,
    loadFromNativeAsset: nativeOutputStyle,
  );
  bindingsIndex.addGlobalVarToSeen(usr, global);

  return global;
}
