// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:collection/collection.dart';
import '../../code_generator.dart' show SupportedNativeType, Type;
import '../../code_generator/imports.dart';
import '../../code_generator/native_type.dart';

Map<String, ImportedType> cxTypeKindToImportedTypes = {
  'void': voidType,
  'unsigned char': unsignedCharType,
  'signed char': signedCharType,
  'char': charType,
  'unsigned short': unsignedShortType,
  'short': shortType,
  'unsigned int': unsignedIntType,
  'int': intType,
  'unsigned long': unsignedLongType,
  'long': longType,
  'unsigned long long': unsignedLongLongType,
  'long long': longLongType,
  'float': floatType,
  'double': doubleType,
};

Map<Type, ImportedType?> unsignedToSignedNativeIntType = Map.fromEntries(
  cxTypeKindToImportedTypes.entries
      .where((e) => e.key.contains('unsigned'))
      .map(
        (e) => MapEntry(
          e.value as Type,
          cxTypeKindToImportedTypes[e.key.replaceFirst('unsigned ', '')],
        ),
      ),
);

Map<Type, ImportedType?> signedToUnsignedNativeIntType = Map.fromEntries(
  cxTypeKindToImportedTypes.entries
      .whereNot((e) => e.key.contains('unsigned'))
      .map(
        (e) => MapEntry(
          e.value as Type,
          cxTypeKindToImportedTypes['unsigned ${e.key}'],
        ),
      ),
);

Map<String, NativeType> suportedTypedefToSuportedNativeType = {
  'uint8_t': NativeType(SupportedNativeType.uint8),
  'uint16_t': NativeType(SupportedNativeType.uint16),
  'uint32_t': NativeType(SupportedNativeType.uint32),
  'uint64_t': NativeType(SupportedNativeType.uint64),
  'int8_t': NativeType(SupportedNativeType.int8),
  'int16_t': NativeType(SupportedNativeType.int16),
  'int32_t': NativeType(SupportedNativeType.int32),
  'int64_t': NativeType(SupportedNativeType.int64),
  'intptr_t': NativeType(SupportedNativeType.intPtr),
  'uintptr_t': NativeType(SupportedNativeType.uintPtr),
};

Map<String, ImportedType> supportedTypedefToImportedType = {
  'size_t': sizeType,
  'wchar_t': wCharType,
};
