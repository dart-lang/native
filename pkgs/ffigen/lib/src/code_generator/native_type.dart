// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';

import 'writer.dart';

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
  UintPtr,
}

/// Represents a primitive native type, such as float.
class NativeType extends Type {
  static const _primitives = <SupportedNativeType, NativeType>{
    SupportedNativeType.Void: NativeType._('Void', 'void', 'void', null),
    SupportedNativeType.Char: NativeType._('Uint8', 'int', 'char', '0'),
    SupportedNativeType.Int8: NativeType._('Int8', 'int', 'int8_t', '0'),
    SupportedNativeType.Int16: NativeType._('Int16', 'int', 'int16_t', '0'),
    SupportedNativeType.Int32: NativeType._('Int32', 'int', 'int32_t', '0'),
    SupportedNativeType.Int64: NativeType._('Int64', 'int', 'int64_t', '0'),
    SupportedNativeType.Uint8: NativeType._('Uint8', 'int', 'uint8_t', '0'),
    SupportedNativeType.Uint16: NativeType._('Uint16', 'int', 'uint16_t', '0'),
    SupportedNativeType.Uint32: NativeType._('Uint32', 'int', 'uint32_t', '0'),
    SupportedNativeType.Uint64: NativeType._('Uint64', 'int', 'uint64_t', '0'),
    SupportedNativeType.Float: NativeType._('Float', 'double', 'float', '0.0'),
    SupportedNativeType.Double:
        NativeType._('Double', 'double', 'double', '0.0'),
    SupportedNativeType.IntPtr: NativeType._('IntPtr', 'int', 'intptr_t', '0'),
    SupportedNativeType.UintPtr:
        NativeType._('UintPtr', 'int', 'uintptr_t', '0'),
  };

  final String _cType;
  final String _dartType;
  final String _nativeType;
  final String? _defaultValue;

  const NativeType._(
      this._cType, this._dartType, this._nativeType, this._defaultValue);

  factory NativeType(SupportedNativeType type) => _primitives[type]!;

  @override
  String getCType(Writer w) => '${w.ffiLibraryPrefix}.$_cType';

  @override
  String getFfiDartType(Writer w) => _dartType;

  @override
  String getNativeType({String varName = ''}) => '$_nativeType $varName';

  @override
  bool get sameFfiDartAndCType => _cType == _dartType;

  @override
  String toString() => _cType;

  @override
  String cacheKey() => _cType;

  @override
  String? getDefaultValue(Writer w) => _defaultValue;
}

class BooleanType extends NativeType {
  const BooleanType._() : super._('Bool', 'bool', 'BOOL', 'false');
  static const _boolean = BooleanType._();
  factory BooleanType() => _boolean;

  @override
  String toString() => 'bool';

  @override
  String cacheKey() => 'bool';
}
