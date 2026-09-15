// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/config_provider/config.dart';
import 'package:ffigen/src/header_parser.dart' show parse;

import '../test_utils.dart';

Future<void> verifyBindings(FfiGenerator config) async {
  final context = testContext(config);
  final library = parse(context);
  final bindingsName = context.config.output.dart.path.pathSegments.last;
  await matchLibraryWithExpected(context, library, bindingsName, [
    'test',
    'native_cpp_test',
    bindingsName,
  ]);

  final cppBindingsName =
      context.config.output.cppBindingsFile.pathSegments.last;
  await matchCppFileWithExpected(context, library, cppBindingsName, [
    'test',
    'native_cpp_test',
    cppBindingsName,
  ]);
}
