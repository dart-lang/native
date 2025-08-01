// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: unused_import

// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.
// ignore_for_file: type=lint
/// test line 1
/// test line 2
enum Duplicates {
  /// This is a unique value
  a(0),

  /// This is an original value
  b(1);

  /// This is a duplicate value
  static const c = b;

  final int value;
  const Duplicates(this.value);

  static Duplicates fromValue(int value) => switch (value) {
    0 => a,
    1 => b,
    _ => throw ArgumentError('Unknown value for Duplicates: $value'),
  };

  @override
  String toString() {
    if (this == b) return "Duplicates.b, Duplicates.c";
    return super.toString();
  }
}
