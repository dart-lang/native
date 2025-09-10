// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';
import '../context.dart';
import '../visitor/ast.dart';

/// An ObjC type annotated with nullable. Eg:
/// +(nullable NSObject*) methodWithNullableResult;
class ObjCNullable extends Type {
  Type child;

  ObjCNullable(this.child)
    : assert(
        isSupported(child),
        'Nullable ${child.typealiasType.runtimeType} is not supported',
      );

  static bool isSupported(Type type) => _isSupported(type.typealiasType);
  static bool _isSupported(Type type) =>
      type is ObjCInterface ||
      type is ObjCBlock ||
      type is ObjCObjectPointer ||
      type is ObjCInstanceType;

  @override
  Type get baseType => child.baseType;

  @override
  String getCType(Context context) => child.getCType(context);

  @override
  String getFfiDartType(Context context) => child.getFfiDartType(context);

  @override
  String getDartType(Context context) => '${child.getDartType(context)}?';

  @override
  String getNativeType({String varName = ''}) =>
      child.getNativeType(varName: varName);

  @override
  String getObjCBlockSignatureType(Context context) =>
      '${child.getObjCBlockSignatureType(context)}?';

  @override
  bool get sameFfiDartAndCType => child.sameFfiDartAndCType;

  @override
  bool get sameDartAndCType => false;

  @override
  bool get sameDartAndFfiDartType => false;

  @override
  String convertDartTypeToFfiDartType(
    Context context,
    String value, {
    required bool objCRetain,
    required bool objCAutorelease,
  }) {
    // Just appending `?` to `value` like this is a bit of a hack, but works for
    // all the types that are allowed to be a child type. If we add more allowed
    // child types, we may have to start special casing each type. For example,
    // `value.pointer` becomes `value?.pointer ?? nullptr`.
    final convertedValue = child.convertDartTypeToFfiDartType(
      context,
      '$value?',
      objCRetain: objCRetain,
      objCAutorelease: objCAutorelease,
    );
    return '$convertedValue ?? ${context.libs.prefix(ffiImport)}.nullptr';
  }

  @override
  String convertFfiDartTypeToDartType(
    Context context,
    String value, {
    required bool objCRetain,
    String? objCEnclosingClass,
  }) {
    // All currently supported child types have a Pointer as their FfiDartType.
    final convertedValue = child.convertFfiDartTypeToDartType(
      context,
      value,
      objCRetain: objCRetain,
      objCEnclosingClass: objCEnclosingClass,
    );
    return '$value.address == 0 ? null : $convertedValue';
  }

  @override
  String? generateRetain(String value) => child.generateRetain(value);

  @override
  String toString() => '$child?';

  @override
  String cacheKey() => '${child.cacheKey()}?';

  @override
  void visitChildren(Visitor visitor) {
    super.visitChildren(visitor);
    visitor.visit(child);
    visitor.visit(ffiImport);
  }

  @override
  bool isSupertypeOf(Type other) {
    other = other.typealiasType;

    if (other is ObjCNullable) {
      // T? :> S? if T :> S
      return child.isSupertypeOf(other.child);
    } else {
      // T? :> S if T :> S
      return child.isSupertypeOf(other);
    }
  }
}
