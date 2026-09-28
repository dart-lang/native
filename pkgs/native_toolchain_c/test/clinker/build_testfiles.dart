// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:native_toolchain_c/src/utils/run_process.dart';
import 'package:process/process.dart';

import '../helpers.dart';

String _clangTargetTriple(
  OS targetOS,
  Architecture architecture, {
  int? androidTargetNdkApi,
  int? macOSTargetVersion,
  int? iOSTargetVersion,
  IOSSdk? iOSTargetSdk,
}) => switch ((targetOS, architecture)) {
  (OS.linux, Architecture.x64) => 'x86_64-unknown-linux-gnu',
  (OS.linux, Architecture.arm64) => 'aarch64-unknown-linux-gnu',
  (OS.linux, Architecture.arm) => 'armv7-unknown-linux-gnueabihf',
  (OS.linux, Architecture.ia32) => 'i686-unknown-linux-gnu',
  (OS.linux, Architecture.riscv64) => 'riscv64-unknown-linux-gnu',
  (OS.android, Architecture.arm64) =>
    'aarch64-linux-android${androidTargetNdkApi ?? 21}',
  (OS.android, Architecture.arm) =>
    'armv7a-linux-androideabi${androidTargetNdkApi ?? 21}',
  (OS.android, Architecture.x64) =>
    'x86_64-linux-android${androidTargetNdkApi ?? 21}',
  (OS.android, Architecture.ia32) =>
    'i686-linux-android${androidTargetNdkApi ?? 21}',
  (OS.android, Architecture.riscv64) =>
    'riscv64-linux-android${androidTargetNdkApi ?? 35}',
  (OS.macOS, Architecture.arm64) =>
    'arm64-apple-macosx${macOSTargetVersion ?? 13}.0',
  (OS.macOS, Architecture.arm64e) =>
    'arm64e-apple-macosx${macOSTargetVersion ?? 13}.0',
  (OS.macOS, Architecture.x64) =>
    'x86_64-apple-macosx${macOSTargetVersion ?? 13}.0',
  (OS.iOS, Architecture.arm64) =>
    iOSTargetSdk == IOSSdk.iPhoneSimulator
        ? 'arm64-apple-ios${iOSTargetVersion ?? 16}.0-simulator'
        : 'arm64-apple-ios${iOSTargetVersion ?? 16}.0',
  (OS.iOS, Architecture.arm64e) =>
    iOSTargetSdk == IOSSdk.iPhoneSimulator
        ? 'arm64e-apple-ios${iOSTargetVersion ?? 16}.0-simulator'
        : 'arm64e-apple-ios${iOSTargetVersion ?? 16}.0',
  (OS.iOS, Architecture.x64) =>
    'x86_64-apple-ios${iOSTargetVersion ?? 16}.0-simulator',
  (OS.windows, Architecture.x64) => 'x86_64-pc-windows-msvc',
  (OS.windows, Architecture.arm64) => 'aarch64-pc-windows-msvc',
  (OS.windows, Architecture.ia32) => 'i686-pc-windows-msvc',
  _ => throw UnsupportedError(
    'Unsupported target ($targetOS, $architecture) for test archive',
  ),
};

Future<Uri> _buildCrossTestArchive(
  Uri tempUri,
  OS targetOS,
  Architecture architecture,
  List<Uri> sources, {
  int? androidTargetNdkApi,
  int? macOSTargetVersion,
  int? iOSTargetVersion,
  IOSSdk? iOSTargetSdk,
}) async {
  final llvmReadobjUri = await resolveLlvmReadobj();
  if (llvmReadobjUri == null) {
    throw StateError('Unable to locate clang/llvm-ar in buildtools');
  }
  final clangUri = llvmReadobjUri.resolve(
    OS.current.executableFileName('clang'),
  );
  final llvmArUri = llvmReadobjUri.resolve(
    OS.current.executableFileName('llvm-ar'),
  );
  final stubIncludeDir = tempUri.resolve('stub_include/');
  await Directory.fromUri(stubIncludeDir).create(recursive: true);
  await File.fromUri(stubIncludeDir.resolve('stdio.h')).writeAsString('''
#ifndef _STUB_STDIO_H
#define _STUB_STDIO_H
int printf(const char* format, ...);
int puts(const char* s);
#endif
''');

  final triple = _clangTargetTriple(
    targetOS,
    architecture,
    androidTargetNdkApi: androidTargetNdkApi,
    macOSTargetVersion: macOSTargetVersion,
    iOSTargetVersion: iOSTargetVersion,
    iOSTargetSdk: iOSTargetSdk,
  );
  final objDir = tempUri.resolve('objs/');
  await Directory.fromUri(objDir).create(recursive: true);
  final objFiles = <String>[];
  for (var i = 0; i < sources.length; i++) {
    final objUri = objDir.resolve(
      'obj_$i${targetOS == OS.windows ? '.obj' : '.o'}',
    );
    final result = await runProcess(
      executable: clangUri,
      arguments: [
        '--target=$triple',
        '-nostdinc',
        '-isystem',
        stubIncludeDir.toFilePath(),
        '-O2',
        '-ffunction-sections',
        '-fdata-sections',
        if (targetOS != OS.windows) '-fPIC',
        '-c',
        sources[i].toFilePath(),
        '-o',
        objUri.toFilePath(),
      ],
      logger: logger,
      processManager: const LocalProcessManager(),
    );
    if (result.exitCode != 0) {
      throw StateError(
        'Failed to compile ${sources[i]} for $triple:\n${result.stderr}',
      );
    }
    objFiles.add(objUri.toFilePath());
  }

  final archiveUri = tempUri.resolve(
    targetOS.staticlibFileName('static_test'),
  );
  final arResult = await runProcess(
    executable: llvmArUri,
    arguments: ['rc', archiveUri.toFilePath(), ...objFiles],
    logger: logger,
    processManager: const LocalProcessManager(),
  );
  if (arResult.exitCode != 0) {
    throw StateError(
      'Failed to archive objects for $triple:\n${arResult.stderr}',
    );
  }
  return archiveUri;
}

