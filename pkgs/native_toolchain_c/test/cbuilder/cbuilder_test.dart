// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@OnPlatform({
  'mac-os': Timeout.factor(2),
  'windows': Timeout.factor(10),
})
library;

import 'dart:ffi';
import 'dart:io';

import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:native_toolchain_c/src/utils/run_process.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  for (final pic in [null, true, false]) {
    final picTag =
        switch (pic) { null => 'auto_pic', true => 'pic', false => 'no_pic' };

    for (final buildMode in BuildMode.values) {
      final suffix = testSuffix([buildMode, picTag]);

      test('CBuilder executable$suffix', () async {
        await inTempDir((tempUri) async {
          final helloWorldCUri = packageUri
              .resolve('test/cbuilder/testfiles/hello_world/src/hello_world.c');
          if (!await File.fromUri(helloWorldCUri).exists()) {
            throw Exception('Run the test from the root directory.');
          }
          const name = 'hello_world';

          final logMessages = <String>[];
          final logger = createCapturingLogger(logMessages);

          final buildConfig = BuildConfig(
            outDir: tempUri,
            packageRoot: tempUri,
            targetArchitecture: Architecture.current,
            targetOs: OS.current,
            buildMode: buildMode,
            // Ignored by executables.
            linkModePreference: LinkModePreference.dynamic,
            cCompiler: CCompilerConfig(
              cc: cc,
              envScript: envScript,
              envScriptArgs: envScriptArgs,
            ),
          );
          final buildOutput = BuildOutput();
          final cbuilder = CBuilder.executable(
            name: name,
            sources: [helloWorldCUri.toFilePath()],
            pie: pic,
          );
          await cbuilder.run(
            buildConfig: buildConfig,
            buildOutput: buildOutput,
            logger: logger,
          );

          final executableUri =
              tempUri.resolve(Target.current.os.executableFileName(name));
          expect(await File.fromUri(executableUri).exists(), true);
          final result = await runProcess(
            executable: executableUri,
            logger: logger,
          );
          expect(result.exitCode, 0);
          if (buildMode == BuildMode.debug) {
            expect(result.stdout.trim(), startsWith('Running in debug mode.'));
          }
          expect(result.stdout.trim(), endsWith('Hello world.'));

          final compilerInvocation = logMessages.singleWhere(
            (message) => message.contains(helloWorldCUri.toFilePath()),
          );

          switch ((buildConfig.targetOs, pic)) {
            case (OS.windows, _) || (_, null):
              expect(compilerInvocation, isNot(contains('-fPIC')));
              expect(compilerInvocation, isNot(contains('-fPIE')));
              expect(compilerInvocation, isNot(contains('-fno-PIC')));
              expect(compilerInvocation, isNot(contains('-fno-PIE')));
            case (_, true):
              expect(compilerInvocation, contains('-fPIE'));
            case (_, false):
              expect(compilerInvocation, contains('-fno-PIC'));
              expect(compilerInvocation, contains('-fno-PIE'));
          }
        });
      });
    }

    for (final dryRun in [true, false]) {
      final suffix = testSuffix([if (dryRun) 'dry_run', picTag]);

      test('CBuilder dylib$suffix', () async {
        await inTempDir(
          // https://github.com/dart-lang/sdk/issues/40159
          keepTemp: Platform.isWindows,
          (tempUri) async {
            final addCUri =
                packageUri.resolve('test/cbuilder/testfiles/add/src/add.c');
            const name = 'add';

            final logMessages = <String>[];
            final logger = createCapturingLogger(logMessages);

            final buildConfig = dryRun
                ? BuildConfig.dryRun(
                    outDir: tempUri,
                    packageRoot: tempUri,
                    targetOs: OS.current,
                    linkModePreference: LinkModePreference.dynamic,
                  )
                : BuildConfig(
                    outDir: tempUri,
                    packageRoot: tempUri,
                    targetArchitecture: Architecture.current,
                    targetOs: OS.current,
                    buildMode: BuildMode.release,
                    linkModePreference: LinkModePreference.dynamic,
                    cCompiler: CCompilerConfig(
                      cc: cc,
                      envScript: envScript,
                      envScriptArgs: envScriptArgs,
                    ),
                  );
            final buildOutput = BuildOutput();

            final cbuilder = CBuilder.library(
              sources: [addCUri.toFilePath()],
              name: name,
              assetId: name,
              pic: pic,
            );
            await cbuilder.run(
              buildConfig: buildConfig,
              buildOutput: buildOutput,
              logger: logger,
            );

            final dylibUri =
                tempUri.resolve(Target.current.os.dylibFileName(name));
            expect(await File.fromUri(dylibUri).exists(), !dryRun);
            if (!dryRun) {
              final dylib = DynamicLibrary.open(dylibUri.toFilePath());
              final add = dylib.lookupFunction<Int32 Function(Int32, Int32),
                  int Function(int, int)>('add');
              expect(add(1, 2), 3);

              final compilerInvocation = logMessages.singleWhere(
                (message) => message.contains(addCUri.toFilePath()),
              );
              switch ((buildConfig.targetOs, pic)) {
                case (OS.windows, _) || (_, null):
                  expect(compilerInvocation, isNot(contains('-fPIC')));
                  expect(compilerInvocation, isNot(contains('-fPIE')));
                  expect(compilerInvocation, isNot(contains('-fno-PIC')));
                  expect(compilerInvocation, isNot(contains('-fno-PIE')));
                case (_, true):
                  expect(compilerInvocation, contains('-fPIC'));
                case (_, false):
                  expect(compilerInvocation, contains('-fno-PIC'));
                  expect(compilerInvocation, contains('-fno-PIE'));
              }
            }
          },
        );
      });
    }
  }

  for (final buildMode in BuildMode.values) {
    for (final enabled in [true, false]) {
      final suffix = testSuffix([buildMode, enabled ? 'enabled' : 'disabled']);

      test(
        'CBuilder build mode defines$suffix',
        () => testDefines(
          buildMode: buildMode,
          buildModeDefine: enabled,
          ndebugDefine: enabled,
        ),
      );
    }
  }

  for (final value in [true, false]) {
    final suffix = testSuffix([value ? 'with_value' : 'without_value']);

    test(
      'CBuilder define$suffix',
      () => testDefines(customDefineWithValue: value),
    );
  }

  test('CBuilder flags', () async {
    await inTempDir(
      // https://github.com/dart-lang/sdk/issues/40159
      keepTemp: Platform.isWindows,
      (tempUri) async {
        final addCUri =
            packageUri.resolve('test/cbuilder/testfiles/add/src/add.c');
        const name = 'add';

        final logMessages = <String>[];
        final logger = createCapturingLogger(logMessages);

        final buildConfig = BuildConfig(
          outDir: tempUri,
          packageRoot: tempUri,
          targetArchitecture: Architecture.current,
          targetOs: OS.current,
          buildMode: BuildMode.release,
          linkModePreference: LinkModePreference.dynamic,
          cCompiler: CCompilerConfig(
            cc: cc,
            envScript: envScript,
            envScriptArgs: envScriptArgs,
          ),
        );
        final buildOutput = BuildOutput();

        final flag = switch (buildConfig.targetOs) {
          OS.windows => '/O2',
          _ => '-O2',
        };

        final cbuilder = CBuilder.library(
          sources: [addCUri.toFilePath()],
          name: name,
          assetId: name,
          flags: [flag],
        );
        await cbuilder.run(
          buildConfig: buildConfig,
          buildOutput: buildOutput,
          logger: logger,
        );

        final dylibUri = tempUri.resolve(Target.current.os.dylibFileName(name));

        final dylib = DynamicLibrary.open(dylibUri.toFilePath());
        final add = dylib.lookupFunction<Int32 Function(Int32, Int32),
            int Function(int, int)>('add');
        expect(add(1, 2), 3);

        final compilerInvocation = logMessages.singleWhere(
          (message) => message.contains(addCUri.toFilePath()),
        );
        expect(compilerInvocation, contains(flag));
      },
    );
  });

  test('CBuilder includes', () async {
    await inTempDir(
      // https://github.com/dart-lang/sdk/issues/40159
      keepTemp: Platform.isWindows,
      (tempUri) async {
        final includeDirectoryUri =
            packageUri.resolve('test/cbuilder/testfiles/includes/include');
        final includesHUri = packageUri
            .resolve('test/cbuilder/testfiles/includes/include/includes.h');
        final includesCUri = packageUri
            .resolve('test/cbuilder/testfiles/includes/src/includes.c');
        const name = 'includes';

        final buildConfig = BuildConfig(
          outDir: tempUri,
          packageRoot: tempUri,
          targetArchitecture: Architecture.current,
          targetOs: OS.current,
          buildMode: BuildMode.release,
          linkModePreference: LinkModePreference.dynamic,
          cCompiler: CCompilerConfig(
            cc: cc,
            envScript: envScript,
            envScriptArgs: envScriptArgs,
          ),
        );
        final buildOutput = BuildOutput();

        final cbuilder = CBuilder.library(
          name: name,
          assetId: name,
          includes: [includeDirectoryUri.toFilePath()],
          sources: [includesCUri.toFilePath()],
        );
        await cbuilder.run(
          buildConfig: buildConfig,
          buildOutput: buildOutput,
          logger: logger,
        );

        expect(buildOutput.dependencies.dependencies, contains(includesHUri));

        final dylibUri = tempUri.resolve(Target.current.os.dylibFileName(name));
        final dylib = DynamicLibrary.open(dylibUri.toFilePath());
        final x = dylib.lookup<Int>('x');
        expect(x.value, 42);
      },
    );
  });

  test('CBuilder std', () async {
    await inTempDir(
      // https://github.com/dart-lang/sdk/issues/40159
      keepTemp: Platform.isWindows,
      (tempUri) async {
        final addCUri =
            packageUri.resolve('test/cbuilder/testfiles/add/src/add.c');
        const name = 'add';
        const std = 'c99';

        final logMessages = <String>[];
        final logger = createCapturingLogger(logMessages);

        final buildConfig = BuildConfig(
          outDir: tempUri,
          packageRoot: tempUri,
          targetArchitecture: Architecture.current,
          targetOs: OS.current,
          buildMode: BuildMode.release,
          linkModePreference: LinkModePreference.dynamic,
          cCompiler: CCompilerConfig(
            cc: cc,
            envScript: envScript,
            envScriptArgs: envScriptArgs,
          ),
        );
        final buildOutput = BuildOutput();

        final stdFlag = switch (buildConfig.targetOs) {
          OS.windows => '/std:$std',
          _ => '-std=$std',
        };

        final cbuilder = CBuilder.library(
          sources: [addCUri.toFilePath()],
          name: name,
          assetId: name,
          std: std,
        );
        await cbuilder.run(
          buildConfig: buildConfig,
          buildOutput: buildOutput,
          logger: logger,
        );

        final dylibUri = tempUri.resolve(Target.current.os.dylibFileName(name));

        final dylib = DynamicLibrary.open(dylibUri.toFilePath());
        final add = dylib.lookupFunction<Int32 Function(Int32, Int32),
            int Function(int, int)>('add');
        expect(add(1, 2), 3);

        final compilerInvocation = logMessages.singleWhere(
          (message) => message.contains(addCUri.toFilePath()),
        );
        expect(compilerInvocation, contains(stdFlag));
      },
    );
  });

  test('CBuilder cpp', () async {
    await inTempDir((tempUri) async {
      final helloWorldCppUri = packageUri.resolve(
          'test/cbuilder/testfiles/hello_world_cpp/src/hello_world_cpp.cc');
      if (!await File.fromUri(helloWorldCppUri).exists()) {
        throw Exception('Run the test from the root directory.');
      }
      const name = 'hello_world_cpp';

      final buildConfig = BuildConfig(
        buildMode: BuildMode.release,
        outDir: tempUri,
        packageRoot: tempUri,
        targetArchitecture: Architecture.current,
        targetOs: OS.current,
        // Ignored by executables.
        linkModePreference: LinkModePreference.dynamic,
        cCompiler: CCompilerConfig(
          cc: cc,
          envScript: envScript,
          envScriptArgs: envScriptArgs,
        ),
      );
      final buildOutput = BuildOutput();
      final cbuilder = CBuilder.executable(
        name: name,
        sources: [helloWorldCppUri.toFilePath()],
        cpp: true,
      );
      await cbuilder.run(
        buildConfig: buildConfig,
        buildOutput: buildOutput,
        logger: logger,
      );

      final executableUri =
          tempUri.resolve(Target.current.os.executableFileName(name));
      expect(await File.fromUri(executableUri).exists(), true);
      final result = await runProcess(
        executable: executableUri,
        logger: logger,
      );
      expect(result.exitCode, 0);
      expect(result.stdout.trim(), endsWith('Hello world.'));
    });
  });
}

