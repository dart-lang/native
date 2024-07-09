// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:swift2objc/src/ast/_core/interfaces/declaration.dart';
import 'package:swift2objc/src/ast/_core/shared/referred_type.dart';
import 'package:swift2objc/src/transformer/_core/unique_namer.dart';
import 'package:swift2objc/src/transformer/transform.dart';

DeclaredType transformReferredType(
  ReferredType referredType,
  UniqueNamer globalNamer,
  TransformationMap transformationMap,
) {
  if (referredType is GenericType) {
    throw UnimplementedError("Generic types are not supported yet");
  }

  referredType as DeclaredType;

  if (referredType.isObjCRepresentable) return referredType;

  final transformedDeclaration = transformDeclaration(
    referredType.declaration,
    globalNamer,
    transformationMap,
  );

  transformationMap[referredType.declaration] = transformedDeclaration;

  return transformedDeclaration.asDeclaredType;
}
