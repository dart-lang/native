// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
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
  // An end-to-end run of [CLinker.run] with both external seams faked: a
  // [MemoryFileSystem] for all file system access native_toolchain_c performs,
  // and a [FakeProcessManager] scripting the compiler resolution and the link
  // invocation. No real linker is invoked and no real files are touched by
  // native_toolchain_c, so this test is host-independent.
  //
  // Note: [LinkInput.outputDirectory] (from package:hooks) still creates its
  // directory on the real file system, so [tempDirForTest] is used for the
  // shared output directory, exactly as the integration tests do. Everything
  // native_toolchain_c itself touches goes through the [MemoryFileSystem].
  test('CLinker.run with faked file system and process manager', () async {
    final fileSystem = MemoryFileSystem(
      style: Platform.isWindows
          ? FileSystemStyle.windows
          : FileSystemStyle.posix,
    );

    final outputDirectoryShared = await tempDirForTest();
    final packageRoot = await tempDirForTest();

    const name = 'mylib';
    const targetOS = OS.linux;
    const targetArchitecture = Architecture.x64;

    final ccUri = packageRoot.resolve(OS.current.executableFileName('clang'));
    final arUri = packageRoot.resolve(OS.current.executableFileName('llvm-ar'));
    final ldUri = packageRoot.resolve(OS.current.executableFileName('ld.lld'));
    for (final toolUri in [ccUri, arUri, ldUri]) {
      fileSystem.file(toolUri)
        ..createSync(recursive: true)
        ..writeAsStringSync('');
    }

    final sourceUri = packageRoot.resolve('src.c');
    fileSystem.file(sourceUri)
      ..createSync(recursive: true)
      ..writeAsStringSync('int foo() { return 0; }\n');
    final includeUri = packageRoot.resolve('include');
    fileSystem.directory(includeUri).createSync(recursive: true);
    final headerUri = packageRoot.resolve('include/header.h');
    fileSystem.file(headerUri)
      ..createSync(recursive: true)
      ..writeAsStringSync('int foo();\n');

    final ccPath = ccUri.toFilePath();

    const versionStdout = 'clang version 14.0.0\n';
    final fakeProcessManager = FakeProcessManager([
      FakeCommand(command: [ccPath, '--version'], stdout: versionStdout),
      FakeCommand(command: [ccPath, '--version'], stdout: versionStdout),
      FakeCommand(
        onRun: (command) {
          final outIndex = command.indexOf('-o');
          if (outIndex >= 0 && outIndex + 1 < command.length) {
            fileSystem.file(command[outIndex + 1]).createSync(recursive: true);
          }
        },
      ),
    ]);

    final linkInputBuilder = LinkInputBuilder()
      ..setupShared(
        packageName: name,
        packageRoot: packageRoot,
        outputFile: outputDirectoryShared.resolve('output.json'),
        outputDirectoryShared: outputDirectoryShared,
      )
      ..setupLink(assets: [], recordedUsesFile: null, assetsFromLinking: [])
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
    final linkInput = linkInputBuilder.build();
    final linkOutput = LinkOutputBuilder();

    final clinker = CLinker.library(
      name: name,
      assetName: name,
      linkerOptions: LinkerOptions.manual(gcSections: false),
      sources: [sourceUri.toFilePath()],
      includes: ['include'],
    );

    await clinker.run(
      input: linkInput,
      output: linkOutput,
      logger: logger,
      processManager: fakeProcessManager,
      fileSystem: fileSystem,
    );

    expect(fakeProcessManager.allCommandsConsumed, true);
    expect(linkOutput.build().dependencies, contains(sourceUri));
    expect(linkOutput.build().dependencies, contains(headerUri));
  });

  test('CLinker.run with trackDependencies disabled', () async {
    final fileSystem = MemoryFileSystem(
      style: Platform.isWindows
          ? FileSystemStyle.windows
          : FileSystemStyle.posix,
    );

    final outputDirectoryShared = await tempDirForTest();
    final packageRoot = await tempDirForTest();

    const name = 'mylib';
    const targetOS = OS.linux;
    const targetArchitecture = Architecture.x64;

    final ccUri = packageRoot.resolve(OS.current.executableFileName('clang'));
    final arUri = packageRoot.resolve(OS.current.executableFileName('llvm-ar'));
    final ldUri = packageRoot.resolve(OS.current.executableFileName('ld.lld'));
    for (final toolUri in [ccUri, arUri, ldUri]) {
      fileSystem.file(toolUri)
        ..createSync(recursive: true)
        ..writeAsStringSync('');
    }

    final sourceUri = packageRoot.resolve('src.c');
    fileSystem.file(sourceUri)
      ..createSync(recursive: true)
      ..writeAsStringSync('int foo() { return 0; }\n');
    final includeUri = packageRoot.resolve('include');
    fileSystem.directory(includeUri).createSync(recursive: true);
    final headerUri = packageRoot.resolve('include/header.h');
    fileSystem.file(headerUri)
      ..createSync(recursive: true)
      ..writeAsStringSync('int foo();\n');

    final ccPath = ccUri.toFilePath();

    const versionStdout = 'clang version 14.0.0\n';
    final fakeProcessManager = FakeProcessManager([
      FakeCommand(command: [ccPath, '--version'], stdout: versionStdout),
      FakeCommand(command: [ccPath, '--version'], stdout: versionStdout),
      FakeCommand(
        onRun: (command) {
          final outIndex = command.indexOf('-o');
          if (outIndex >= 0 && outIndex + 1 < command.length) {
            fileSystem.file(command[outIndex + 1]).createSync(recursive: true);
          }
        },
      ),
    ]);

    final linkInputBuilder = LinkInputBuilder()
      ..setupShared(
        packageName: name,
        packageRoot: packageRoot,
        outputFile: outputDirectoryShared.resolve('output.json'),
        outputDirectoryShared: outputDirectoryShared,
      )
      ..setupLink(assets: [], recordedUsesFile: null, assetsFromLinking: [])
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
    final linkInput = linkInputBuilder.build();
    final linkOutput = LinkOutputBuilder();

    final clinker = CLinker.library(
      name: name,
      assetName: name,
      linkerOptions: LinkerOptions.manual(gcSections: false),
      sources: [sourceUri.toFilePath()],
      includes: ['include'],
      trackDependencies: false,
    );

    await clinker.run(
      input: linkInput,
      output: linkOutput,
      logger: logger,
      processManager: fakeProcessManager,
      fileSystem: fileSystem,
    );

    expect(fakeProcessManager.allCommandsConsumed, true);
    expect(linkOutput.build().dependencies, isEmpty);
  });
}
