// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/header_parser.dart' show parse;
import 'package:ffigen/src/strings.dart' as strings;
import 'package:logging/logging.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  group('deprecate_assetId_test', () {
    final logArr = <String>[];
    logToArray(logArr, Level.WARNING);
    final config = testConfig('''
${strings.name}: 'NativeLibrary'
${strings.description}: 'Deprecation warning if assetId is used instead of ${strings.ffiNativeAsset}'
${strings.output}: 'unused'
${strings.ffiNative}:
    assetId: 'myasset'
${strings.headers}:
  ${strings.entryPoints}:
    - 'test/header_parser_tests/comment_markup.h'
''');
    parse(config);

    final logStr = logArr.join('\n');
    test('asset-id is correctly set', () {
      expect(config.ffiNativeConfig.assetId, 'myasset');
    });

    test('Deprecation Warning is logged', () {
      expect(logStr.contains('DEPRECATION WARNING'), true);
    });
  });
}
