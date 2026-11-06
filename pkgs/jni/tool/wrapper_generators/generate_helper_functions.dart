// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

class GeneratedFunction {
  final String name;
  final String cCode;
  final String? dartCode;

  GeneratedFunction(this.name, this.cCode, this.dartCode);

  @override
  String toString() => cCode;
}

class PrimitiveType {
  final String name;
  final String jValueGetter;
  final String dartReturnType;
  final String dartArgumentType;
  final String conversionSuffix;
  final String resultGetter;

  const PrimitiveType(
    this.name,
    this.jValueGetter,
    this.dartReturnType,
    this.dartArgumentType,
    this.conversionSuffix,
    this.resultGetter,
  );
}

const primitiveTypes = [
  PrimitiveType('Boolean', 'z', 'bool', 'int', ' ? 1 : 0', 'boolean'),
  PrimitiveType('Byte', 'b', 'int', 'int', '', 'byte'),
  PrimitiveType('Char', 'c', 'int', 'int', '', 'char'),
  PrimitiveType('Short', 's', 'int', 'int', '', 'short'),
  PrimitiveType('Int', 'i', 'int', 'int', '', 'integer'),
  PrimitiveType('Long', 'j', 'int', 'int', '', 'long'),
  PrimitiveType('Float', 'f', 'double', 'double', '', 'float'),
  PrimitiveType('Double', 'd', 'double', 'double', '', 'doubleFloat'),
];

final primitiveArrayHelperFields = _primitiveArrayHelpers(isField: true);
final primitiveArrayHelperFunctions = _primitiveArrayHelpers(isField: false);

/// Generates helpers for setting and getting a single element in primitive
/// Java arrays faster.
///
/// By default, the JNI primitive array functions operate on ranges.
/// This means that Dart has to allocate pointers on heap to pass to them, which
/// is slower.
List<GeneratedFunction> _primitiveArrayHelpers({required bool isField}) {
  final functions = <GeneratedFunction>[];
  for (final PrimitiveType(
        name: typeName,
        :jValueGetter,
        :dartReturnType,
        :dartArgumentType,
        :conversionSuffix,
        :resultGetter
      ) in primitiveTypes) {
    final elementType = 'j${typeName.toLowerCase()}';
    final arrayType = '${elementType}Array';

    /* Get */ {
      final name = 'Get${typeName}ArrayElement';
      if (isField) {
        functions.add(GeneratedFunction(
          name,
          'JniResult (*$name)($arrayType array, jsize index);',
          null,
        ));
      } else {
        functions.add(GeneratedFunction(name, '''
JniResult globalEnv_$name($arrayType array, jsize index) {
  jvalue value;
  jthrowable exception =
    globalEnv_Get${typeName}ArrayRegion(array, index, 1, 
      &value.$jValueGetter);
  return (JniResult){.value = value, .exception = exception};
}
''', '''
  late final _$name = ptr.ref.$name.asFunction<
      JniResult Function(J${typeName}ArrayPtr array, int index)>(isLeaf: true);

  $dartReturnType $name(
          J${typeName}ArrayPtr array, int index) =>
      _$name(array, index).$resultGetter;
'''));
      }
      /* Set */ {
        final name = 'Set${typeName}ArrayElement';
        if (isField) {
          functions.add(GeneratedFunction(
            name,
            'jthrowable (*$name)($arrayType array, jsize index,'
            ' $elementType element);',
            null,
          ));
        } else {
          functions.add(GeneratedFunction(name, '''
jthrowable globalEnv_$name($arrayType array, jsize index, $elementType val) {
  return globalEnv_Set${typeName}ArrayRegion(array, index, 1, &val);
}
''', '''
  late final _$name = ptr.ref.$name.asFunction<
      JThrowablePtr Function(J${typeName}ArrayPtr array, int index,
        $dartArgumentType val)>(isLeaf: true);

  void $name(
          J${typeName}ArrayPtr array, int index, $dartReturnType value) =>
      _$name(array, index, value$conversionSuffix).check();
'''));
        }
      }
    }
  }
  return functions;
}