Future<Uri> buildTestArchive(
  Uri tempUri,
  Uri tempUri2,
  OS targetOS,
  Architecture architecture, {
  List<Uri>? extraSources,
  int? androidTargetNdkApi, // Must be specified iff targetOS is OS.android.
  int? macOSTargetVersion, // Must be specified iff targetOS is OS.macos.
  int? iOSTargetVersion, // Must be specified iff targetOS is OS.iOS.
  IOSSdk? iOSTargetSdk, // Must be specified iff targetOS is OS.iOS.
}) async {
  if (targetOS == OS.android) {
    ArgumentError.checkNotNull(androidTargetNdkApi, 'androidTargetNdkApi');
  }
  if (targetOS == OS.macOS) {
    ArgumentError.checkNotNull(macOSTargetVersion, 'macOSTargetVersion');
  }
  if (targetOS == OS.iOS) {
    ArgumentError.checkNotNull(iOSTargetVersion, 'iOSTargetVersion');
    ArgumentError.checkNotNull(iOSTargetSdk, 'iOSTargetSdk');
  }

  final test1Uri = packageUri.resolve('test/clinker/testfiles/linker/test1.c');
  final test2Uri = packageUri.resolve('test/clinker/testfiles/linker/test2.c');
  if (!await File.fromUri(test1Uri).exists() ||
      !await File.fromUri(test2Uri).exists()) {
    throw Exception('Run the test from the root directory.');
  }
  final allSources = <Uri>[test1Uri, test2Uri, ...?extraSources];
  if (targetOS != OS.current) {
    return await _buildCrossTestArchive(
      tempUri,
      targetOS,
      architecture,
      allSources,
      androidTargetNdkApi: androidTargetNdkApi,
      macOSTargetVersion: macOSTargetVersion,
      iOSTargetVersion: iOSTargetVersion,
      iOSTargetSdk: iOSTargetSdk,
    );
  }
  const name = 'static_test';

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
        targetArchitecture: architecture,
        linkModePreference: LinkModePreference.dynamic,
        cCompiler: cCompiler,
        android: androidTargetNdkApi != null
            ? AndroidCodeConfig(targetNdkApi: androidTargetNdkApi)
            : null,
        macOS: macOSTargetVersion != null
            ? MacOSCodeConfig(targetVersion: macOSTargetVersion)
            : null,
        iOS: iOSTargetVersion != null && iOSTargetSdk != null
            ? IOSCodeConfig(
                targetSdk: iOSTargetSdk,
                targetVersion: iOSTargetVersion,
              )
            : null,
      ),
    );

  final buildInput = buildInputBuilder.build();
  final buildOutputBuilder = BuildOutputBuilder();

  final cbuilder = CBuilder.library(
    name: name,
    assetName: '',
    sources: [for (final src in allSources) src.toFilePath()],
    linkModePreference: LinkModePreference.static,
    buildMode: BuildMode.release,
  );
  try {
    await cbuilder.run(
      input: buildInput,
      output: buildOutputBuilder,
      logger: logger,
    );
    final buildOutput = buildOutputBuilder.build();
    return buildOutput.assets.code.first.file!;
  } on Object {
    return await _buildCrossTestArchive(
      tempUri,
      targetOS,
      architecture,
      allSources,
      androidTargetNdkApi: androidTargetNdkApi,
      macOSTargetVersion: macOSTargetVersion,
      iOSTargetVersion: iOSTargetVersion,
      iOSTargetSdk: iOSTargetSdk,
    );
  }
}
