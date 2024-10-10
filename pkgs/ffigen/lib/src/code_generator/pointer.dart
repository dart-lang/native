// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';

import 'ast.dart';
import 'writer.dart';

/// Represents a pointer.
class PointerType extends Type {
  Type child;

  PointerType._(this.child);

  factory PointerType(Type child) {
    if (child == objCObjectType) {
      return ObjCObjectPointer();
    }
    return PointerType._(child);
  }

  @override
  void addDependencies(Set<Binding> dependencies) {
    child.addDependencies(dependencies);
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
  void transformChildren(Transformer transformer) {
    super.transformChildren(transformer);
    child = transformer.transform(child);
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
      '${child.getNativeType()} $varName[]';

  @override
  String toString() => '$child[]';

  @override
  String cacheKey() => '${child.cacheKey()}[]';
}

/// A pointer to an Objective C object.
class ObjCObjectPointer extends PointerType {
  factory ObjCObjectPointer() => _inst;

  static final _inst = ObjCObjectPointer._();
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
}
