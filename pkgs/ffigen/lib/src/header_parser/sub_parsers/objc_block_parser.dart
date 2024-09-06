// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../code_generator.dart';
import '../clang_bindings/clang_bindings.dart' as clang_types;
import '../data.dart';
import '../utils.dart';

ObjCBlock parseObjCBlock(clang_types.CXType cxtype) {
  // TODO(https://github.com/dart-lang/native/issues/1490): We need to figure
  // out a way of parsing ns_returns_retained and ns_consumed for blocks. Then
  // we can fill in the `objCConsumed` and `returnsRetained` fields below.
  final blk = clang.clang_getPointeeType(cxtype);
  final returnType = clang.clang_getResultType(blk).toCodeGenType();
  final params = <Parameter>[];
  final numArgs = clang.clang_getNumArgTypes(blk);
  for (var i = 0; i < numArgs; ++i) {
    final type = clang.clang_getArgType(blk, i);
    params.add(Parameter(
      name: 'arg$i',
      type: type.toCodeGenType(),
      objCConsumed: false,
    ));
  }
  return ObjCBlock(
    returnType: returnType,
    params: params,
    returnsRetained: false,
  );
}
