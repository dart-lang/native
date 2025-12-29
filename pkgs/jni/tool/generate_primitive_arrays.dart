// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Generates lib/src/primitive_jarrays.dart.

import 'dart:io';

import 'package:dart_style/dart_style.dart';

class PrimitiveType {
  final String name;
  final String signature;
  final String dartType;
  final int size;
  final bool isUnsigned;

  const PrimitiveType(
    this.name,
    this.signature, {
    required this.dartType,
    required this.size,
    this.isUnsigned = false,
  });

  String get nativeDartListType {
    if (dartType == 'double') {
      return 'Float${size}List';
    }
    return '${isUnsigned ? 'Uint' : 'Int'}${size}List';
  }

  String get nativeDartType {
    if (dartType == 'double') {
      return size == 32 ? 'Float' : 'Double';
    }
    return '${isUnsigned ? 'Uint' : 'Int'}$size';
  }

  String get sizeInDoc => size == 8 ? 'eight' : '$size';

  int get lowestInRange {
    if (isUnsigned) {
      return 0;
    }
    return -(1 << (size - 1));
  }

  int get highestInRange {
    if (isUnsigned) {
      return (1 << size) - 1;
    }
    return (1 << (size - 1)) - 1;
  }
}

void main() {
  final outputUri =
      Platform.script.resolve('../lib/src/primitive_jarrays.dart');
  final outputFile = File.fromUri(outputUri);
  final s = StringBuffer();
  s.writeln('''
// AUTO GENERATED. DO NOT EDIT!
// 
// To regenerate, run `dart run tool/generate_primtive_arrays.dart`

part of 'jarray.dart';
''');
  const primitiveTypes = [
    PrimitiveType('Boolean', 'Z', dartType: 'bool', size: 8, isUnsigned: true),
    PrimitiveType('Byte', 'B', dartType: 'int', size: 8),
    PrimitiveType('Char', 'C', dartType: 'int', size: 16, isUnsigned: true),
    PrimitiveType('Short', 'S', dartType: 'int', size: 16),
    PrimitiveType('Int', 'I', dartType: 'int', size: 32),
    PrimitiveType('Long', 'J', dartType: 'int', size: 64),
    PrimitiveType('Float', 'F', dartType: 'double', size: 32),
    PrimitiveType('Double', 'D', dartType: 'double', size: 64),
  ];
  for (final type in primitiveTypes) {
    final typeName = type.name;
    final arrayName = 'J${typeName}Array';
    s.write('''
final class _\$$arrayName\$Type\$ extends JType<$arrayName> {
  const _\$$arrayName\$Type\$();

  @override
  String get signature => '[${type.signature}';
}

/// A fixed-length array of Java $typeName.
///
''');
    if (type.dartType == 'int') {
      s.write('''
/// Integers stored in the list are truncated to their low ${type.sizeInDoc} bits
''');
      if (type.isUnsigned) {
        s.write('''
/// interpreted as an unsigned ${type.size}-bit integer with values in the
/// range ${type.lowestInRange} to +${type.highestInRange}.
///
''');
      } else {
        s.write('''
/// interpreted as a signed ${type.size}-bit two's complement integer with values in the
/// range ${type.lowestInRange} to +${type.highestInRange}.
///
''');
      }
    }
    s.write('''
/// Java equivalent of [${type.nativeDartListType}].
extension type $arrayName._(JObject _\$this) implements JObject {
  /// The type which includes information such as the signature of this class.
  static const JType<$arrayName> type = _\$$arrayName\$Type\$();

  /// Creates a [$arrayName] of the given [length].
  ///
  /// The [length] must be a non-negative integer.
  factory $arrayName(int length) {
    RangeError.checkNotNegative(length);
    return JObject.fromReference(
      JGlobalReference(Jni.env.New${typeName}Array(length)),
    ) as $arrayName;
  }

  /// The number of elements in this array.
  int get length => Jni.env.GetArrayLength(reference.pointer);

  ${type.dartType} operator [](int index) {
    RangeError.checkValidIndex(index, this);
    return Jni.env.Get${typeName}ArrayElement(reference.pointer, index);
  }

  void operator []=(int index, ${type.dartType} value) {
    RangeError.checkValidIndex(index, this);
    Jni.env.Set${typeName}ArrayElement(reference.pointer, index, value);
  }

  ${type.nativeDartListType} getRange(int start, int end, {Allocator allocator = malloc}) {
    RangeError.checkValidRange(start, end, length);
    final rangeLength = end - start;
    final buffer = allocator<${type.nativeDartType}>(rangeLength);
    Jni.env
        .Get${typeName}ArrayRegion(reference.pointer, start, rangeLength, buffer);
    return buffer.asTypedList(rangeLength, finalizer: allocator._nativeFree);
  }

  void setRange(int start, int end, Iterable<${type.dartType}> iterable,
      [int skipCount = 0]) {
    RangeError.checkValidRange(start, end, length);
    final rangeLength = end - start;
    _allocate<${type.nativeDartType}>(sizeOf<${type.nativeDartType}>() * rangeLength, (ptr) {
      ptr
          .asTypedList(rangeLength)
          .setRange(0, rangeLength, iterable${typeName == 'Boolean' ? '.map((e) => e ? 1 : 0)' : ''}, skipCount);
      Jni.env.Set${typeName}ArrayRegion(reference.pointer, start, rangeLength, ptr);
    });
  }
}

final class _${arrayName}ListView
    with ListMixin<${type.dartType}>, NonGrowableListMixin<${type.dartType}> {
  final $arrayName _jarray;

  _${arrayName}ListView(this._jarray);

  @override
  int get length => _jarray.length;

  @override
  ${type.dartType} operator [](int index) {
    return _jarray[index];
  }

  @override
  void operator []=(int index, ${type.dartType} value) {
    _jarray[index] = value;
  }
}

extension ${arrayName}ToList on $arrayName {
  /// Returns a [List] view into this array.
  ///
  /// Any changes to this list will reflect in the original array as well.
  List<${type.dartType}> get asDartList => _${arrayName}ListView(this);
}

''');
    final formatter = DartFormatter(
        languageVersion: DartFormatter.latestShortStyleLanguageVersion);
    outputFile.writeAsStringSync(formatter.format(s.toString()));
  }
}
