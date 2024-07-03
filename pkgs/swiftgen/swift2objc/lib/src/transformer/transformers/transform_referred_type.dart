// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:swift2objc/src/ast/_core/interfaces/declaration.dart';
import 'package:swift2objc/src/ast/_core/shared/referred_type.dart';
import 'package:swift2objc/src/transformer/transform.dart';

DeclaredType transformReferredType(
  ReferredType referredType,
  TransformationMap transformationMap,
) {
  if (referredType is GenericType) {
    throw UnimplementedError("Generic types are not supported yet");
  }

  referredType as DeclaredType;

  if (referredType.isObjCRepresentable) return referredType;

  if (transformationMap[referredType.declaration] != null) {
    return transformationMap[referredType.declaration]!.asDeclaredType;
  }

  final transformedDeclaration = transformDeclaration(
    referredType.declaration,
    transformationMap,
  );

  transformationMap[referredType.declaration] = transformedDeclaration;

  return DeclaredType(
    id: transformedDeclaration.id,
    declaration: transformedDeclaration,
  );
}
