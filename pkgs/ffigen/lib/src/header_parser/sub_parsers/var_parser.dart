// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../code_generator.dart';
import '../../config_provider/config_types.dart';
import '../../context.dart';
import '../clang_bindings/clang_bindings.dart' as clang_types;
import '../utils.dart';

/// Parses a global variable
Global? parseVarDeclaration(Context context, clang_types.CXCursor cursor) {
  final logger = context.logger;
  final config = context.config;
  final bindingsIndex = context.bindingsIndex;
  final name = cursor.spelling();
  final usr = cursor.usr();
  if (bindingsIndex.isSeenGlobalVar(usr)) {
    return bindingsIndex.getSeenGlobalVar(usr);
  }
  final decl = Declaration(usr: usr, originalName: name);

  logger.fine('++++ Adding Global: ${cursor.completeStringRepr()}');

  final cType = cursor.type();

  final type = cType.toCodeGenType(
    context,
    // Native fields can be arrays, but if we use the lookup based method of
    // reading fields there's no way to turn a Pointer into an array.
    supportNonInlineArray: config.ffiNativeConfig.enabled,
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
    exposeSymbolAddress: config.globals.shouldIncludeSymbolAddress(decl),
    constant: cType.isConstQualified,
    nativeConfig: config.ffiNativeConfig,
  );
  bindingsIndex.addGlobalVarToSeen(usr, global);

  return global;
}
