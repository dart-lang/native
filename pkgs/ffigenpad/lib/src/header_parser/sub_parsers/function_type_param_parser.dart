// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../clang_bindings/clang_types.dart';
import '../utils.dart';

/// This type holds the list of `ParmDecl` nodes of a function type declaration.
class FunctionTypeParams {
  final List<String> paramNames;
  final Map<String, CXCursor> params;
  FunctionTypeParams()
      : paramNames = [],
        params = {};
}

/// Returns `ParmDecl` nodes of function pointer declaration
/// directly or indirectly pointed to by [cursor].
FunctionTypeParams parseFunctionPointerParamNames(CXCursor cursor) {
  final params = FunctionTypeParams();
  cursor.visitChildrenMayRecurse((child, parent) {
    if (child.kind == CXCursorKind.CXCursor_ParmDecl) {
      final spelling = child.spelling();
      if (spelling.isNotEmpty) {
        params.paramNames.add(spelling);
        params.params[spelling] = child;
        return CXChildVisitResult.CXChildVisit_Continue;
      } else {
        // A parameter's spelling is empty, do not continue further traversal.
        params.paramNames.clear();
        params.params.clear();
        return CXChildVisitResult.CXChildVisit_Break;
      }
    }
    // The cursor itself may be a pointer etc..
    return CXChildVisitResult.CXChildVisit_Recurse;
  });
  return params;
}
