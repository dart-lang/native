// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// dart format width=74

// snippet-start
import 'dart:io';
import 'package:hooks/hooks.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    // Access raw user-defines value
    final debugLogging = input.userDefines['enable_debug_logging'];
    if (debugLogging is! bool?) {
      throw const FormatException(
        'hooks.user_defines.my_package.enable_debug_logging must be a '
        'boolean (or omitted)',
      );
    }
    if (debugLogging == true) {
      print('Debug logging is enabled.');
    }

    // Resolve relative path against pubspec.yaml base path
    final customAssetUri = input.userDefines.path('custom_asset');
    if (customAssetUri != null) {
      final file = File.fromUri(customAssetUri);
      output.dependencies.add(file.uri); // Declare cache dependency
      // Use the file...
    }
  });
}
// snippet-end
