// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@OnPlatform({'mac-os': Timeout.factor(2), 'windows': Timeout.factor(10)})
library;

import 'dart:ffi';
import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:native_toolchain_c/src/utils/run_process.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  test('Language.toString', () {
    expect(Language.c.toString(), 'c');
    expect(Language.cpp.toString(), 'c++');
  });

  final targetOS = OS.current;
  final macOSConfig = targetOS == OS.macOS
      ? MacOSCodeConfig(targetVersion: defaultMacOSVersion)
      : null;
  for (final pic in [null, true, false]) {
    final picTag = switch (pic) {
      null => 'auto_pic',
      true => 'pic',
      false => 'no_pic',
    };

    for (final buildMode in BuildMode.values) {
      final suffix = testSuffix([buildMode, picTag]);

      test('CBuilder executable$suffix', () async {
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
              // Ignored by executables.
              linkModePreference: LinkModePreference.dynamic,
              cCompiler: cCompiler,
            ),
          );

        final buildInput = buildInputBuilder.build();
        final buildOutput = BuildOutputBuilder();

        final cbuilder = CBuilder.executable(
          name: name,
          sources: [helloWorldCUri.toFilePath()],
          pie: pic,
          buildMode: buildMode,
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

        switch ((buildInput.config.code.targetOS, pic)) {
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

    for (final buildCodeAssets in [true, false]) {
      final suffix = testSuffix([picTag]);

      test('CBuilder dylib$suffix', () async {
        final tempUri = await tempDirForTest();
        final tempUri2 = await tempDirForTest();
        final addCUri = packageUri.resolve(
          'test/cbuilder/testfiles/add/src/add.c',
        );
        const name = 'add';

        final logMessages = <String>[];
        final logger = createCapturingLogger(logMessages);

        final buildInputBuilder = BuildInputBuilder()
          ..setupShared(
            packageName: name,
            packageRoot: tempUri,
            outputFile: tempUri.resolve('output.json'),
            outputDirectoryShared: tempUri2,
          )
          ..config.setupBuild(linkingEnabled: false);
        if (buildCodeAssets) {
          buildInputBuilder.addExtension(
            CodeAssetExtension(
              targetOS: targetOS,
              macOS: macOSConfig,
              targetArchitecture: Architecture.current,
              linkModePreference: LinkModePreference.dynamic,
              cCompiler: cCompiler,
            ),
          );
        }

        final buildInput = buildInputBuilder.build();
        final buildOutput = BuildOutputBuilder();

        final cbuilder = CBuilder.library(
          sources: [addCUri.toFilePath()],
          name: name,
          assetName: name,
          pic: pic,
          buildMode: BuildMode.release,
        );
        await cbuilder.run(
          input: buildInput,
          output: buildOutput,
          logger: logger,
        );

        final dylibUri = buildInput.outputDirectory.resolve(
          OS.current.dylibFileName(name),
        );
        expect(await File.fromUri(dylibUri).exists(), equals(buildCodeAssets));
        if (buildCodeAssets) {
          final dylib = openDynamicLibraryForTest(dylibUri.toFilePath());
          final add = dylib
              .lookupFunction<
                Int32 Function(Int32, Int32),
                int Function(int, int)
              >('add');
          expect(add(1, 2), 3);

          final compilerInvocation = logMessages.singleWhere(
            (message) => message.contains(addCUri.toFilePath()),
          );
          switch ((buildInput.config.code.targetOS, pic)) {
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
    final tempUri2 = await tempDirForTest();
    final definesCUri = packageUri.resolve(
      'test/cbuilder/testfiles/defines/src/defines.c',
    );
    if (!await File.fromUri(definesCUri).exists()) {
      throw Exception('Run the test from the root directory.');
    }
    final forcedIncludeCUri = packageUri.resolve(
      'test/cbuilder/testfiles/defines/src/forcedInclude.c',
    );
    const name = 'defines';

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
          // Ignored by executables.
          linkModePreference: LinkModePreference.dynamic,
          cCompiler: cCompiler,
        ),
      );
    final buildInput = buildInputBuilder.build();
    final buildOutput = BuildOutputBuilder();

    final flag = switch (buildInput.config.code.targetOS) {
      OS.windows => '/DFOO=USER_FLAG',
      _ => '-DFOO=USER_FLAG',
    };

    final cbuilder = CBuilder.executable(
      name: name,
      sources: [definesCUri.toFilePath()],
      forcedIncludes: [forcedIncludeCUri.toFilePath()],
      flags: [flag],
      buildMode: BuildMode.release,
    );
    await cbuilder.run(input: buildInput, output: buildOutput, logger: logger);

    final executableUri = buildInput.outputDirectory.resolve(
      OS.current.executableFileName(name),
    );
    expect(await File.fromUri(executableUri).exists(), true);
    final result = await runProcess(executable: executableUri, logger: logger);
    expect(result.exitCode, 0);
    expect(result.stdout, contains('Macro FOO is defined: USER_FLAG'));
    // Check the forced include is added.
    expect(result.stdout, contains('Macro FIFOO is defined: "QuotedFIFOO"'));

    final compilerInvocation = logMessages.singleWhere(
      (message) => message.contains(definesCUri.toFilePath()),
    );
    expect(compilerInvocation, contains(flag));
  });

  test('CBuilder includes', () async {
    final tempUri = await tempDirForTest();
    final tempUri2 = await tempDirForTest();
    final includeDirectoryUri = packageUri.resolve(
      'test/cbuilder/testfiles/includes/include',
    );
    final includesHUri = packageUri.resolve(
      'test/cbuilder/testfiles/includes/include/includes.h',
    );
    final includesCUri = packageUri.resolve(
      'test/cbuilder/testfiles/includes/src/includes.c',
    );
    const name = 'includes';

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
          // Ignored by executables.
          linkModePreference: LinkModePreference.dynamic,
          cCompiler: cCompiler,
        ),
      );

    final buildInput = buildInputBuilder.build();
    final buildOutputBuilder = BuildOutputBuilder();

    final cbuilder = CBuilder.library(
      name: name,
      assetName: name,
      includes: [includeDirectoryUri.toFilePath()],
      sources: [includesCUri.toFilePath()],
      buildMode: BuildMode.release,
    );
    await cbuilder.run(
      input: buildInput,
      output: buildOutputBuilder,
      logger: logger,
    );

    final buildOutput = buildOutputBuilder.build();
    expect(buildOutput.dependencies, contains(includesHUri));

    final dylibUri = buildInput.outputDirectory.resolve(
      OS.current.dylibFileName(name),
    );
    final dylib = openDynamicLibraryForTest(dylibUri.toFilePath());
    final x = dylib.lookup<Int>('x');
    expect(x.value, 42);
  });

  test('CBuilder std', () async {
    final tempUri = await tempDirForTest();
    final tempUri2 = await tempDirForTest();
    final addCUri = packageUri.resolve('test/cbuilder/testfiles/add/src/add.c');
    const name = 'add';
    const std = 'c99';

    final logMessages = <String>[];
    final logger = createCapturingLogger(logMessages);

    final targetOS = OS.current;
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
          // Ignored by executables.
          linkModePreference: LinkModePreference.dynamic,
          cCompiler: cCompiler,
        ),
      );

    final buildInput = buildInputBuilder.build();
    final buildOutput = BuildOutputBuilder();

    final stdFlag = switch (buildInput.config.code.targetOS) {
      OS.windows => '/std:$std',
      _ => '-std=$std',
    };

    final cbuilder = CBuilder.library(
      sources: [addCUri.toFilePath()],
      name: name,
      assetName: name,
      std: std,
      buildMode: BuildMode.release,
    );
    await cbuilder.run(input: buildInput, output: buildOutput, logger: logger);

    final dylibUri = buildInput.outputDirectory.resolve(
      OS.current.dylibFileName(name),
    );

    final dylib = openDynamicLibraryForTest(dylibUri.toFilePath());
    final add = dylib
        .lookupFunction<Int32 Function(Int32, Int32), int Function(int, int)>(
          'add',
        );
    expect(add(1, 2), 3);

    final compilerInvocation = logMessages.singleWhere(
      (message) => message.contains(addCUri.toFilePath()),
    );
    expect(compilerInvocation, contains(stdFlag));
  });

  test('CBuilder compile c++', () async {
    final tempUri = await tempDirForTest();
    final tempUri2 = await tempDirForTest();
    final helloWorldCppUri = packageUri.resolve(
      'test/cbuilder/testfiles/hello_world_cpp/src/hello_world_cpp.cc',
    );
    if (!await File.fromUri(helloWorldCppUri).exists()) {
      throw Exception('Run the test from the root directory.');
    }
    const name = 'hello_world_cpp';

    final logMessages = <String>[];
    final logger = createCapturingLogger(logMessages);

    final targetOS = OS.current;
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
          // Ignored by executables.
          linkModePreference: LinkModePreference.dynamic,
          cCompiler: cCompiler,
        ),
      );
    final buildInput = buildInputBuilder.build();
    final buildOutput = BuildOutputBuilder();

    final defaultStdLibLinkFlag = switch (buildInput.config.code.targetOS) {
      OS.windows => null,
      OS.linux => '-l stdc++',
      OS.macOS => '-l c++',
      _ => throw UnimplementedError(),
    };

    final cbuilder = CBuilder.executable(
      name: name,
      sources: [helloWorldCppUri.toFilePath()],
      language: Language.cpp,
      buildMode: BuildMode.release,
    );
    await cbuilder.run(input: buildInput, output: buildOutput, logger: logger);

    final executableUri = buildInput.outputDirectory.resolve(
      OS.current.executableFileName(name),
    );
    expect(await File.fromUri(executableUri).exists(), true);
    final result = await runProcess(executable: executableUri, logger: logger);
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
    final tempUri2 = await tempDirForTest();
    final helloWorldCppUri = packageUri.resolve(
      'test/cbuilder/testfiles/hello_world_cpp/src/hello_world_cpp.cc',
    );
    if (!await File.fromUri(helloWorldCppUri).exists()) {
      throw Exception('Run the test from the root directory.');
    }
    const name = 'hello_world_cpp';

    final logMessages = <String>[];
    final logger = createCapturingLogger(logMessages);

    final targetOS = OS.current;
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
          // Ignored by executables.
          linkModePreference: LinkModePreference.dynamic,
          cCompiler: cCompiler,
        ),
      );
    final buildInput = buildInputBuilder.build();
    final buildOutput = BuildOutputBuilder();

    final cbuilder = CBuilder.executable(
      name: name,
      sources: [helloWorldCppUri.toFilePath()],
      language: Language.cpp,
      cppLinkStdLib: 'stdc++',
      buildMode: BuildMode.release,
    );

    if (buildInput.config.code.targetOS == OS.windows) {
      await expectLater(
        () => cbuilder.run(
          input: buildInput,
          output: buildOutput,
          logger: logger,
        ),
        throwsArgumentError,
      );
    } else {
      await cbuilder.run(
        input: buildInput,
        output: buildOutput,
        logger: logger,
      );

      final executableUri = buildInput.outputDirectory.resolve(
        OS.current.executableFileName(name),
      );
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

  test('CBuilder libraries and libraryDirectories', () async {
    final tempUri = await tempDirForTest();
    final tempUri2 = await tempDirForTest();

    final dynamicallyLinkedSrcUri = packageUri.resolve(
      'test/cbuilder/testfiles/dynamically_linked/src/',
    );
    final dynamicallyLinkedCUri = dynamicallyLinkedSrcUri.resolve(
      'dynamically_linked.c',
    );
    final debugCUri = dynamicallyLinkedSrcUri.resolve('debug.c');
    final mathCUri = dynamicallyLinkedSrcUri.resolve('math.c');

    if (!await File.fromUri(dynamicallyLinkedCUri).exists()) {
      throw Exception('Run the test from the root directory.');
    }
    const name = 'dynamically_linked';

    final logMessages = <String>[];
    final logger = createCapturingLogger(logMessages);

    final targetOS = OS.current;
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
          // Ignored by executables.
          linkModePreference: LinkModePreference.dynamic,
          cCompiler: cCompiler,
        ),
      );
    final buildInput = buildInputBuilder.build();
    final buildOutput = BuildOutputBuilder();

    final debugBuilder = CBuilder.library(
      name: 'debug',
      assetName: 'debug',
      includes: [dynamicallyLinkedSrcUri.toFilePath()],
      sources: [debugCUri.toFilePath()],
      buildMode: BuildMode.release,
    );

    await debugBuilder.run(
      input: buildInput,
      output: buildOutput,
      logger: logger,
    );

    final debugLibraryFile = File.fromUri(
      buildInput.outputDirectory.resolve(OS.current.dylibFileName('debug')),
    );
    final nestedDebugLibraryFile = File.fromUri(
      buildInput.outputDirectory
          .resolve('debug/')
          .resolve(OS.current.dylibFileName('debug')),
    );
    await nestedDebugLibraryFile.parent.create(recursive: true);
    await debugLibraryFile.rename(nestedDebugLibraryFile.path);

    final mathBuilder = CBuilder.library(
      name: 'math',
      assetName: 'math',
      includes: [dynamicallyLinkedSrcUri.toFilePath()],
      sources: [mathCUri.toFilePath()],
      libraries: ['debug'],
      libraryDirectories: ['debug'],
    );

    await mathBuilder.run(
      input: buildInput,
      output: buildOutput,
      logger: logger,
    );

    await nestedDebugLibraryFile.rename(debugLibraryFile.path);

    final executableBuilder = CBuilder.executable(
      name: name,
      includes: [dynamicallyLinkedSrcUri.toFilePath()],
      sources: [dynamicallyLinkedCUri.toFilePath()],
      libraries: ['math'],
    );

    await executableBuilder.run(
      input: buildInput,
      output: buildOutput,
      logger: logger,
    );

    final executableUri = buildInput.outputDirectory.resolve(
      OS.current.executableFileName(name),
    );
    expect(await File.fromUri(executableUri).exists(), true);
    final result = await runProcess(executable: executableUri, logger: logger);
    expect(result.exitCode, 0);
  });
}

