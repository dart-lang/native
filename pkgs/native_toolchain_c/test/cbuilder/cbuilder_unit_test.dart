// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:file/memory.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import '../utils/fake_process_manager.dart';

void main() {
  // An end-to-end run of [CBuilder.run] with both external seams faked: a
  // [MemoryFileSystem] for all file system access native_toolchain_c performs,
  // and a [FakeProcessManager] scripting the compiler resolution and the
  // compile invocation. No real compiler is invoked and no real files are
  // touched by native_toolchain_c, so this test is host-independent.
  //
  // Note: [BuildInput.outputDirectory] (from package:hooks) still creates its
  // directory on the real file system, so [tempDirForTest] is used for the
  // shared output directory, exactly as the integration tests do. Everything
  // native_toolchain_c itself touches goes through the [MemoryFileSystem].
  test('CBuilder.run with faked file system and process manager', () async {
    final fileSystem = MemoryFileSystem(
      style: Platform.isWindows
          ? FileSystemStyle.windows
          : FileSystemStyle.posix,
    );

    // The shared output directory has to live on the real file system because
    // `input.outputDirectory` (package:hooks) hardcodes `dart:io`.
    final outputDirectoryShared = await tempDirForTest();
    final packageRoot = await tempDirForTest();

    const name = 'mylib';
    const targetOS = OS.linux;
    const targetArchitecture = Architecture.x64;

    // A deterministic toolchain provided via the input config, so compiler
    // resolution does not depend on the host machine. The file has to exist in
    // the (memory) file system, because the compiler resolver asserts it does.
    // Naming it with the host `executableFileName` keeps the compiler
    // recognizer (which uses `OS.current`) working on every host.
    final ccUri = packageRoot.resolve(OS.current.executableFileName('clang'));
    final arUri = packageRoot.resolve(OS.current.executableFileName('llvm-ar'));
    final ldUri = packageRoot.resolve(OS.current.executableFileName('ld.lld'));
    for (final toolUri in [ccUri, arUri, ldUri]) {
      fileSystem.file(toolUri)
        ..createSync(recursive: true)
        ..writeAsStringSync('');
    }

    // A fake C source file in the memory file system.
    final sourceUri = packageRoot.resolve('src.c');
    fileSystem.file(sourceUri)
      ..createSync(recursive: true)
      ..writeAsStringSync('int foo() { return 0; }\n');

    final ccPath = ccUri.toFilePath();

    // Script the process invocations: two `clang --version` calls (one by the
    // compiler recognizer, one by the version lookup), then the compile itself.
    // The compile's `onRun` creates the expected output library in the memory
    // file system so any downstream exists-checks are satisfied.
    const versionStdout = 'clang version 14.0.0\n';
    final fakeProcessManager = FakeProcessManager([
      FakeCommand(command: [ccPath, '--version'], stdout: versionStdout),
      FakeCommand(command: [ccPath, '--version'], stdout: versionStdout),
      FakeCommand(
        onRun: (command) {
          final outIndex = command.indexOf('-o');
          expect(outIndex, greaterThanOrEqualTo(0));
          fileSystem.file(command[outIndex + 1]).createSync(recursive: true);
        },
      ),
    ]);

    final buildInputBuilder = BuildInputBuilder()
      ..setupShared(
        packageName: name,
        packageRoot: packageRoot,
        outputFile: outputDirectoryShared.resolve('output.json'),
        outputDirectoryShared: outputDirectoryShared,
      )
      ..config.setupBuild(linkingEnabled: false)
      ..addExtension(
        CodeAssetExtension(
          targetOS: targetOS,
          targetArchitecture: targetArchitecture,
          linkModePreference: LinkModePreference.dynamic,
          cCompiler: CCompilerConfig(
            archiver: arUri,
            compiler: ccUri,
            linker: ldUri,
          ),
        ),
      );
    final buildInput = buildInputBuilder.build();
    final buildOutput = BuildOutputBuilder();

    final cbuilder = CBuilder.library(
      name: name,
      assetName: name,
      sources: [sourceUri.toFilePath()],
    );

    await cbuilder.run(
      input: buildInput,
      output: buildOutput,
      logger: logger,
      processManager: fakeProcessManager,
      fileSystem: fileSystem,
    );

    // Every scripted command was consumed, in order.
    expect(fakeProcessManager.allCommandsConsumed, true);
    final invocations = fakeProcessManager.invocations;
    expect(invocations.length, 3);
    expect(invocations[0].command, [ccPath, '--version']);
    expect(invocations[1].command, [ccPath, '--version']);

    // The compile invocation runs the provided compiler on the source file and
    // writes the shared library.
    final compileCommand = invocations[2].command;
    expect(compileCommand.first, ccPath);
    expect(compileCommand, contains(sourceUri.toFilePath()));
    expect(compileCommand, contains('--shared'));
    final outIndex = compileCommand.indexOf('-o');
    expect(outIndex, greaterThanOrEqualTo(0));
    final outputLibraryPath = compileCommand[outIndex + 1];

    // The scripted output exists in the memory file system.
    expect(fileSystem.file(outputLibraryPath).existsSync(), true);
    expect(
      outputLibraryPath,
      endsWith(targetOS.libraryFileName(name, DynamicLoadingBundled())),
    );
  });
}
