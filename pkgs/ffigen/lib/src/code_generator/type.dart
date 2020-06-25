// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart';

import 'writer.dart';

class _SubType {
  final String c;
  final String dart;

  const _SubType({this.c, this.dart});
}

enum SupportedNativeType {
  Void,
  Char,
  Int8,
  Int16,
  Int32,
  Int64,
  Uint8,
  Uint16,
  Uint32,
  Uint64,
  Float,
  Double,
  IntPtr,
}

/// The basic types in which all types can be broadly classified into.
enum BroadType {
  NativeType,
  Pointer,
  Struct,
  NativeFunction,

  /// Stores its element type in NativeType as only those are supported.
  ConstantArray,

  /// Used as a marker, so that functions/structs having these can exclude them.
  Unimplemented,
}

/// Type class for return types, variable types, etc.
class Type {
  static const _primitives = <SupportedNativeType, _SubType>{
    SupportedNativeType.Void: _SubType(c: 'Void', dart: 'void'),
    SupportedNativeType.Char: _SubType(c: 'Uint8', dart: 'int'),
    SupportedNativeType.Int8: _SubType(c: 'Int8', dart: 'int'),
    SupportedNativeType.Int16: _SubType(c: 'Int16', dart: 'int'),
    SupportedNativeType.Int32: _SubType(c: 'Int32', dart: 'int'),
    SupportedNativeType.Int64: _SubType(c: 'Int64', dart: 'int'),
    SupportedNativeType.Uint8: _SubType(c: 'Uint8', dart: 'int'),
    SupportedNativeType.Uint16: _SubType(c: 'Uint16', dart: 'int'),
    SupportedNativeType.Uint32: _SubType(c: 'Uint32', dart: 'int'),
    SupportedNativeType.Uint64: _SubType(c: 'Uint64', dart: 'int'),
    SupportedNativeType.Float: _SubType(c: 'Float', dart: 'double'),
    SupportedNativeType.Double: _SubType(c: 'Double', dart: 'double'),
    SupportedNativeType.IntPtr: _SubType(c: 'IntPtr', dart: 'int'),
  };

  /// For providing name of Struct.
  String structName;

  /// For providing name of nativeFunc.
  String nativeFuncName;

  /// For providing [SupportedNativeType] only.
  final SupportedNativeType nativeType;

  /// The BroadType of this Type.
  final BroadType broadType;

  /// Child Type, e.g Pointer(Parent) to Int(Child).
  final Type child;

  /// For ConstantArray type.
  final int arrayLength;
  final Type elementType;

  /// For storing cursor type info for an unimplemented type.
  String unimplementedReason;

  Type._({
    @required this.broadType,
    this.child,
    this.structName,
    this.nativeType,
    this.nativeFuncName,
    this.arrayLength,
    this.elementType,
    this.unimplementedReason,
  });

  factory Type.pointer(Type child) {
    return Type._(broadType: BroadType.Pointer, child: child);
  }
  factory Type.struct(String structName) {
    return Type._(broadType: BroadType.Struct, structName: structName);
  }
  factory Type.nativeFunc(String nativeFuncName) {
    return Type._(
        broadType: BroadType.NativeFunction, nativeFuncName: nativeFuncName);
  }
  factory Type.nativeType(SupportedNativeType nativeType) {
    return Type._(broadType: BroadType.NativeType, nativeType: nativeType);
  }
  factory Type.constantArray(int arrayLength, Type elementType) {
    return Type._(broadType: BroadType.ConstantArray, elementType: elementType);
  }
  factory Type.unimplemented(String reason) {
    return Type._(
        broadType: BroadType.Unimplemented, unimplementedReason: reason);
  }

  /// Get base broad type for any type.
  ///
  /// E.g int** has base Broadtype as NativeType.
  BroadType getBaseBroadType() {
    if (broadType == BroadType.Pointer) {
      return child.getBaseBroadType();
    } else {
      return broadType;
    }
  }

  bool get isPrimitive => broadType == BroadType.NativeType;

  String getCType(Writer w) {
    switch (broadType) {
      case BroadType.NativeType:
        return '${w.ffiLibraryPrefix}.${_primitives[nativeType].c}';
      case BroadType.Pointer:
        return '${w.ffiLibraryPrefix}.Pointer<${child.getCType(w)}>';
      case BroadType.Struct:
        return structName;
      case BroadType.NativeFunction:
        return '${w.ffiLibraryPrefix}.NativeFunction<${nativeFuncName}>';
      default:
        throw Exception('cType unknown');
    }
  }

  String getDartType(Writer w) {
    switch (broadType) {
      case BroadType.NativeType:
        return _primitives[nativeType].dart;
      case BroadType.Pointer:
        return '${w.ffiLibraryPrefix}.Pointer<${child.getCType(w)}>';
      case BroadType.Struct:
        return structName;
      case BroadType.NativeFunction:
        return '${w.ffiLibraryPrefix}.NativeFunction<${nativeFuncName}>';
      default:
        throw Exception('dart type unknown for ${broadType.toString()}');
    }
  }

  @override
  String toString() {
    return 'Type: ${broadType}';
  }
}