Future<void> testDefines({
  BuildMode buildMode = BuildMode.debug,
  bool buildModeDefine = false,
  bool ndebugDefine = false,
  bool? customDefineWithValue,
}) async {
  final tempUri = await tempDirForTest();
  final tempUri2 = await tempDirForTest();
  final definesCUri = packageUri.resolve(
    'test/cbuilder/testfiles/defines/src/defines.c',
  );
  if (!await File.fromUri(definesCUri).exists()) {
    throw Exception('Run the test from the root directory.');
  }
  const name = 'defines';

  final targetOS = OS.current;
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
        macOS: targetOS == OS.macOS
            ? MacOSCodeConfig(targetVersion: defaultMacOSVersion)
            : null,
        targetArchitecture: Architecture.current,
        // Ignored by executables.
        linkModePreference: LinkModePreference.dynamic,
        cCompiler: cCompiler,
      ),
    );

  final buildInput = buildInputBuilder.build();
  final buildOutput = BuildOutputBuilder();

  final cbuilder = CBuilder.executable(
    name: name,
    sources: [definesCUri.toFilePath()],
    defines: {
      if (customDefineWithValue != null)
        'FOO': customDefineWithValue ? 'BAR' : null,
    },
    buildModeDefine: buildModeDefine,
    ndebugDefine: ndebugDefine,
    buildMode: buildMode,
  );
  await cbuilder.run(input: buildInput, output: buildOutput, logger: logger);

  final executableUri = buildInput.outputDirectory.resolve(
    OS.current.executableFileName(name),
  );
  expect(await File.fromUri(executableUri).exists(), true);
  final result = await runProcess(executable: executableUri, logger: logger);
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
    expect(result.stdout, contains('Macro NDEBUG is defined: 1'));
  } else {
    expect(result.stdout, contains('Macro NDEBUG is undefined.'));
  }

  if (customDefineWithValue != null) {
    expect(
      result.stdout,
      contains('Macro FOO is defined: ${customDefineWithValue ? 'BAR' : '1'}'),
    );
  } else {
    expect(result.stdout, contains('Macro FOO is undefined.'));
  }
}
