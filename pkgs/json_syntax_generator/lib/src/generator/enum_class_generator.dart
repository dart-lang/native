// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../model/class_info.dart';

class EnumGenerator {
  final EnumClassInfo classInfo;

  EnumGenerator(this.classInfo);

  String generate() {
    final buffer = StringBuffer();
    final className = classInfo.name;
    final enumValues = classInfo.enumValues;

    final staticFinals = <String>[];
    for (final value in enumValues) {
      final valueName = value.name;
      final jsonValue = value.jsonValue;
      staticFinals.add(
        'static const $valueName = $className._(\'$jsonValue\');',
      );
    }

    buffer.writeln('''
class $className {
  final String name;

  const $className._(this.name);

  ${staticFinals.join('\n\n')}

  static const List<$className> values = [
    ${enumValues.map((e) => e.name).join(',')}
  ];

  static final Map<String, $className> _byName = {
    for (final value in values) value.name: value,
  };

  $className.unknown(this.name) : assert(!_byName.keys.contains(name));

  factory $className.fromJson(String name) {
    final knownValue = _byName[name];
    if(knownValue != null) {
      return knownValue;
    }
    return $className.unknown(name);
  }

  bool get isKnown => _byName[name] != null;

  @override
  String toString() => name;
}
''');
    return buffer.toString();
  }
}
