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
import 'transform_function.dart';
import 'transform_initializer.dart';
import 'transform_variable.dart';

TypealiasDeclaration transformTypealias(
  TypealiasDeclaration originalTypealias,
  UniqueNamer parentNamer,
  TransformationMap transformationMap,
) {
  // Transform it if the target is not objc representable.
  return originalTypealias;
}
