// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../code_generator.dart';
import '../../context.dart';
import '../clang_bindings/clang_bindings.dart' as clang_types;
import '../utils.dart';

ObjCBlock parseObjCBlock(Context context, clang_types.CXType cxtype) {
  // TODO(https://github.com/dart-lang/native/issues/1490): We need to figure
  // out a way of parsing ns_returns_retained and ns_consumed for blocks. Then
  // we can fill in the `objCConsumed` and `returnsRetained` fields below.
  final blk = clang.clang_getPointeeType(cxtype);
  final returnType = clang.clang_getResultType(blk).toCodeGenType(context);
  final params = <Parameter>[];
  final numArgs = clang.clang_getNumArgTypes(blk);
  for (var i = 0; i < numArgs; ++i) {
    final type = clang.clang_getArgType(blk, i);
    params.add(
      Parameter(type: type.toCodeGenType(context), objCConsumed: false),
    );
  }
  return ObjCBlock(
    context,
    returnType: returnType,
    params: params,
    returnsRetained: false,
  );
}
