// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';
import '../strings.dart' as strings;
import '../visitor/ast.dart';

import 'binding_string.dart';
import 'utils.dart';
import 'writer.dart';

/// A simple Typealias, Expands to -
///
/// ```dart
/// typedef $name = $type;
/// );
/// ```
class Typealias extends BindingType {
  final Type type;
  String? _ffiDartAliasName;
  String? dartAliasName;

  /// Creates a Typealias.
  ///
  /// If [genFfiDartType] is true, a binding is generated for the Ffi Dart type
  /// in addition to the C type. See [Type.getFfiDartType].
  factory Typealias({
    String? usr,
    String? originalName,
    String? dartDoc,
    required String name,
    required Type type,
    bool genFfiDartType = false,
    bool isInternal = false,
  }) {
    final funcType = _getFunctionTypeFromPointer(type);
    if (funcType != null) {
      type = PointerType(NativeFunc(Typealias._(
        name: '${name}Function',
        type: funcType,
        genFfiDartType: genFfiDartType,
        isInternal: isInternal,
      )));
    }
    if ((originalName ?? name) == strings.objcInstanceType &&
        type is ObjCObjectPointer) {
      return ObjCInstanceType._(
        usr: usr,
        originalName: originalName,
        dartDoc: dartDoc,
        name: name,
        type: type,
        genFfiDartType: genFfiDartType,
        isInternal: isInternal,
      );
    }
    return Typealias._(
      usr: usr,
      originalName: originalName,
      dartDoc: dartDoc,
      name: name,
      type: type,
      genFfiDartType: genFfiDartType,
      isInternal: isInternal,
    );
  }

  Typealias._({
    super.usr,
    super.originalName,
    super.dartDoc,
    required String name,
    required this.type,
    bool genFfiDartType = false,
    super.isInternal,
  })  : _ffiDartAliasName = genFfiDartType ? 'Dart$name' : null,
        dartAliasName =
            (!genFfiDartType && type is! Typealias && !type.sameDartAndCType)
                ? 'Dart$name'
                : null,
        super(
          name: genFfiDartType ? 'Native$name' : name,
        );

  static FunctionType? _getFunctionTypeFromPointer(Type type) {
    if (type is! PointerType) return null;
    final pointee = type.child;
    if (pointee is! NativeFunc) return null;
    return pointee.type;
  }

  @override
  BindingString toBindingString(Writer w) {
    if (_ffiDartAliasName != null) {
      _ffiDartAliasName = w.topLevelUniqueNamer.makeUnique(_ffiDartAliasName!);
    }
    if (dartAliasName != null) {
      dartAliasName = w.topLevelUniqueNamer.makeUnique(dartAliasName!);
    }

    final sb = StringBuffer();
    sb.write(makeDartDoc(dartDoc));
    sb.write('typedef $name = ${type.getCType(w)};\n');
    if (_ffiDartAliasName != null) {
      sb.write('typedef $_ffiDartAliasName = ${type.getFfiDartType(w)};\n');
    }
    if (dartAliasName != null) {
      sb.write('typedef $dartAliasName = ${type.getDartType(w)};\n');
    }
    return BindingString(
        type: BindingStringType.typeDef, string: sb.toString());
  }

  @override
  Type get typealiasType => type.typealiasType;

  @override
  bool get isIncompleteCompound => type.isIncompleteCompound;

  @override
  String getCType(Writer w) => generateBindings ? name : type.getCType(w);

  @override
  String getNativeType({String varName = ''}) =>
      type.getNativeType(varName: varName);

  @override
  String getFfiDartType(Writer w) {
    if (generateBindings) {
      if (_ffiDartAliasName != null) {
        return _ffiDartAliasName!;
      } else if (type.sameFfiDartAndCType) {
        return name;
      }
    }
    return type.getFfiDartType(w);
  }

  @override
  String getDartType(Writer w) {
    if (generateBindings) {
      if (dartAliasName != null) {
        return dartAliasName!;
      } else if (type.sameDartAndCType) {
        return getFfiDartType(w);
      }
    }
    return type.getDartType(w);
  }

  @override
  String getObjCBlockSignatureType(Writer w) =>
      type.getObjCBlockSignatureType(w);

  @override
  bool get sameFfiDartAndCType => type.sameFfiDartAndCType;

  @override
  bool get sameDartAndCType => type.sameDartAndCType;

  @override
  bool get sameDartAndFfiDartType => type.sameDartAndFfiDartType;

  @override
  String convertDartTypeToFfiDartType(
    Writer w,
    String value, {
    required bool objCRetain,
    required bool objCAutorelease,
  }) =>
      type.convertDartTypeToFfiDartType(
        w,
        value,
        objCRetain: objCRetain,
        objCAutorelease: objCAutorelease,
      );

  @override
  String convertFfiDartTypeToDartType(
    Writer w,
    String value, {
    required bool objCRetain,
    String? objCEnclosingClass,
  }) =>
      type.convertFfiDartTypeToDartType(
        w,
        value,
        objCRetain: objCRetain,
        objCEnclosingClass: objCEnclosingClass,
      );

  @override
  String? generateRetain(String value) => type.generateRetain(value);

  @override
  String cacheKey() => type.cacheKey();

  @override
  String? getDefaultValue(Writer w) => type.getDefaultValue(w);

  @override
  void visitChildren(Visitor visitor) {
    super.visitChildren(visitor);
    visitor.visit(type);
  }

  @override
  void visit(Visitation visitation) => visitation.visitTypealias(this);

  @override
  bool isSupertypeOf(Type other) => type.isSupertypeOf(other);
}

/// Objective C's instancetype.
///
/// This is an alias for an ObjC object pointer that is special cased in code
/// generation. It's only valid as the return type of a method, and always
/// appears as the enclosing class's type, even in inherited methods.
class ObjCInstanceType extends Typealias {
  ObjCInstanceType._({
    super.usr,
    super.originalName,
    super.dartDoc,
    required super.name,
    required super.type,
    super.genFfiDartType,
    super.isInternal,
  }) : super._();

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
      objCEnclosingClass == null
          ? super.convertFfiDartTypeToDartType(
              w,
              value,
              objCRetain: objCRetain,
              objCEnclosingClass: objCEnclosingClass,
            )
          : ObjCInterface.generateConstructor(
              objCEnclosingClass, value, objCRetain);

  @override
  String getNativeType({String varName = ''}) => 'id $varName';
}
