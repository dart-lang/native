// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';
import '../visitor/ast.dart';

import 'writer.dart';

/// Represents a pointer.
class PointerType extends Type {
  final Type child;

  PointerType._(this.child);

  factory PointerType(Type child) {
    if (child == objCObjectType) {
      return ObjCObjectPointer();
    } else if (child == objCBlockType) {
      return ObjCBlockPointer();
    }
    return PointerType._(child);
  }

  @override
  Type get baseType => child.baseType;

  @override
  String getCType(Writer w) =>
      '${w.ffiLibraryPrefix}.Pointer<${child.getCType(w)}>';

  @override
  String getNativeType({String varName = ''}) =>
      '${child.getNativeType()}* $varName';

  // Both the C type and the FFI Dart type are 'Pointer<$cType>'.
  @override
  bool get sameFfiDartAndCType => true;

  @override
  String toString() => '$child*';

  @override
  String cacheKey() => '${child.cacheKey()}*';

  @override
  void visitChildren(Visitor visitor) {
    super.visitChildren(visitor);
    visitor.visit(child);
  }

  @override
  void visit(Visitation visitation) => visitation.visitPointerType(this);

  @override
  bool isSupertypeOf(Type other) {
    other = other.typealiasType;
    if (other is PointerType) {
      return child.isSupertypeOf(other.child);
    }
    return false;
  }
}

/// Represents a constant array, which has a fixed size.
class ConstantArray extends PointerType {
  final int length;
  final bool useArrayType;

  ConstantArray(this.length, Type child, {required this.useArrayType})
      : super._(child);

  @override
  Type get baseArrayType => child.baseArrayType;

  @override
  bool get isIncompleteCompound => baseArrayType.isIncompleteCompound;

  @override
  String getNativeType({String varName = ''}) =>
      '${child.getNativeType()} $varName[$length]';

  @override
  String toString() => '$child[$length]';

  @override
  String cacheKey() => '${child.cacheKey()}[$length]';

  @override
  String getCType(Writer w) {
    if (useArrayType) {
      return '${w.ffiLibraryPrefix}.Array<${child.getCType(w)}>';
    }

    return super.getCType(w);
  }
}

/// Represents an incomplete array, which has an unknown size.
class IncompleteArray extends PointerType {
  IncompleteArray(super.child) : super._();

  @override
  Type get baseArrayType => child.baseArrayType;

  @override
  String getNativeType({String varName = ''}) =>
      '${child.getNativeType()}* $varName';

  @override
  String toString() => '$child[]';

  @override
  String cacheKey() => '${child.cacheKey()}[]';
}

/// A pointer to an Objective C object.
class ObjCObjectPointer extends PointerType {
  factory ObjCObjectPointer() => _inst;

  static final _inst = ObjCObjectPointer._();
  ObjCObjectPointer.__(super.child) : super._();
  ObjCObjectPointer._() : super._(objCObjectType);

  @override
  String getDartType(Writer w) => '${w.objcPkgPrefix}.ObjCObjectBase';

  @override
  String getNativeType({String varName = ''}) => 'id $varName';

  @override
  bool get sameDartAndCType => false;

  @override
  bool get sameDartAndFfiDartType => false;

  @override
  String convertDartTypeToFfiDartType(
    Writer w,
    String value, {
    required bool objCRetain,
    required bool objCAutorelease,
  }) =>
      ObjCInterface.generateGetId(value, objCRetain, objCAutorelease);

  @override
  String convertFfiDartTypeToDartType(
    Writer w,
    String value, {
    required bool objCRetain,
    String? objCEnclosingClass,
  }) =>
      '${getDartType(w)}($value, retain: $objCRetain, release: true)';

  @override
  String? generateRetain(String value) => 'objc_retain($value)';

  @override
  bool isSupertypeOf(Type other) {
    other = other.typealiasType;
    // id/Object* is a supertype of all ObjC objects and blocks.
    return other is ObjCObjectPointer ||
        other is ObjCInterface ||
        other is ObjCBlock;
  }
}

/// A pointer to an Objective C block.
class ObjCBlockPointer extends ObjCObjectPointer {
  factory ObjCBlockPointer() => _inst;

  static final _inst = ObjCBlockPointer._();
  ObjCBlockPointer._() : super.__(objCBlockType);

  @override
  String getDartType(Writer w) => '${w.objcPkgPrefix}.ObjCBlockBase';

  @override
  String? generateRetain(String value) => 'objc_retainBlock($value)';

  @override
  bool isSupertypeOf(Type other) {
    other = other.typealiasType;
    return other is ObjCBlockPointer || other is ObjCBlock;
  }
}
