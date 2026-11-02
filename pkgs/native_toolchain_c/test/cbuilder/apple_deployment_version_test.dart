// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:code_assets/code_assets.dart';
import 'package:file/memory.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/src/cbuilder/optimization_level.dart';
import 'package:native_toolchain_c/src/cbuilder/run_cbuilder.dart';
import 'package:native_toolchain_c/src/native_toolchain/apple_clang.dart';
import 'package:native_toolchain_c/src/tool/tool_instance.dart';
import 'package:native_toolchain_c/src/tool/tool_resolver.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import '../utils/fake_process_manager.dart';

void main() {
  for (final (version, expected) in [
    (AppleVersion(17), '17'),
    (AppleVersion(17, minor: 2), '17.2'),
    (AppleVersion(17, minor: 2, patch: 1), '17.2.1'),
    (AppleVersion(17, patch: 1), '17.0.1'),
  ]) {
    for (final (os, sdk) in [
      (OS.macOS, null),
      (OS.iOS, IOSSdk.iPhoneOS),
      (OS.iOS, IOSSdk.iPhoneSimulator),
    ]) {
      test('clang formats $os $sdk deployment version $version', () async {
        final directory = await tempDirForTest();
        final input =
            (BuildInputBuilder()
                  ..setupShared(
                    packageName: 'test',
                    packageRoot: directory,
                    outputFile: directory.resolve('output.json'),
                    outputDirectoryShared: directory,
                  )
                  ..config.setupBuild(linkingEnabled: false)
                  ..addExtension(
                    CodeAssetExtension(
                      targetOS: os,
                      targetArchitecture: Architecture.arm64,
                      linkModePreference: LinkModePreference.dynamic,
                      macOS: os == OS.macOS
                          ? MacOSCodeConfig(deploymentVersion: version)
                          : null,
                      iOS: sdk != null
                          ? IOSCodeConfig(
                              targetSdk: sdk,
                              deploymentVersion: version,
                            )
                          : null,
                    ),
                  ))
                .build();
        final processes = FakeProcessManager([const FakeCommand()]);
        final runner = _RunCBuilder(
          input: input,
          codeConfig: input.config.code,
          processManager: processes,
          fileSystem: MemoryFileSystem(),
          dynamicLibrary: directory.resolve('test.dylib'),
        );
        await runner.runClangLike(
          tool: ToolInstance(tool: appleClang, uri: directory.resolve('clang')),
        );
        expect(processes.allCommandsConsumed, isTrue);
        final flag = os == OS.macOS
            ? '-mmacos-version-min='
            : '-mios-version-min=';
        expect(
          processes.invocations.single.command,
          contains('$flag$expected'),
        );
      });
    }
  }
}

// Keep the production argument path while avoiding SDK discovery and compilers.
class _RunCBuilder extends RunCBuilder {
  _RunCBuilder({
    required super.input,
    required super.codeConfig,
    required super.processManager,
    required super.fileSystem,
    required super.dynamicLibrary,
  }) : super(
         frameworks: const [],
         optimizationLevel: OptimizationLevel.unspecified,
       );

  @override
  Future<Uri> iosSdk(IOSSdk iosSdk, ToolResolvingContext context) async =>
      input.packageRoot;

  @override
  Future<Uri> macosSdk(ToolResolvingContext context) async => input.packageRoot;
}
