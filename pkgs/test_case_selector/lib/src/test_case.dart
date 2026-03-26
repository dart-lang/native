// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart';

/// A single selected test case containing a value for each dimension.
///
/// Use [get] to retrieve the value for a specific dimension type in a
/// type-safe manner.
class TestCase {
  final Map<Type, Object> _values;

  /// Internal accessor for rendering.
  @internal
  Map<Type, Object> get values => _values;

  TestCase(this._values);

  /// Returns the value for a specific dimension type [T].
  ///
  /// This is the primary way to access dimension values when iterating over
  /// selected test cases.
  ///
  /// Example:
  ///
  /// ```dart
  /// for (final tc in configurations) {
  ///   final arch = tc.get<Architecture>();
  ///   final os = tc.get<OS>();
  ///   // ...
  /// }
  /// ```
  ///
  /// Throws an [ArgumentError] if the type [T] is not present in this test
  /// case.
  T get<T>() {
    final value = _values[T];
    if (value == null) {
      throw ArgumentError('Dimension type $T not found in this test case.');
    }
    return value as T;
  }

  @override
  String toString() => _values.entries
      .map((e) => '${e.key.toString().split('.').last}: ${e.value}')
      .join(', ');
}
