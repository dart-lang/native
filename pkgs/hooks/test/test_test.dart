// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

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
              ? MacOSCodeConfig(deploymentVersion: AppleVersion(13))
              : null,
        ),
      ],
      check: expectAsync2((_, _) {}, count: 0),
    );

    expect(
      testResult,
      throwsA(
        isA<ValidationFailure>()
            .having(
              (e) => e.message,
              'message',
              contains(
                'output validation issues: [Code asset '
                '"package:foreign_package/foo.dart" does not start with '
                // We don't know the expected prefix here because this test can
                // be run from the hooks package or the workspace. We just want
                // to assert some message related to outputs gets thrown.
                '"package:',
              ),
            )
            .having(
              (e) => e.toString(),
              'toString',
              contains('output validation issues:'),
            ),
      ),
    );
  });

  test('ProtocolExtension default implementations', () async {
    final ext = _EmptyExtension();
    final buildInputBuilder = BuildInputBuilder();
    final linkInputBuilder = LinkInputBuilder();
    // ignore: experimental_member_use
    final doctorInputBuilder = DoctorInputBuilder();
    ext.setupBuildInput(buildInputBuilder);
    ext.setupLinkInput(linkInputBuilder);
    // ignore: experimental_member_use
    ext.setupDoctorInput(doctorInputBuilder);
    // ignore: experimental_member_use
    expect(await ext.validateDoctorInput(doctorInputBuilder.build()), isEmpty);
    expect(await ext.validateApplicationAssets([]), isEmpty);
    expect(ext.outputFiles([]), isEmpty);
  });

  test('testDoctorHook', () async {
    // ignore: experimental_member_use
    await testDoctorHook(
      mainMethod: (args) async {
        // ignore: experimental_member_use
        await doctor(args, (input, output) async {
          // ignore: experimental_member_use
          final targetOS = input.config.code!.single.targetOS.name;
          output.addValidation(
            // ignore: experimental_member_use
            DoctorValidationResult(
              title: 'Doctor check (${input.packageName})',
              type: .success,
              statusInfo: 'OK ($targetOS)',
              // ignore: experimental_member_use
              messages: [DoctorValidationMessage('All good')],
            ),
          );
        });
      },
      extensions: [
        // ignore: experimental_member_use
        DoctorCodeAssetExtension(
          configs: [
            // ignore: experimental_member_use
            DoctorCodeConfig(
              targetOS: OS.current,
              targetArchitecture: Architecture.current,
            ),
          ],
        ),
      ],
      check: expectAsync2((input, output) {
        expect(output.validations, hasLength(1));
        // ignore: experimental_member_use
        expect(output.validations.single.type, DoctorValidationType.success);
        expect(output.validations.single.statusInfo, 'OK (${OS.current.name})');
        expect(output.validations.single.messages.single.message, 'All good');
      }),
    );
  });

  test('testDoctorHook throws on output error', () async {
    late Uri outputFile;
    // ignore: experimental_member_use
    final testResult = testDoctorHook(
      mainMethod: (args) async {
        // ignore: experimental_member_use
        await doctor(args, (input, output) async {
          outputFile = input.outputFile;
        });
        File.fromUri(outputFile).writeAsStringSync('{"validations": 123}');
      },
      check: expectAsync2((_, _) {}, count: 0),
    );

    expect(
      testResult,
      throwsA(
        isA<ValidationFailure>().having(
          (e) => e.message,
          'message',
          contains('Encountered doctor output validation issues:'),
        ),
      ),
    );
  });
}

final class _EmptyExtension extends ProtocolExtension {}
