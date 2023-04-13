// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:native_assets_cli/native_assets_cli.dart';

import '../native_toolchain/android_ndk.dart';
import '../native_toolchain/clang.dart';
import '../native_toolchain/gcc.dart';
import '../tool/tool.dart';
import '../tool/tool_error.dart';
import '../tool/tool_instance.dart';
import '../tool/tool_resolver.dart';

class CompilerResolver implements ToolResolver {
  final BuildConfig buildConfig;
  final Logger? logger;

  CompilerResolver({
    required this.buildConfig,
    required this.logger,
  });

  @override
  Future<List<ToolInstance>> resolve({Logger? logger}) async {
    final tool = selectCompiler();

    // First, check if the launcher provided a direct path to the compiler.
    var result = await _tryLoadCompilerFromConfig(
        tool, BuildConfig.ccConfigKey, (buildConfig) => buildConfig.cc);

    // Then, check if this package itself provided metadata.
    final depsToolKey = [
      BuildConfig.dependencyMetadataConfigKey,
      ' c_compiler',
      tool.name
    ].join('.');
    result ??= await _tryLoadCompilerFromConfig(
      tool,
      depsToolKey,
      (buildConfig) =>
          buildConfig.config.optionalPath(depsToolKey, mustExist: true),
    );

    // Lastly, try to detect on the host machine.
    result ??= await _tryLoadCompilerFromNativeToolchain(
      tool,
    );

    if (result != null) {
      return [result];
    }

    const errorMessage = 'No C compiler found.';
    logger?.severe(errorMessage);
    throw Exception(errorMessage);
  }

  /// Select the right compiler for cross compiling to the specified target.
  Tool selectCompiler() {
    final host = Target.current;
    final target = buildConfig.target;
    switch (target) {
      case Target.linuxArm:
        return armLinuxGnueabihfGcc;
      case Target.linuxArm64:
        return aarch64LinuxGnuGcc;
      case Target.linuxIA32:
        return i686LinuxGnuGcc;
      case Target.linuxX64:
        return clang;
      case Target.androidArm:
      case Target.androidArm64:
      case Target.androidIA32:
      case Target.androidX64:
        return androidNdkClang;
    }
    throw ToolError(
        "No tool configured on host '$host' for target: '$target'.");
  }

  Future<ToolInstance?> _tryLoadCompilerFromConfig(
      Tool tool, String configKey, Uri? Function(BuildConfig) getter) async {
    final configCcUri = getter(buildConfig);
    if (configCcUri != null) {
      if (await File.fromUri(configCcUri).exists()) {
        logger?.finer('Using compiler ${configCcUri.path} '
            'from config[${BuildConfig.ccConfigKey}].');
        return ToolInstance(tool: tool, uri: configCcUri);
      } else {
        logger?.warning('Compiler ${configCcUri.path} from '
            'config[${BuildConfig.ccConfigKey}] does not '
            'exist.');
      }
    }
    return null;
  }

  /// If a build is invoked
  Future<ToolInstance?> _tryLoadCompilerFromNativeToolchain(Tool tool) async {
    final resolved = (await tool.defaultResolver!.resolve(logger: logger))
        .where((i) => i.tool == tool)
        .toList()
      ..sort();
    return resolved.isEmpty ? null : resolved.first;
  }

  Future<Uri> resolveLinker(
    Uri compiler,
  ) async {
    if (compiler.pathSegments.last == 'clang') {
      final lld = compiler.resolve('lld');
      if (await File.fromUri(lld).exists()) {
        return lld;
      }
    }
    const errorMessage = 'No native linker found.';
    logger?.severe(errorMessage);
    throw Exception(errorMessage);
  }

  Future<Uri> resolveArchiver(
    Uri compiler,
  ) async {
    final compilerExecutable = compiler.pathSegments.last;
    if (compilerExecutable == 'clang') {
      final ar = compiler.resolve('llvm-ar');
      if (await File.fromUri(ar).exists()) {
        return ar;
      }
    } else if (compilerExecutable.contains('-gcc')) {
      final ar =
          compiler.resolve(compilerExecutable.replaceAll('-gcc', '-gcc-ar'));
      if (await File.fromUri(ar).exists()) {
        return ar;
      } else {
        print(ar);
      }
    }
    final errorMessage =
        'No native linker found for compiler: $compilerExecutable $compiler.';
    logger?.severe(errorMessage);
    throw Exception(errorMessage);
  }
}
