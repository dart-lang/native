// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../_core/interfaces/declaration.dart';
import '../../_core/interfaces/objc_annotatable.dart';

/// Describes a built-in Swift type (e.g Int, String, etc).
enum BuiltInDeclaration implements Declaration, ObjCAnnotatable {
  swiftNSObject(id: 'c:objc(cs)NSObject', name: 'NSObject'),
  swiftURL(id: 's:10Foundation3URLV', name: 'URL'),  // HACK
  swiftTimeInterval(id: 'c:@T@NSTimeInterval', name: 'TimeInterval'),  // HACK
  swiftString(id: 's:SS', name: 'String'),
  swiftInt(id: 's:Si', name: 'Int'),
  swiftFloat(id: 's:Sf', name: 'Float'),
  swiftDouble(id: 's:Sd', name: 'Double'),
  swiftBool(id: 's:Sb', name: 'Bool'),
  swiftVoid(id: 's:s4Voida', name: 'Void');

  @override
  final String id;

  @override
  final String name;

  @override
  bool get hasObjCAnnotation => true;

  const BuiltInDeclaration({
    required this.id,
    required this.name,
  });
}

final objectType = BuiltInDeclaration.swiftNSObject.asDeclaredType;
final stringType = BuiltInDeclaration.swiftString.asDeclaredType;
final intType = BuiltInDeclaration.swiftInt.asDeclaredType;
final floatType = BuiltInDeclaration.swiftFloat.asDeclaredType;
final doubleType = BuiltInDeclaration.swiftDouble.asDeclaredType;
final boolType = BuiltInDeclaration.swiftBool.asDeclaredType;
final voidType = BuiltInDeclaration.swiftVoid.asDeclaredType;
