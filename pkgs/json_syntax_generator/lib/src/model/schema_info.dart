// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'class_info.dart';
import 'utils.dart';

/// Information extracted from a JSON schema which can be used to generate Dart
/// code.
class SchemaInfo {
  final List<ClassInfo> classes;

  SchemaInfo({required this.classes});

  @override
  String toString() {
    final classesString = classes
        .map((c) => indentLines(c.toString(), level: 2))
        .join(',\n');
    return '''
SchemaInfo(
  classes: [
$classesString
  ]
)''';
  }
}
