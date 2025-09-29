// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'c_bindings_generated.dart';

/// Creates an Objective-C autorelease pool, runs [function], then releases the
/// pool.
///
/// This is analogous to the Objective-C `@autoreleasepool` block:
/// ```
/// @autoreleasepool {
///   function();
/// }
/// ```
///
/// [function] is executed synchronously. Do not try to pass an async function
/// here (the [Future] it returns will not be awaited). Objective-C autorelease
/// pools form a strict stack, and allowing async execution gaps inside the pool
/// scope could easily break this nesting, so async functions are not supported.
void autoReleasePool(void Function() function) {
  final pool = autoreleasePoolPush();
  try {
    function();
  } finally {
    autoreleasePoolPop(pool);
  }
}
