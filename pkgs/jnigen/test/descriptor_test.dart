// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:jnigen/src/bindings/linker.dart';
import 'package:jnigen/src/config/config_types.dart';
import 'package:jnigen/src/elements/elements.dart';
import 'package:jnigen/src/summary/summary.dart';
import 'package:test/test.dart';

import 'jackson_core_test/generate.dart' as jackson_core_test;
import 'kotlin_test/generate.dart' as kotlin_test;
import 'simple_package_test/generate.dart' as simple_package_test;
import 'test_util/test_util.dart';

void main() {
  checkLocallyBuiltDependencies();
  for (final (name, getConfig) in [
    ('simple_package', simple_package_test.getConfig),
    ('kotlin', kotlin_test.getConfig),
    ('jackson_core', jackson_core_test.getConfig),
  ]) {
    test('Method descriptor generation for $name',
        timeout: const Timeout.factor(3), () async {
      final config = getConfig();
      config.summarizerOptions =
          SummarizerOptions(backend: SummarizerBackend.asm);
      final classes = await getSummary(config);
      final methodDescriptorsPreLinking = <Method, String?>{};
      for (final decl in classes.decls.values) {
        for (final method in decl.methods) {
          methodDescriptorsPreLinking[method] = method.descriptor;
        }
      }
      await classes.accept(Linker(config));
      for (final decl in classes.decls.values) {
        for (final method in decl.methods) {
          if (methodDescriptorsPreLinking[method]
              case final preLinkingDescriptor?) {
            expect(method.descriptor, preLinkingDescriptor);
          }
        }
      }
    });
  }
}
