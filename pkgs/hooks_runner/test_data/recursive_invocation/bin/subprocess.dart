// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:recursive_invocation/recursive_invocation.dart'
    as recursive_invocation;

void main(List<String> args) {
  print('in main: $args');
  print(recursive_invocation.someString);

  if (args.isEmpty) {
    final result = Process.runSync(Platform.resolvedExecutable, [
      'run',
      'bin/subprocess.dart',
      'child',
    ]);
    print(result.stdout);
    print(result.stderr);
  }
  print(recursive_invocation.someString);
  print('exiting main: $args');
}
