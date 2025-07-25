// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/config_provider/config_types.dart';
import 'package:ffigen/src/header_parser/sub_parsers/api_availability.dart';
import 'package:test/test.dart';

void main() {
  group('ObjC inheritance edge cases', () {
    test('multiple children', () {
      final config;
      final context = textContext(config);
      final method = ObjCMethod(
        builtInFunctions: context.builtInFunctions,
      );
      final bindings = transformBindings(config, [
      ]);
    });
  });
}
