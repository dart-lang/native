// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../_core/interfaces/declaration.dart';
import '../../_core/interfaces/objc_annotatable.dart';

/// Describes a built-in Swift type (e.g Int, String, etc).
enum BuiltInDeclaration implements Declaration, ObjCAnnotatable {
  swiftNSObject(id: 'c:objc(cs)NSObject', name: 'NSObject'),
  swiftString(id: 's:SS', name: 'String'),
  swiftInt(id: 's:Si', name: 'Int'),
  swiftDouble(id: 's:Sd', name: 'Double'),
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
