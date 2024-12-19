// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../_core/interfaces/declaration.dart';
import '../../_core/interfaces/objc_annotatable.dart';
import '../../ast_node.dart';

/// Describes a built-in Swift type (e.g Int, String, etc).
class BuiltInDeclaration extends AstNode
    implements Declaration, ObjCAnnotatable {
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

  @override
  void visit(Visitation visitation) => visitation.visitBuiltInDeclaration(this);
}

const _objectDecl =
    BuiltInDeclaration(id: 'c:objc(cs)NSObject', name: 'NSObject');
const _stringDecl = BuiltInDeclaration(id: 's:SS', name: 'String');
const _intDecl = BuiltInDeclaration(id: 's:Si', name: 'Int');
const _floatDecl = BuiltInDeclaration(id: 's:Sf', name: 'Float');
const _doubleDecl = BuiltInDeclaration(id: 's:Sd', name: 'Double');
const _boolDecl = BuiltInDeclaration(id: 's:Sb', name: 'Bool');
const _voidDecl = BuiltInDeclaration(id: 's:s4Voida', name: 'Void');

const builtInDeclarations = [
  _objectDecl,
  _stringDecl,
  _intDecl,
  _floatDecl,
  _doubleDecl,
  _boolDecl,
  _voidDecl,
];

final objectType = _objectDecl.asDeclaredType;
final stringType = _stringDecl.asDeclaredType;
final intType = _intDecl.asDeclaredType;
final floatType = _floatDecl.asDeclaredType;
final doubleType = _doubleDecl.asDeclaredType;
final boolType = _boolDecl.asDeclaredType;
final voidType = _voidDecl.asDeclaredType;
