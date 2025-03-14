// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// `package:json_syntax_generator` provides a powerful and flexible way to
/// generate Dart code from JSON schemas. It simplifies the process of
/// working with JSON data by automatically creating Dart classes that
/// represent the structure of your JSON data, including support for complex
/// schema features.
library;

export 'src/generator/syntax_generator.dart' show SyntaxGenerator;
export 'src/model/class_info.dart';
export 'src/model/dart_type.dart';
export 'src/model/property_info.dart';
export 'src/model/schema_info.dart';
export 'src/parser/schema_analyzer.dart' show SchemaAnalyzer;
