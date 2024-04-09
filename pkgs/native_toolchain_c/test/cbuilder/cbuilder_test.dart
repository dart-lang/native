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
  test('Langauge.toString', () {
    expect(Language.c.toString(), 'c');
    expect(Language.cpp.toString(), 'c++');
  });

  for (final pic in [null, true, false]) {
    final picTag =
        switch (pic) { null => 'auto_pic', true => 'pic', false => 'no_pic' };

    for (final buildMode in BuildMode.values) {
      final suffix = testSuffix([buildMode, picTag]);

      test('CBuilder executable$suffix', () async {
        final tempUri = await tempDirForTest();
        final helloWorldCUri = packageUri
            .resolve('test/cbuilder/testfiles/hello_world/src/hello_world.c');
        if (!await File.fromUri(helloWorldCUri).exists()) {
          throw Exception('Run the test from the root directory.');
        }
        const name = 'hello_world';

        final logMessages = <String>[];
        final logger = createCapturingLogger(logMessages);

        final buildConfig = BuildConfig.build(
          outputDirectory: tempUri,
          packageName: name,
          packageRoot: tempUri,
          targetArchitecture: Architecture.current,
          targetOS: OS.current,
          buildMode: buildMode,
          // Ignored by executables.
          linkModePreference: LinkModePreference.dynamic,
          cCompiler: CCompilerConfig(
            compiler: cc,
            envScript: envScript,
            envScriptArgs: envScriptArgs,
          ),
        );
        final buildOutput = BuildOutput();
        final cbuilder = CBuilder.executable(
          name: name,
          sources: [helloWorldCUri.toFilePath()],
          pie: pic,
          dartBuildFiles: ['hook/build.dart'],
        );
        await cbuilder.run(
          buildConfig: buildConfig,
          buildOutput: buildOutput,
          logger: logger,
        );

        final executableUri =
            tempUri.resolve(OS.current.executableFileName(name));
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

        switch ((buildConfig.targetOS, pic)) {
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
    }

    for (final dryRun in [true, false]) {
      final suffix = testSuffix([if (dryRun) 'dry_run', picTag]);

      test('CBuilder dylib$suffix', () async {
        final tempUri = await tempDirForTest();
        final addCUri =
            packageUri.resolve('test/cbuilder/testfiles/add/src/add.c');
        const name = 'add';

        final logMessages = <String>[];
        final logger = createCapturingLogger(logMessages);

        final buildConfig = dryRun
            ? BuildConfig.dryRun(
                outDir: tempUri,
                packageName: name,
                packageRoot: tempUri,
                targetOS: OS.current,
                linkModePreference: LinkModePreference.dynamic,
              )
            : BuildConfig.build(
                outputDirectory: tempUri,
                packageName: name,
                packageRoot: tempUri,
                targetArchitecture: Architecture.current,
                targetOS: OS.current,
                buildMode: BuildMode.release,
                linkModePreference: LinkModePreference.dynamic,
                cCompiler: CCompilerConfig(
                  compiler: cc,
                  envScript: envScript,
                  envScriptArgs: envScriptArgs,
                ),
              );
        final buildOutput = BuildOutput();

        final cbuilder = CBuilder.library(
          sources: [addCUri.toFilePath()],
          name: name,
          assetName: name,
          pic: pic,
          dartBuildFiles: ['hook/build.dart'],
        );
        await cbuilder.run(
          buildConfig: buildConfig,
          buildOutput: buildOutput,
          logger: logger,
        );

        final dylibUri = tempUri.resolve(OS.current.dylibFileName(name));
        expect(await File.fromUri(dylibUri).exists(), !dryRun);
        if (!dryRun) {
          final dylib = openDynamicLibraryForTest(dylibUri.toFilePath());
          final add = dylib.lookupFunction<Int32 Function(Int32, Int32),
              int Function(int, int)>('add');
          expect(add(1, 2), 3);

          final compilerInvocation = logMessages.singleWhere(
            (message) => message.contains(addCUri.toFilePath()),
          );
          switch ((buildConfig.targetOS, pic)) {
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
    final tempUri = await tempDirForTest();
    final definesCUri =
        packageUri.resolve('test/cbuilder/testfiles/defines/src/defines.c');
    if (!await File.fromUri(definesCUri).exists()) {
      throw Exception('Run the test from the root directory.');
    }
    const name = 'defines';

    final logMessages = <String>[];
    final logger = createCapturingLogger(logMessages);

    final buildConfig = BuildConfig.build(
      outputDirectory: tempUri,
      packageName: name,
      packageRoot: tempUri,
      targetArchitecture: Architecture.current,
      targetOS: OS.current,
      buildMode: BuildMode.release,
      // Ignored by executables.
      linkModePreference: LinkModePreference.dynamic,
      cCompiler: CCompilerConfig(
        compiler: cc,
        envScript: envScript,
        envScriptArgs: envScriptArgs,
      ),
    );
    final buildOutput = BuildOutput();

    final flag = switch (buildConfig.targetOS) {
      OS.windows => '/DFOO=USER_FLAG',
      _ => '-DFOO=USER_FLAG',
    };

    final cbuilder = CBuilder.executable(
      name: name,
      sources: [definesCUri.toFilePath()],
      flags: [flag],
      dartBuildFiles: ['hook/build.dart'],
    );
    await cbuilder.run(
      buildConfig: buildConfig,
      buildOutput: buildOutput,
      logger: logger,
    );

    final executableUri = tempUri.resolve(OS.current.executableFileName(name));
    expect(await File.fromUri(executableUri).exists(), true);
    final result = await runProcess(
      executable: executableUri,
      logger: logger,
    );
    expect(result.exitCode, 0);
    expect(result.stdout, contains('Macro FOO is defined: USER_FLAG'));

    final compilerInvocation = logMessages.singleWhere(
      (message) => message.contains(definesCUri.toFilePath()),
    );
    expect(compilerInvocation, contains(flag));
  });

  test('CBuilder includes', () async {
    final tempUri = await tempDirForTest();
    final includeDirectoryUri =
        packageUri.resolve('test/cbuilder/testfiles/includes/include');
    final includesHUri = packageUri
        .resolve('test/cbuilder/testfiles/includes/include/includes.h');
    final includesCUri =
        packageUri.resolve('test/cbuilder/testfiles/includes/src/includes.c');
    const name = 'includes';

    final buildConfig = BuildConfig.build(
      outputDirectory: tempUri,
      packageName: name,
      packageRoot: tempUri,
      targetArchitecture: Architecture.current,
      targetOS: OS.current,
      buildMode: BuildMode.release,
      linkModePreference: LinkModePreference.dynamic,
      cCompiler: CCompilerConfig(
        compiler: cc,
        envScript: envScript,
        envScriptArgs: envScriptArgs,
      ),
    );
    final buildOutput = BuildOutput();

    final cbuilder = CBuilder.library(
      name: name,
      assetName: name,
      includes: [includeDirectoryUri.toFilePath()],
      sources: [includesCUri.toFilePath()],
      dartBuildFiles: ['hook/build.dart'],
    );
    await cbuilder.run(
      buildConfig: buildConfig,
      buildOutput: buildOutput,
      logger: logger,
    );

    expect(buildOutput.dependencies, contains(includesHUri));

    final dylibUri = tempUri.resolve(OS.current.dylibFileName(name));
    final dylib = openDynamicLibraryForTest(dylibUri.toFilePath());
    final x = dylib.lookup<Int>('x');
    expect(x.value, 42);
  });

  test('CBuilder std', () async {
    final tempUri = await tempDirForTest();
    final addCUri = packageUri.resolve('test/cbuilder/testfiles/add/src/add.c');
    const name = 'add';
    const std = 'c99';

    final logMessages = <String>[];
    final logger = createCapturingLogger(logMessages);

    final buildConfig = BuildConfig.build(
      outputDirectory: tempUri,
      packageName: name,
      packageRoot: tempUri,
      targetArchitecture: Architecture.current,
      targetOS: OS.current,
      buildMode: BuildMode.release,
      linkModePreference: LinkModePreference.dynamic,
      cCompiler: CCompilerConfig(
        compiler: cc,
        envScript: envScript,
        envScriptArgs: envScriptArgs,
      ),
    );
    final buildOutput = BuildOutput();

    final stdFlag = switch (buildConfig.targetOS) {
      OS.windows => '/std:$std',
      _ => '-std=$std',
    };

    final cbuilder = CBuilder.library(
      sources: [addCUri.toFilePath()],
      name: name,
      assetName: name,
      std: std,
      dartBuildFiles: ['hook/build.dart'],
    );
    await cbuilder.run(
      buildConfig: buildConfig,
      buildOutput: buildOutput,
      logger: logger,
    );

    final dylibUri = tempUri.resolve(OS.current.dylibFileName(name));

    final dylib = openDynamicLibraryForTest(dylibUri.toFilePath());
    final add = dylib.lookupFunction<Int32 Function(Int32, Int32),
        int Function(int, int)>('add');
    expect(add(1, 2), 3);

    final compilerInvocation = logMessages.singleWhere(
      (message) => message.contains(addCUri.toFilePath()),
    );
    expect(compilerInvocation, contains(stdFlag));
  });

  test('CBuilder compile c++', () async {
    final tempUri = await tempDirForTest();
    final helloWorldCppUri = packageUri.resolve(
        'test/cbuilder/testfiles/hello_world_cpp/src/hello_world_cpp.cc');
    if (!await File.fromUri(helloWorldCppUri).exists()) {
      throw Exception('Run the test from the root directory.');
    }
    const name = 'hello_world_cpp';

    final logMessages = <String>[];
    final logger = createCapturingLogger(logMessages);

    final buildConfig = BuildConfig.build(
      buildMode: BuildMode.release,
      outputDirectory: tempUri,
      packageName: name,
      packageRoot: tempUri,
      targetArchitecture: Architecture.current,
      targetOS: OS.current,
      // Ignored by executables.
      linkModePreference: LinkModePreference.dynamic,
      cCompiler: CCompilerConfig(
        compiler: cc,
        envScript: envScript,
        envScriptArgs: envScriptArgs,
      ),
    );
    final buildOutput = BuildOutput();

    final defaultStdLibLinkFlag = switch (buildConfig.targetOS) {
      OS.windows => null,
      OS.linux => '-l stdc++',
      OS.macOS => '-l c++',
      _ => throw UnimplementedError(),
    };

    final cbuilder = CBuilder.executable(
      name: name,
      sources: [helloWorldCppUri.toFilePath()],
      language: Language.cpp,
      dartBuildFiles: ['hook/build.dart'],
    );
    await cbuilder.run(
      buildConfig: buildConfig,
      buildOutput: buildOutput,
      logger: logger,
    );

    final executableUri = tempUri.resolve(OS.current.executableFileName(name));
    expect(await File.fromUri(executableUri).exists(), true);
    final result = await runProcess(
      executable: executableUri,
      logger: logger,
    );
    expect(result.exitCode, 0);
    expect(result.stdout.trim(), endsWith('Hello world.'));

    if (defaultStdLibLinkFlag != null) {
      final compilerInvocation = logMessages.singleWhere(
        (message) => message.contains(helloWorldCppUri.toFilePath()),
      );
      expect(compilerInvocation, contains(defaultStdLibLinkFlag));
    }
  });

  test('CBuilder cppLinkStdLib', () async {
    final tempUri = await tempDirForTest();
    final helloWorldCppUri = packageUri.resolve(
        'test/cbuilder/testfiles/hello_world_cpp/src/hello_world_cpp.cc');
    if (!await File.fromUri(helloWorldCppUri).exists()) {
      throw Exception('Run the test from the root directory.');
    }
    const name = 'hello_world_cpp';

    final logMessages = <String>[];
    final logger = createCapturingLogger(logMessages);

    final buildConfig = BuildConfig.build(
      buildMode: BuildMode.release,
      outputDirectory: tempUri,
      packageName: name,
      packageRoot: tempUri,
      targetArchitecture: Architecture.current,
      targetOS: OS.current,
      // Ignored by executables.
      linkModePreference: LinkModePreference.dynamic,
      cCompiler: CCompilerConfig(
        compiler: cc,
        envScript: envScript,
        envScriptArgs: envScriptArgs,
      ),
    );
    final buildOutput = BuildOutput();
    final cbuilder = CBuilder.executable(
      name: name,
      sources: [helloWorldCppUri.toFilePath()],
      language: Language.cpp,
      cppLinkStdLib: 'stdc++',
      dartBuildFiles: ['hook/build.dart'],
    );

    if (buildConfig.targetOS == OS.windows) {
      await expectLater(
        () => cbuilder.run(
          buildConfig: buildConfig,
          buildOutput: buildOutput,
          logger: logger,
        ),
        throwsArgumentError,
      );
    } else {
      await cbuilder.run(
        buildConfig: buildConfig,
        buildOutput: buildOutput,
        logger: logger,
      );

      final executableUri =
          tempUri.resolve(OS.current.executableFileName(name));
      expect(await File.fromUri(executableUri).exists(), true);
      final result = await runProcess(
        executable: executableUri,
        logger: logger,
      );
      expect(result.exitCode, 0);
      expect(result.stdout.trim(), endsWith('Hello world.'));

      final compilerInvocation = logMessages.singleWhere(
        (message) => message.contains(helloWorldCppUri.toFilePath()),
      );
      expect(compilerInvocation, contains('-l stdc++'));
    }
  });
}

Future<void> testDefines({
  BuildMode buildMode = BuildMode.debug,
  bool buildModeDefine = false,
  bool ndebugDefine = false,
  bool? customDefineWithValue,
}) async {
  final tempUri = await tempDirForTest();
  final definesCUri =
      packageUri.resolve('test/cbuilder/testfiles/defines/src/defines.c');
  if (!await File.fromUri(definesCUri).exists()) {
    throw Exception('Run the test from the root directory.');
  }
  const name = 'defines';

  final buildConfig = BuildConfig.build(
    outputDirectory: tempUri,
    packageName: name,
    packageRoot: tempUri,
    targetArchitecture: Architecture.current,
    targetOS: OS.current,
    buildMode: buildMode,
    // Ignored by executables.
    linkModePreference: LinkModePreference.dynamic,
    cCompiler: CCompilerConfig(
      compiler: cc,
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
    dartBuildFiles: ['hook/build.dart'],
  );
  await cbuilder.run(
    buildConfig: buildConfig,
    buildOutput: buildOutput,
    logger: logger,
  );

  final executableUri = tempUri.resolve(OS.current.executableFileName(name));
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
}
