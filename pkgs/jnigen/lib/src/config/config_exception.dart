// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Exception thrown when a configuration value is invalid.
class ConfigException implements Exception {
  ConfigException(this.message);
  String message;

  @override
  String toString() => 'Error parsing configuration: $message';
}
