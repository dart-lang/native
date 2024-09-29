// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')

import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:ffigen/ffigen.dart';
import 'package:ffigen/src/config_provider/config.dart';
import 'package:ffigen/src/config_provider/config_types.dart';
import 'package:logging/logging.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';
import '../test_utils.dart';
import 'util.dart';

void main() {
  group('NSRange', () {
    late final String bindings;
    setUpAll(() {
      final config = Config(
        wrapperName: 'NSRangeTestObjCLibrary',
        language: Language.objc,
        output: Uri.file('test/native_objc_test/ns_range_bindings.dart'),
        entryPoints: [Uri.file('test/native_objc_test/ns_range_test.m')],
        formatOutput: false,
        objcInterfaces: DeclarationFilters.include({'SFTranscriptionSegment'}),
      );
      FfiGen(logLevel: Level.SEVERE).run(config);
      bindings = File('test/native_objc_test/ns_range_bindings.dart')
          .readAsStringSync();
    });

    test('interfaces', () {
      // Regression test for https://github.com/dart-lang/native/issues/1180.
      expect(bindings.split('\n'),
          isNot(contains(matches(RegExp(r'class.*NSRange.*Struct')))));
    });
  });
}
