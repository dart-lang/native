// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/header_parser.dart' show parse;
import 'package:path/path.dart' as p;

import '../test_utils.dart';

void verifyBindings(String testName) {
  final thisDir = p.join(packagePathForTests, 'test', 'native_cpp_test');
  final configFile = p.join(thisDir, '${testName}_config.yaml');
  final config = testConfigFromPath(configFile);
  final context = testContext(config);
  final library = parse(context);
  final bindingsName = context.config.output.dartFile.pathSegments.last;
  matchLibraryWithExpected(context, library, bindingsName, [
    'test',
    'native_cpp_test',
    bindingsName,
  ]);

  final cppBindingsName =
      context.config.output.cppBindingsFile.pathSegments.last;
  matchCppFileWithExpected(context, library, cppBindingsName, [
    'test',
    'native_cpp_test',
    cppBindingsName,
  ]);
}
