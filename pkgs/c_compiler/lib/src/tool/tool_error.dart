// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// The operation could not be performed due to a configuration error on the
/// host system.
class ToolError extends Error {
  final String message;
  ToolError(this.message);
  @override
  String toString() => 'System not configured correctly: $message';
}
