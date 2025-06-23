// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Provides utility extensions on [DateTime] to perform common time-based
/// operations.
extension DateTimeExtension on DateTime {
  /// Rounds down the [DateTime] instance to the nearest whole second.
  DateTime roundDownToSeconds() => DateTime.fromMillisecondsSinceEpoch(
    millisecondsSinceEpoch -
        millisecondsSinceEpoch % const Duration(seconds: 1).inMilliseconds,
  );
}
