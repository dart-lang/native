// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/header_parser.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../../example/c_json/tool/ffigen.dart' as cjson_example;
import '../test_utils.dart';

void main() {
  group('cjson_example_test', () {
    test('c_json', () async {
      final packageRoot = path.join(packagePathForTests, 'example', 'c_json/');
      final context = testContext(
        cjson_example.getConfig(Uri.file(packageRoot)),
      );
      final library = parse(context);

      await matchLibraryWithExpected(context, library, 'example_c_json.dart', [
        'example',
        'c_json',
        'cjson_generated_bindings.dart',
      ]);
    });
  });
}