Future<void> testDefines({
  BuildMode buildMode = BuildMode.debug,
  bool buildModeDefine = false,
  bool ndebugDefine = false,
  bool? customDefineWithValue,
}) async {
  await inTempDir((tempUri) async {
    final definesCUri =
        packageUri.resolve('test/cbuilder/testfiles/defines/src/defines.c');
    if (!await File.fromUri(definesCUri).exists()) {
      throw Exception('Run the test from the root directory.');
    }
    const name = 'defines';

    final buildConfig = BuildConfig(
      outDir: tempUri,
      packageRoot: tempUri,
      targetArchitecture: Architecture.current,
      targetOs: OS.current,
      buildMode: buildMode,
      // Ignored by executables.
      linkModePreference: LinkModePreference.dynamic,
      cCompiler: CCompilerConfig(
        cc: cc,
        envScript: envScript,
        envScriptArgs: envScriptArgs,
      ),
    );
    final buildOutput = BuildOutput();
    final cbuilder = CBuilder.executable(
      name: name,
      sources: [definesCUri.toFilePath()],
      defines: {
        if (customDefineWithValue != null)
          'FOO': customDefineWithValue ? 'BAR' : null,
      },
      buildModeDefine: buildModeDefine,
      ndebugDefine: ndebugDefine,
    );
    await cbuilder.run(
      buildConfig: buildConfig,
      buildOutput: buildOutput,
      logger: logger,
    );

    final executableUri =
        tempUri.resolve(Target.current.os.executableFileName(name));
    expect(await File.fromUri(executableUri).exists(), true);
    final result = await runProcess(
      executable: executableUri,
      logger: logger,
    );
    expect(result.exitCode, 0);

    if (buildModeDefine) {
      expect(
        result.stdout,
        contains('Macro ${buildMode.name.toUpperCase()} is defined: 1'),
      );
    } else {
      expect(
        result.stdout,
        contains('Macro ${buildMode.name.toUpperCase()} is undefined.'),
      );
    }

    if (ndebugDefine && buildMode != BuildMode.debug) {
      expect(
        result.stdout,
        contains('Macro NDEBUG is defined: 1'),
      );
    } else {
      expect(
        result.stdout,
        contains('Macro NDEBUG is undefined.'),
      );
    }

    if (customDefineWithValue != null) {
      expect(
        result.stdout,
        contains(
          'Macro FOO is defined: ${customDefineWithValue ? 'BAR' : '1'}',
        ),
      );
    } else {
      expect(
        result.stdout,
        contains('Macro FOO is undefined.'),
      );
    }
  });
}
