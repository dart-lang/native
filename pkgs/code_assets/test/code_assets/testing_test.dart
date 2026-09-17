// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:test/test.dart';

void main() {
  test(
    'testCodeBuildHook runs with default OS and explicit target OSes',
    () async {
      await testCodeBuildHook(
        mainMethod: (args) async {
          await build(args, (input, output) async {});
        },
        check: (input, output) {
          expect(input.config.buildCodeAssets, isTrue);
        },
      );

      await testCodeBuildHook(
        targetOS: OS.iOS,
        targetArchitecture: Architecture.arm64,
        targetIOSSdk: IOSSdk.iPhoneOS,
        targetIOSVersion: 17,
        mainMethod: (args) async {
          await build(args, (input, output) async {});
        },
        check: (input, output) {
          expect(input.config.code.targetOS, OS.iOS);
          expect(input.config.code.iOS.targetSdk, IOSSdk.iPhoneOS);
          expect(input.config.code.iOS.targetVersion, 17);
        },
      );

      await testCodeBuildHook(
        targetOS: OS.macOS,
        targetArchitecture: Architecture.arm64,
        targetMacOSVersion: 14,
        mainMethod: (args) async {
          await build(args, (input, output) async {});
        },
        check: (input, output) {
          expect(input.config.code.targetOS, OS.macOS);
          expect(input.config.code.macOS.targetVersion, 14);
        },
      );

      await testCodeBuildHook(
        targetOS: OS.android,
        targetArchitecture: Architecture.arm64,
        targetAndroidNdkApi: 30,
        mainMethod: (args) async {
          await build(args, (input, output) async {});
        },
        check: (input, output) {
          expect(input.config.code.targetOS, OS.android);
          expect(input.config.code.android.targetNdkApi, 30);
        },
      );
    },
  );

  test('CCompilerConfig equality, hashCode, and windows getter', () {
    final cc = Uri.file('/path/to/cc');
    final ld = Uri.file('/path/to/ld');
    final ar = Uri.file('/path/to/ar');
    final script = Uri.file('/path/to/vcvars.bat');

    final config1 = CCompilerConfig(
      archiver: ar,
      compiler: cc,
      linker: ld,
      windows: WindowsCCompilerConfig(
        developerCommandPrompt: DeveloperCommandPrompt(
          script: script,
          arguments: ['x64'],
        ),
      ),
    );
    final config2 = CCompilerConfig(
      archiver: ar,
      compiler: cc,
      linker: ld,
      windows: WindowsCCompilerConfig(
        developerCommandPrompt: DeveloperCommandPrompt(
          script: script,
          arguments: ['x64'],
        ),
      ),
    );

    expect(config1, equals(config2));
    expect(config1.hashCode, equals(config2.hashCode));
    expect(config1.windows.developerCommandPrompt?.script, equals(script));
    expect(config1 == Object(), isFalse);

    expect(
      config1,
      isNot(
        equals(
          CCompilerConfig(
            archiver: Uri.file('/other/ar'),
            compiler: cc,
            linker: ld,
          ),
        ),
      ),
    );
    expect(
      config1,
      isNot(
        equals(
          CCompilerConfig(
            archiver: ar,
            compiler: Uri.file('/other/cc'),
            linker: ld,
          ),
        ),
      ),
    );
    expect(
      config1,
      isNot(
        equals(
          CCompilerConfig(
            archiver: ar,
            compiler: cc,
            linker: Uri.file('/other/ld'),
          ),
        ),
      ),
    );
    expect(
      config1,
      isNot(
        equals(
          CCompilerConfig(
            archiver: ar,
            compiler: cc,
            linker: ld,
            windows: WindowsCCompilerConfig(
              developerCommandPrompt: DeveloperCommandPrompt(
                script: Uri.file('/other/vcvars.bat'),
                arguments: ['x64'],
              ),
            ),
          ),
        ),
      ),
    );
    expect(
      config1,
      isNot(
        equals(
          CCompilerConfig(
            archiver: ar,
            compiler: cc,
            linker: ld,
            windows: WindowsCCompilerConfig(
              developerCommandPrompt: DeveloperCommandPrompt(
                script: script,
                arguments: ['arm64'],
              ),
            ),
          ),
        ),
      ),
    );

    final noWindowsConfig = CCompilerConfig(
      archiver: ar,
      compiler: cc,
      linker: ld,
    );
    expect(() => noWindowsConfig.windows, throwsStateError);
  });
}
