// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@OnPlatform({'mac-os': Timeout.factor(2), 'windows': Timeout.factor(10)})
library;

import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:native_toolchain_c/src/utils/run_process.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  final targetOS = OS.current;
  final macOSConfig = targetOS == OS.macOS
      ? MacOSCodeConfig(targetVersion: defaultMacOSVersion)
      : null;

  for (final sanitizer in Sanitizer.values) {
    test('CBuilder executable sanitizer ${sanitizer.name}', () async {
      // MemorySanitizer is only supported on Linux.
      if (sanitizer == Sanitizer.msan && !Platform.isLinux) {
        return;
      }
      // ThreadSanitizer is not supported on Windows.
      if (sanitizer == Sanitizer.tsan && Platform.isWindows) {
        return;
      }

      final tempUri = await tempDirForTest();
      final tempUri2 = await tempDirForTest();
      final helloWorldCUri = packageUri.resolve(
        'test/cbuilder/testfiles/hello_world/src/hello_world.c',
      );
      if (!await File.fromUri(helloWorldCUri).exists()) {
        throw Exception('Run the test from the root directory.');
      }
      const name = 'hello_world';

      final logMessages = <String>[];
      final logger = createCapturingLogger(logMessages);

      final buildInputBuilder = BuildInputBuilder()
        ..setupShared(
          packageName: name,
          packageRoot: tempUri,
          outputFile: tempUri.resolve('output.json'),
          outputDirectoryShared: tempUri2,
        )
        ..config.setupBuild(linkingEnabled: false)
        ..addExtension(
          CodeAssetExtension(
            targetOS: targetOS,
            macOS: macOSConfig,
            targetArchitecture: Architecture.current,
            linkModePreference: LinkModePreference.dynamic,
            cCompiler: cCompiler,
            sanitizer: sanitizer,
          ),
        );

      final buildInput = buildInputBuilder.build();
      final buildOutput = BuildOutputBuilder();

      final cbuilder = CBuilder.executable(
        name: name,
        sources: [helloWorldCUri.toFilePath()],
        buildMode: BuildMode.release,
      );
      await cbuilder.run(
        input: buildInput,
        output: buildOutput,
        logger: logger,
      );

      final executableUri = buildInput.outputDirectory.resolve(
        OS.current.executableFileName(name),
      );
      expect(await File.fromUri(executableUri).exists(), true);
      if (Platform.isLinux) {
        final result = await runProcess(
          executable: executableUri,
          logger: logger,
        );
        expect(result.exitCode, 0);
        expect(result.stdout.trim(), endsWith('Hello world.'));
      }

      final compilerInvocation = logMessages.singleWhere(
        (message) =>
            message.contains('Running `') &&
            message.contains(helloWorldCUri.toFilePath()),
      );

      final expectedFlag = switch (buildInput.config.code.targetOS) {
        OS.windows => '/fsanitize=address', // only asan is supported
        _ => switch (sanitizer) {
          Sanitizer.asan => '-fsanitize=address',
          Sanitizer.msan => '-fsanitize=memory',
          Sanitizer.tsan => '-fsanitize=thread',
          final s => '-fsanitize=${s.name}',
        },
      };
      expect(compilerInvocation, contains(expectedFlag));
    });
  }

  test('CBuilder executable custom sanitizer ignored', () async {
    final tempUri = await tempDirForTest();
    final tempUri2 = await tempDirForTest();
    final helloWorldCUri = packageUri.resolve(
      'test/cbuilder/testfiles/hello_world/src/hello_world.c',
    );
    if (!await File.fromUri(helloWorldCUri).exists()) {
      throw Exception('Run the test from the root directory.');
    }
    const name = 'hello_world';

    final logMessages = <String>[];
    final logger = createCapturingLogger(logMessages);

    final customSanitizer = Sanitizer.fromString('custom_sanitizer');

    final buildInputBuilder = BuildInputBuilder()
      ..setupShared(
        packageName: name,
        packageRoot: tempUri,
        outputFile: tempUri.resolve('output.json'),
        outputDirectoryShared: tempUri2,
      )
      ..config.setupBuild(linkingEnabled: false)
      ..addExtension(
        CodeAssetExtension(
          targetOS: targetOS,
          macOS: macOSConfig,
          targetArchitecture: Architecture.current,
          linkModePreference: LinkModePreference.dynamic,
          cCompiler: cCompiler,
          sanitizer: customSanitizer,
        ),
      );

    final buildInput = buildInputBuilder.build();
    final buildOutput = BuildOutputBuilder();

    final cbuilder = CBuilder.executable(
      name: name,
      sources: [helloWorldCUri.toFilePath()],
      buildMode: BuildMode.release,
    );
    await cbuilder.run(
      input: buildInput,
      output: buildOutput,
      logger: logger,
    );

    final executableUri = buildInput.outputDirectory.resolve(
      OS.current.executableFileName(name),
    );
    expect(await File.fromUri(executableUri).exists(), true);

    final compilerInvocation = logMessages.singleWhere(
      (message) =>
          message.contains('Running `') &&
          message.contains(helloWorldCUri.toFilePath()),
    );

    // Compiler invocation should NOT contain any sanitizer flags.
    expect(compilerInvocation, isNot(contains('-fsanitize=')));
    expect(compilerInvocation, isNot(contains('/fsanitize=')));

    // A warning should be logged about the ignored sanitizer.
    final warningLogged = logMessages.any(
      (message) =>
          message.contains("The sanitizer 'custom_sanitizer' is not") &&
          message.contains('will be ignored'),
    );
    expect(warningLogged, true);
  });
}
