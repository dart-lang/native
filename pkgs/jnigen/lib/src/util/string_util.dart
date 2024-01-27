// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

extension StringUtil on String {
  /// Makes the first letter uppercase.
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Remove special characters from the beginning fo the variable name
  String get rename{
    return RegExp(r'^[a-zA-Z]').hasMatch(this[0]) ? this : substring(1);
  }

  /// Reverses an ASCII string.
  String get reversed => split('').reversed.join();
}
