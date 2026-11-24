// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:hooks/hooks.dart';

/// The user-defines that the tests assert on.
const _dumpedKeys = [
  'user_define_key',
  'user_define_key2',
  'user_define_precedence',
  'user_define_typed',
  'cli_only_key',
  'env_only_key',
  'some_file',
];

void main(List<String> arguments) async {
  await build(arguments, (input, output) async {
    // Load some relative path as absolute path from user-defines.
    final someFile = input.userDefines.path('some_file');
    if (someFile == null) {
      throw Exception(
        'User-define some_file does not have the right value: '
        '${input.userDefines['some_file']}.',
      );
    }
    final file = File.fromUri(someFile);
    output.dependencies.add(file.uri);

    final base = input.userDefines.baseUri([
      'nested',
      'options',
      'paths',
      0,
    ]);
    if (base == null) {
      throw Exception(
        'User-define nested.options.paths.0 does not have the right value: '
        '${input.userDefines['nested']}.',
      );
    }

    final pathOption =
        (((input.userDefines['nested'] as Map)['options'] as Map)['paths']
                as List)[0]
            as String;
    output.dependencies.add(base.resolve(pathOption));

    // Write out the resolved user-defines so that the tests can assert on the
    // precedence of the different user-define sources.
    final received = <String, Object?>{
      for (final key in _dumpedKeys) key: input.userDefines[key],
      'some_file_path': someFile.toString(),
    };
    File.fromUri(
      input.packageRoot.resolve('received_user_defines.json'),
    ).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(received));
  });
}
