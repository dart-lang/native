// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: experimental_member_use

import 'package:code_assets/code_assets.dart';
import 'package:file/memory.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/src/tool/tool_resolver.dart';
import 'package:test/test.dart';

import '../hook/doctor.dart' as doctor_hook;
import 'helpers.dart';
import 'utils/fake_process_manager.dart';

void main() {
  test('native_toolchain_c doctor hook smoke test', () async {
    await testDoctorHook(
      mainMethod: doctor_hook.main,
      check: (input, output) {
        expect(output.validations, hasLength(2));
        final hostValidation = output.validations.first;
        expect(hostValidation.title, startsWith('C Toolchain'));
        expect(
          hostValidation.type,
          isIn([DoctorValidationType.success, DoctorValidationType.partial]),
        );
        expect(hostValidation.messages, isNotEmpty);

        final androidValidation = output.validations.last;
        expect(androidValidation.title, 'Android NDK C Toolchain');
        expect(
          androidValidation.type,
          isIn([
            DoctorValidationType.success,
            DoctorValidationType.partial,
            DoctorValidationType.notAvailable,
          ]),
        );
      },
    );
  });

  for (final hostOS in [OS.macOS, OS.linux, OS.windows]) {
    test(
      'runNativeToolchainCDoctor reports missing when no tools are installed '
      'on $hostOS',
      () async {
        final emptyContext = ToolResolvingContext(
          logger: logger,
          environment: const {},
          fileSystem: MemoryFileSystem.test(),
          processManager: FakeProcessManager(
            List.filled(20, const FakeCommand(exitCode: 1)),
          ),
        );
        final results = await doctor_hook.runNativeToolchainCDoctor(
          context: emptyContext,
          hostOS: hostOS,
        );
        expect(results, hasLength(2));
        expect(results.first.type, DoctorValidationType.missing);
        expect(
          results.first.messages.any(
            (m) => m.type == DoctorValidationMessageType.error,
          ),
          isTrue,
        );
        expect(
          results.first.messages.any(
            (m) => m.type == DoctorValidationMessageType.hint,
          ),
          isTrue,
        );
        expect(results.last.title, 'Android NDK C Toolchain');
        expect(results.last.type, DoctorValidationType.notAvailable);
      },
    );
  }

  test('runNativeToolchainCDoctor handles unsupported hostOS', () async {
    final emptyContext = ToolResolvingContext(
      logger: logger,
      environment: const {},
      fileSystem: MemoryFileSystem.test(),
      processManager: FakeProcessManager(
        List.filled(5, const FakeCommand(exitCode: 1)),
      ),
    );
    final results = await doctor_hook.runNativeToolchainCDoctor(
      context: emptyContext,
      hostOS: OS.fuchsia,
    );
    expect(results.first.type, DoctorValidationType.notAvailable);
    expect(results.first.statusInfo, contains('fuchsia'));
  });
}
