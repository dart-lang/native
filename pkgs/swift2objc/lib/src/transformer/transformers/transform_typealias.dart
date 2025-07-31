// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../ast/_core/interfaces/compound_declaration.dart';
import '../../ast/_core/interfaces/declaration.dart';
import '../../ast/_core/interfaces/nestable_declaration.dart';
import '../../ast/declarations/built_in/built_in_declaration.dart';
import '../../ast/declarations/typealias_declaration.dart';
import '../../parser/_core/utils.dart';
import '../_core/unique_namer.dart';
import '../_core/utils.dart';
import '../transform.dart';
import 'transform_referred_type.dart';

TypealiasDeclaration? transformTypealias(
  TypealiasDeclaration originalTypealias,
  UniqueNamer parentNamer,
  TransformationMap transformationMap,
) =>
    transformationMap[originalTypealias] = _transformTypealias(
      originalTypealias,
      parentNamer,
      transformationMap,
    );

TypealiasDeclaration? _transformTypealias(
  TypealiasDeclaration originalTypealias,
  UniqueNamer parentNamer,
  TransformationMap transformationMap,
) {
  if (originalTypealias.target.isObjCRepresentable) return null;

  // return TypealiasDeclaration(
  //   id: originalTypealias.id.addIdSuffix('wrapper'),
  //   name: parentNamer.makeUnique(
  //     '${originalTypealias.name}Wrapper',
  //   ),
  //   target: transformReferredType(
  //     originalTypealias.target,
  //     parentNamer,
  //     transformationMap,
  //   ),
  // );
  return transformReferredType(
    originalTypealias.target,
    parentNamer,
    transformationMap,
  );
}
