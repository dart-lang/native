// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../../_core/interfaces/declaration.dart';
import '../../../_core/interfaces/objc_annotatable.dart';
import '../../../_core/shared/referred_type.dart';

/// Describes a property declaration for a Swift compound entity
/// (e.g, class, structs)
class PropertyDeclaration implements Declaration, ObjCAnnotatable {
  @override
  String id;

  @override
  String name;

  @override
  bool hasObjCAnnotation;

  bool hasSetter;
  List<String> getterStatements;
  List<String> setterStatements;

  ReferredType type;

  PropertyDeclaration({
    required this.id,
    required this.name,
    required this.type,
    this.hasSetter = false,
    this.hasObjCAnnotation = false,
    this.getterStatements = const [],
    this.setterStatements = const [],
  });
}
