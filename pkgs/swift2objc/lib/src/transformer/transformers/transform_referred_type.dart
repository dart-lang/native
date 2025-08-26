// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../ast/_core/interfaces/declaration.dart';
import '../../ast/_core/shared/referred_type.dart';
import '../../ast/declarations/typealias_declaration.dart';
import '../_core/unique_namer.dart';
import '../transform.dart';

// TODO(https://github.com/dart-lang/native/issues/1358): Refactor this as a
// transformer or visitor.

ReferredType transformReferredType(
  ReferredType type,
  UniqueNamer globalNamer,
  TransformationState state,
) {
  if (type.isObjCRepresentable) return type;

  if (type is GenericType) {
    throw UnimplementedError('Generic types are not supported yet');
  } else if (type is DeclaredType) {
    final decl = type.declaration;
    if (decl is TypealiasDeclaration) {
      return transformReferredType(decl.target, globalNamer, state);
    }
    return transformDeclaration(decl, globalNamer, state).asDeclaredType;
  } else if (type is OptionalType) {
    return OptionalType(transformReferredType(type.child, globalNamer, state));
  } else {
    throw UnimplementedError('Unknown type: $type');
  }
}
