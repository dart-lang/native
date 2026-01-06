// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';
import '../context.dart';
import '../strings.dart' as strings;
import '../visitor/ast.dart';
import 'binding_string.dart';
import 'scope.dart';
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
  Symbol? _ffiDartAliasName;
  Symbol? dartAliasName;
  bool isAnonymous;

  // Don't code gen this alias at all, just use the [type] directly.
  bool isAnonymous;

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
      type = PointerType(
        NativeFunc(
          Typealias._(
            name: '${name}Function',
            type: funcType,
            genFfiDartType: genFfiDartType,
            isInternal: isInternal,
          ),
        ),
      );
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

  Typealias.anonymous({
    required String usr,
    required String name,
    required Type type,
  }) : this._(usr: usr, name: name, type: type, isAnonymous: true);

  Typealias._({
    super.usr,
    super.originalName,
    super.dartDoc,
    required String name,
    required this.type,
    bool genFfiDartType = false,
    super.isInternal,
    this.isAnonymous = false,
  }) : _ffiDartAliasName = genFfiDartType
           ? Symbol('Dart$name', SymbolKind.klass)
           : null,
       dartAliasName =
           (!genFfiDartType && type is! Typealias && !type.sameDartAndCType)
           ? Symbol('Dart$name', SymbolKind.klass)
           : null,
       super(name: genFfiDartType ? 'Native$name' : name);

  static FunctionType? _getFunctionTypeFromPointer(Type type) {
    if (type is! PointerType) return null;
    final pointee = type.child;
    if (pointee is! NativeFunc) return null;
    return pointee.type;
  }

  @override
  BindingString toBindingString(Writer w) {
    assert(!isAnonymous);
    final context = w.context;
    final sb = StringBuffer();
    sb.write(makeDartDoc(dartDoc));
    sb.write('typedef $name = ${type.getCType(context)};\n');
    if (_ffiDartAliasName != null) {
      final ffiDartType = type.getFfiDartType(context);
      sb.write('typedef ${_ffiDartAliasName!.name} = $ffiDartType;\n');
    }
    if (dartAliasName != null) {
      final dartType = type.getDartType(context);
      sb.write('typedef ${dartAliasName!.name} = $dartType;\n');
    }
    return BindingString(
      type: BindingStringType.typeDef,
      string: sb.toString(),
    );
  }

  @override
  Type get typealiasType => type.typealiasType;

  @override
  bool get isIncompleteCompound => type.isIncompleteCompound;

  @override
  String getCType(Context context) =>
      generateBindings ? name : type.getCType(context);

  @override
  String getNativeType({String varName = ''}) =>
      type.getNativeType(varName: varName);

  @override
  String getFfiDartType(Context context) {
    if (generateBindings) {
      if (_ffiDartAliasName != null) {
        return _ffiDartAliasName!.name;
      } else if (type.sameFfiDartAndCType) {
        return name;
      }
    }
    return type.getFfiDartType(context);
  }

  @override
  String getDartType(Context context) {
    if (generateBindings) {
      if (dartAliasName != null) {
        return dartAliasName!.name;
      } else if (type.sameDartAndCType) {
        return getFfiDartType(context);
      }
    }
    return type.getDartType(context);
  }

  @override
  String getObjCBlockSignatureType(Context context) =>
      type.getObjCBlockSignatureType(context);

  @override
  bool get sameFfiDartAndCType => type.sameFfiDartAndCType;

  @override
  bool get sameDartAndCType => type.sameDartAndCType;

  @override
  bool get sameDartAndFfiDartType => type.sameDartAndFfiDartType;

  @override
  String convertDartTypeToFfiDartType(
    Context context,
    String value, {
    required bool objCRetain,
    required bool objCAutorelease,
  }) => type.convertDartTypeToFfiDartType(
    context,
    value,
    objCRetain: objCRetain,
    objCAutorelease: objCAutorelease,
  );

  @override
  String convertFfiDartTypeToDartType(
    Context context,
    String value, {
    required bool objCRetain,
    String? objCEnclosingClass,
  }) => type.convertFfiDartTypeToDartType(
    context,
    value,
    objCRetain: objCRetain,
    objCEnclosingClass: objCEnclosingClass,
  );

  @override
  String? generateRetain(String value) => type.generateRetain(value);

  @override
  String cacheKey() => type.cacheKey();

  @override
  String? getDefaultValue(Context context) => type.getDefaultValue(context);

  @override
  void visitChildren(Visitor visitor) {
    super.visitChildren(visitor);
    visitor.visit(_ffiDartAliasName);
    visitor.visit(dartAliasName);
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
    Context context,
    String value, {
    required bool objCRetain,
    required bool objCAutorelease,
  }) => ObjCInterface.generateGetId(value, objCRetain, objCAutorelease);

  @override
  String convertFfiDartTypeToDartType(
    Context context,
    String value, {
    required bool objCRetain,
    String? objCEnclosingClass,
  }) => objCEnclosingClass == null
      ? super.convertFfiDartTypeToDartType(
          context,
          value,
          objCRetain: objCRetain,
          objCEnclosingClass: objCEnclosingClass,
        )
      : ObjCInterface.generateConstructor(
          objCEnclosingClass,
          value,
          objCRetain,
        );

  @override
  String getNativeType({String varName = ''}) => 'id $varName';
}
