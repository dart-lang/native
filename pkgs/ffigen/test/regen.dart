// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:ffigen/ffigen.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'test_utils.dart';

const usage = r'''Regenerates the Dart FFI bindings used in tests and examples.

Use this command when developing features that change the generated bindings
e.g. with this command:

$ dart run test/setup.dart && dart run test/regen.dart && dart test
''';

void _regenConfig(Logger logger, String yamlConfigPath) {
  final path = p.join(packagePathForTests, yamlConfigPath);
  withChDir(path, () {
    testConfigFromPath(path).generate(logger: logger);
  });
}

Future<void> main(List<String> args) async {
  final parser = ArgParser();
  parser.addSeparator(usage);
  parser.addFlag(
    'help',
    abbr: 'h',
    help: 'Prints this usage',
    negatable: false,
  );

  final parseArgs = parser.parse(args);
  if (parseArgs.wasParsed('help')) {
    print(parser.usage);
    exit(0);
  } else if (parseArgs.rest.isNotEmpty) {
    print(parser.usage);
    exit(1);
  }

  final logger = Logger.root..level = Level.WARNING;

  _regenConfig(logger, 'test/native_test/config.yaml');
  _regenConfig(logger, 'example/libclang-example/config.yaml');
  _regenConfig(logger, 'example/simple/config.yaml');
  _regenConfig(logger, 'example/c_json/config.yaml');
  _regenConfig(logger, 'example/swift/config.yaml');
  _regenConfig(logger, 'example/objective_c/config.yaml');
}
