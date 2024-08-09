// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:logging/logging.dart';

import '../../code_generator.dart';
import '../../config_provider/config_types.dart';
import '../clang_bindings/clang_types.dart' as clang_types;
import '../data.dart';
import '../includer.dart';
import '../utils.dart';

final _logger = Logger('ffigen.header_parser.var_parser');

/// Parses a global variable
Global? parseVarDeclaration(clang_types.CXCursor cursor) {
  final name = cursor.spelling();
  final usr = cursor.usr();
  if (bindingsIndex.isSeenGlobalVar(usr)) {
    return bindingsIndex.getSeenGlobalVar(usr);
  }
  final decl = Declaration(usr: usr, originalName: name);
  if (!shouldIncludeGlobalVar(decl)) {
    return null;
  }

  _logger.fine('++++ Adding Global: ${cursor.completeStringRepr()}');

  final cType = cursor.type();

  final type = cType.toCodeGenType(
      // Native fields can be arrays, but if we use the lookup based method of
      // reading fields there's no way to turn a Pointer into an array.
      supportNonInlineArray: config.ffiNativeConfig.enabled);
  if (type.baseType is UnimplementedType) {
    _logger.fine('---- Removed Global, reason: unsupported type: '
        '${cursor.completeStringRepr()}');
    _logger.warning("Skipped global variable '$name', type not supported.");
    return null;
  }

  final global = Global(
    originalName: name,
    name: config.globals.rename(decl),
    usr: usr,
    type: type,
    dartDoc: getCursorDocComment(cursor),
    exposeSymbolAddress: config.globals.shouldIncludeSymbolAddress(decl),
    constant: cType.isConstQualified,
    nativeConfig: config.ffiNativeConfig,
  );
  bindingsIndex.addGlobalVarToSeen(usr, global);

  return global;
}
