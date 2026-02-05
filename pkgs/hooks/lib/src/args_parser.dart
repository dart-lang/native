// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Retrieves the value associated with the '--config' argument from a list of
/// command-line arguments.
///
/// This function iterates through the provided [arguments] list to find an
/// argument that either starts with '--config=' (e.g., '--config=value') or is
/// exactly '--config' followed by its value in the next argument.
///
/// Throws a [StateError] if no '--config' argument is found with an associated
/// value.
///
/// Example usage:
///
/// <!-- no-source-file -->
/// ```dart
/// // If arguments is ['--verbose', '--config=dev_settings.json']
/// String config1 = getInputArgument(arguments); // Returns 'dev_settings.json'
///
/// // If arguments is ['--config', 'prod_settings.json']
/// String config2 = getInputArgument(arguments); // Returns 'prod_settings.json'
///
/// // If arguments is ['--help']
/// // getInputArgument(arguments); // Throws StateError
/// ```
String getInputArgument(List<String> arguments) {
  for (var i = 0; i < arguments.length; ++i) {
    final argument = arguments[i];
    if (argument.startsWith('--config=')) {
      return argument.substring('--config='.length);
    }
    if (argument == '--config') {
      if ((i + 1) < arguments.length) {
        return arguments[i + 1];
      }
    }
  }
  throw StateError('No --config argument given.');
}
