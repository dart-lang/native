// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../code_generator.dart';
import '../clang_bindings/clang_types.dart' as clang_types;
import '../data.dart';
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
