// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:jnigen/jnigen.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' hide equals;

import 'generate.dart';
import '../test_util/test_util.dart';

void main() async {
  test("Generate and compare bindings for kotlin_test", () async {
    await generateAndCompareBindings(
      getConfig(),
      join(testRoot, "lib", "kotlin.dart"),
      join(testRoot, "src"),
    );
  }); // test if generated file == expected file
  test("Generate and analyze bindings for kotlin_test - pure dart", () async {
    await generateAndAnalyzeBindings(
      getConfig(BindingsType.dartOnly),
    );
  }); // test if generated file == expected file
}
