// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../model/class_info.dart';
import '../model/schema_info.dart';
import 'enum_class_generator.dart';
import 'helper_library.dart';
import 'normal_class_generator.dart';

/// Generates Dart code from a [SchemaInfo].
class SyntaxGenerator {
  final SchemaInfo schemaInfo;

  /// If `true`, also generate `required` named parameters for nullable fields.
  ///
  /// This is useful for ensuring that all fields are set when writing a
  /// semantic Dart API that wraps a generated syntax.
  ///
  /// If the generated syntax is used directly, prefer `false`.
  final bool requireNullableParameters;

  final String header;

  SyntaxGenerator(
    this.schemaInfo, {
    this.header = '',
    this.requireNullableParameters = false,
  });

  String generate() {
    final buffer = StringBuffer();

    buffer.writeln('''
// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

$header

// ignore_for_file: unused_element, public_member_api_docs

import 'dart:io';
''');

    for (final classInfo in schemaInfo.classes) {
      switch (classInfo) {
        case NormalClassInfo():
          buffer.writeln(
            ClassGenerator(
              classInfo,
              requireNullableParameters: requireNullableParameters,
            ).generate(),
          );
        case EnumClassInfo():
          buffer.writeln(EnumGenerator(classInfo).generate());
      }
    }

    buffer.writeln(helperLib);

    return buffer.toString();
  }
}
