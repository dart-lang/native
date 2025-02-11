// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../../parser/_core/utils.dart';
import '../../../transformer/transform.dart';
import '../../../transformer/transformers/transform_compound.dart';
import '../../_core/interfaces/declaration.dart';
import '../../_core/interfaces/objc_annotatable.dart';
import '../../_core/shared/referred_type.dart';
import '../../ast_node.dart';
import '../compounds/class_declaration.dart';
import '../compounds/members/property_declaration.dart';

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

final primitiveWrappers = <ReferredType, ReferredType>{
  intType: _createWrapperClass(intType),
  floatType: _createWrapperClass(floatType),
  doubleType: _createWrapperClass(doubleType),
  boolType: _createWrapperClass(boolType),
};

ReferredType _createWrapperClass(DeclaredType primitiveType) {
  final property = PropertyDeclaration(
    id: primitiveType.id.addIdSuffix('wrappedInstance'),
    name: 'wrappedInstance',
    type: primitiveType,
  );
  return ClassDeclaration(
          id: primitiveType.id.addIdSuffix('wrapper'),
          name: '${primitiveType.name}Wrapper',
          hasObjCAnnotation: true,
          superClass: objectType,
          isWrapper: true,
          wrappedInstance: property,
          wrapperInitializer: buildWrapperInitializer(property))
      .asDeclaredType;
}

// Support Optional primitives as return Type
// TODO(https://github.com/dart-lang/native/issues/1743)

(ReferredType, bool) getWrapperIfNeeded(ReferredType type, bool isThrows) {
  if (type is! DeclaredType || !isPrimitiveType(type) || !isThrows) {
    return (type, false);
  }

  final wrapper = getPrimitiveWrapper(type);
  primitiveWrapperClasses.add((wrapper as DeclaredType).declaration);
  return (wrapper, true);
}

ReferredType getPrimitiveWrapper(DeclaredType other) {
  return primitiveWrappers.entries
      .firstWhere(
        (entry) => entry.key.sameAs(other),
      )
      .value;
}

bool isPrimitiveType(DeclaredType type) {
  return type.name == 'Int' ||
      type.name == 'Float' ||
      type.name == 'Double' ||
      type.name == 'Bool';
}
