// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

String getConfigArgument(List<String> arguments) {
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
