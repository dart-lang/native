// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/header_parser/data.dart';

import '../clang_bindings/clang_bindings.dart' as clang_types;
import '../utils.dart';

ObjCBlock parseObjCBlock(clang_types.CXType cxtype) {
  final blk = clang.clang_getPointeeType(cxtype);
  final returnType = clang.clang_getResultType(blk).toCodeGenType();
  final argTypes = <Type>[];
  final numArgs = clang.clang_getNumArgTypes(blk);
  for (var i = 0; i < numArgs; ++i) {
    argTypes.add(clang.clang_getArgType(blk, i).toCodeGenType());
  }
  return ObjCBlock(
    returnType: returnType,
    argTypes: argTypes,
  );
}
