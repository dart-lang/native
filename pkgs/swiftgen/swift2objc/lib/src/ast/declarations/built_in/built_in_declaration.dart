// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../_core/interfaces/declaration.dart';
import '../../_core/interfaces/objc_annotatable.dart';
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

  @override
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
  static const swiftNSObject = BuiltInDeclaration(
    id: 'c:objc(cs)NSObject',
    name: 'NSObject',
  );

  static const swiftString = BuiltInDeclaration(id: 's:SS', name: 'String');

  static const swiftInt = BuiltInDeclaration(id: 's:Si', name: 'Int');

  static const swiftDouble = BuiltInDeclaration(id: 's:Sd', name: 'Double');

  static const swiftVoid = BuiltInDeclaration(id: 's:s4Voida', name: 'Void');

  static const declarations = [
    swiftNSObject,
    swiftString,
    swiftInt,
    swiftDouble,
    swiftVoid
  ];
}
