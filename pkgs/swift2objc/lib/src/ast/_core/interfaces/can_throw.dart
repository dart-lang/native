// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// An interface to describe a Swift entity's ability to be annotated
/// with `throws`.
abstract interface class CanThrow {
  abstract final bool throws;
}
