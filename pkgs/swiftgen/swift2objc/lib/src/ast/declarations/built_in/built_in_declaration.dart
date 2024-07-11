// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:swift2objc/src/ast/_core/interfaces/objc_annotatable.dart';

import '../../_core/interfaces/declaration.dart';
import '../../_core/interfaces/type_parameterizable.dart';
import '../../_core/shared/referred_type.dart';

/// Describes a built-in Swift type (e.g Int, String, etc).
class BuiltInDeclaration
    implements Declaration, TypeParameterizable, ObjCAnnotatable {
  @override
  final String id;

  @override
  final String name;

  @override
  final List<GenericType> typeParams;

  final bool hasObjCAnnotation;

  const BuiltInDeclaration({
    required this.id,
    required this.name,
    this.typeParams = const [],
    this.hasObjCAnnotation = true,
  });
}

/// Contains built-in Swift type (e.g Int, String, etc).
abstract class BuiltInDeclarations {
  static const NSObject = BuiltInDeclaration(
    id: "c:objc(cs)NSObject",
    name: "NSObject",
  );

  static const String = BuiltInDeclaration(id: "s:SS", name: "String");

  static const Int = BuiltInDeclaration(id: "s:Si", name: "Int");

  static const Double = BuiltInDeclaration(id: "s:Sd", name: "Double");

  static const Void = BuiltInDeclaration(id: "s:s4Voida", name: "Void");

  static const declarations = [NSObject, String, Int, Double, Void];
}
