// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:native_assets_cli/native_assets_cli.dart';

import '../native_toolchain/android_ndk.dart';
import '../native_toolchain/clang.dart';
import '../native_toolchain/gcc.dart';
import '../native_toolchain/recognizer.dart';
import '../tool/tool.dart';
import '../tool/tool_error.dart';
import '../tool/tool_instance.dart';

class CompilerResolver {
  final BuildConfig buildConfig;
  final Logger? logger;

  CompilerResolver({
    required this.buildConfig,
    required this.logger,
  });

  Future<ToolInstance> resolveCompiler() async {
    final tool = _selectCompiler();

    // First, check if the launcher provided a direct path to the compiler.
    var result = await _tryLoadCompilerFromConfig(
      tool,
      BuildConfig.ccConfigKey,
      (buildConfig) => buildConfig.cc,
    );

    // Then, try to detect on the host machine.
    result ??= await _tryLoadToolFromNativeToolchain(tool);

    if (result != null) {
      return result;
    }

    const errorMessage = 'No C compiler found.';
    logger?.severe(errorMessage);
    throw ToolError(errorMessage);
  }

  /// Select the right compiler for cross compiling to the specified target.
  Tool _selectCompiler() {
    final host = Target.current;
    final target = buildConfig.target;

    if (target == host) return clang;
    if (target.os == OS.android) return androidNdkClang;
    if (host.os == OS.linux) {
      switch (target) {
        case Target.linuxArm:
          return armLinuxGnueabihfGcc;
        case Target.linuxArm64:
          return aarch64LinuxGnuGcc;
        case Target.linuxIA32:
          return i686LinuxGnuGcc;
      }
    }

    throw ToolError(
        "No tools configured on host '$host' with target '$target'.");
  }

  Future<ToolInstance?> _tryLoadCompilerFromConfig(
      Tool tool, String configKey, Uri? Function(BuildConfig) getter) async {
    final configCcUri = getter(buildConfig);
    if (configCcUri != null) {
      if (await File.fromUri(configCcUri).exists()) {
        logger?.finer('Using compiler ${configCcUri.path} '
            'from config[${BuildConfig.ccConfigKey}].');
        return (await CompilerRecognizer(configCcUri).resolve(logger: logger))
            .first;
      } else {
        logger?.warning('Compiler ${configCcUri.path} from '
            'config[${BuildConfig.ccConfigKey}] does not '
            'exist.');
      }
    }
    return null;
  }

  Future<ToolInstance?> _tryLoadToolFromNativeToolchain(Tool tool) async {
    final resolved = (await tool.defaultResolver!.resolve(logger: logger))
        .where((i) => i.tool == tool)
        .toList()
      ..sort();
    return resolved.isEmpty ? null : resolved.first;
  }

  Future<ToolInstance> resolveArchiver() async {
    final tool = _selectArchiver();

    // First, check if the launcher provided a direct path to the compiler.
    var result = await _tryLoadArchiverFromConfig(
      tool,
      BuildConfig.arConfigKey,
      (buildConfig) => buildConfig.ar,
    );

    // Then, try to detect on the host machine.
    result ??= await _tryLoadToolFromNativeToolchain(tool);

    if (result != null) {
      return result;
    }

    const errorMessage = 'No C archiver found.';
    logger?.severe(errorMessage);
    throw ToolError(errorMessage);
  }

  /// Select the right compiler for cross compiling to the specified target.
  Tool _selectArchiver() {
    final host = Target.current;
    final target = buildConfig.target;

    if (target == host) return llvmAr;
    if (target.os == OS.android) return androidNdkLlvmAr;
    if (host.os == OS.linux) {
      switch (target) {
        case Target.linuxArm:
          return armLinuxGnueabihfGccAr;
        case Target.linuxArm64:
          return aarch64LinuxGnuGccAr;
        case Target.linuxIA32:
          return i686LinuxGnuGccAr;
      }
    }

    throw ToolError(
        "No tools configured on host '$host' with target '$target'.");
  }

  Future<ToolInstance?> _tryLoadArchiverFromConfig(
      Tool tool, String configKey, Uri? Function(BuildConfig) getter) async {
    final configCcUri = getter(buildConfig);
    if (configCcUri != null) {
      if (await File.fromUri(configCcUri).exists()) {
        logger?.finer('Using archiver ${configCcUri.path} '
            'from config[${BuildConfig.ccConfigKey}].');
        return (await ArchiverRecognizer(configCcUri).resolve(logger: logger))
            .first;
      } else {
        logger?.warning('Archiver ${configCcUri.path} from '
            'config[${BuildConfig.ccConfigKey}] does not '
            'exist.');
      }
    }
    return null;
  }
}
