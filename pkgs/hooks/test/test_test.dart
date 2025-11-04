// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:hooks/src/validation.dart';
import 'package:test/test.dart';

void main() {
  test('throws on output error', () async {
    final testResult = testBuildHook(
      mainMethod: (args) async {
        await build(args, (input, output) async {
          output.assets.code.add(
            CodeAsset(
              package: 'foreign_package',
              name: 'foo.dart',
              linkMode: DynamicLoadingSystem(Uri.parse('libbrokenstuff.so')),
            ),
          );
        });
      },
      extensions: [
        CodeAssetExtension(
          targetArchitecture: Architecture.current,
          targetOS: OS.current,
          linkModePreference: LinkModePreference.preferDynamic,
          macOS: OS.current == OS.macOS
              ? MacOSCodeConfig(targetVersion: 13)
              : null,
        ),
      ],
      check: expectAsync2((_, _) {}, count: 0),
    );

    expect(
      testResult,
      throwsA(
        isA<ValidationFailure>().having(
          (e) => e.message,
          'message',
          contains(
            'output validation issues: [Code asset '
            '"package:foreign_package/foo.dart" does not start with '
            // We don't know the expected prefix here because this test can be
            // run from the hooks package or the workspace. We just want to
            // assert some message related to outputs gets thrown.
            '"package:',
          ),
        ),
      ),
    );
  });
}
