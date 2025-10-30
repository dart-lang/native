// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';

import 'writer.dart';

enum SupportedNativeType {
  voidType,
  char,
  int8,
  int16,
  int32,
  int64,
  uint8,
  uint16,
  uint32,
  uint64,
  float,
  double,
  intPtr,
  uintPtr,
}

/// Represents a primitive native type, such as float.
class NativeType extends Type {
  static const _primitives = <SupportedNativeType, NativeType>{
    SupportedNativeType.voidType: NativeType._('Void', 'void', 'void', null),
    SupportedNativeType.char: NativeType._('Uint8', 'int', 'char', '0'),
    SupportedNativeType.int8: NativeType._('Int8', 'int', 'int8_t', '0'),
    SupportedNativeType.int16: NativeType._('Int16', 'int', 'int16_t', '0'),
    SupportedNativeType.int32: NativeType._('Int32', 'int', 'int32_t', '0'),
    SupportedNativeType.int64: NativeType._('Int64', 'int', 'int64_t', '0'),
    SupportedNativeType.uint8: NativeType._('Uint8', 'int', 'uint8_t', '0'),
    SupportedNativeType.uint16: NativeType._('Uint16', 'int', 'uint16_t', '0'),
    SupportedNativeType.uint32: NativeType._('Uint32', 'int', 'uint32_t', '0'),
    SupportedNativeType.uint64: NativeType._('Uint64', 'int', 'uint64_t', '0'),
    SupportedNativeType.float: NativeType._('Float', 'double', 'float', '0.0'),
    SupportedNativeType.double:
        NativeType._('Double', 'double', 'double', '0.0'),
    SupportedNativeType.intPtr: NativeType._('IntPtr', 'int', 'intptr_t', '0'),
    SupportedNativeType.uintPtr:
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
