// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:jnigen/src/bindings/linker.dart';
import 'package:jnigen/src/config/config_types.dart';
import 'package:jnigen/src/elements/elements.dart';
import 'package:jnigen/src/summary/summary.dart';
import 'package:test/test.dart';

import 'jackson_core_test/generate.dart' as jackson_core_test;
import 'kotlin_test/generate.dart' as kotlin_test;
import 'simple_package_test/generate.dart' as simple_package_test;
import 'test_util/test_util.dart';

Future<void> main() async {
  await checkLocallyBuiltDependencies();
  for (final (name, getConfig) in [
    (
      'simple_package',
      (Directory tempDir) => simple_package_test.getConfig(
            backend: SummarizerBackend.asm,
            targetDir: tempDir,
          )
    ),
    (
      'kotlin',
      (Directory tempDir) => kotlin_test.getConfig(
            backend: SummarizerBackend.asm,
            targetDir: tempDir,
          )
    ),
    (
      'jackson_core',
      (Directory _) =>
          jackson_core_test.getConfig(backend: SummarizerBackend.asm)
    ),
  ]) {
    test('Method descriptor generation for $name',
        timeout: const Timeout.factor(3), () async {
      final tempDir = getTempDir('jnigen_descriptor_${name}_');
      try {
        final config = getConfig(tempDir);
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
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });
  }
}
