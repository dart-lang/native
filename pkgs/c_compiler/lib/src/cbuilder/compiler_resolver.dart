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

// TODO(dacoharkes): This should support alternatives.
// For example use Clang or MSVC on Windows.
class CompilerResolver {
  final BuildConfig buildConfig;
  final Logger? logger;
  final Target host;

  CompilerResolver({
    required this.buildConfig,
    required this.logger,
    Target? host, // Only visible for testing.
  }) : host = host ?? Target.current;

  Future<ToolInstance> resolveCompiler() async {
    // First, check if the launcher provided a direct path to the compiler.
    var result = await _tryLoadCompilerFromConfig(
      BuildConfig.ccConfigKey,
      (buildConfig) => buildConfig.cc,
    );

    // Then, try to detect on the host machine.
    final tool = _selectCompiler();
    if (tool != null) {
      result ??= await _tryLoadToolFromNativeToolchain(tool);
    }

    if (result != null) {
      return result;
    }

    final target = buildConfig.target;
    final errorMessage =
        "No tools configured on host '$host' with target '$target'.";
    logger?.severe(errorMessage);
    throw ToolError(errorMessage);
  }

  /// Select the right compiler for cross compiling to the specified target.
  Tool? _selectCompiler() {
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

    return null;
  }

  Future<ToolInstance?> _tryLoadCompilerFromConfig(
      String configKey, Uri? Function(BuildConfig) getter) async {
    final configCcUri = getter(buildConfig);
    if (configCcUri != null) {
      assert(await File.fromUri(configCcUri).exists());
      logger?.finer('Using compiler ${configCcUri.path} '
          'from config[${BuildConfig.ccConfigKey}].');
      return (await CompilerRecognizer(configCcUri).resolve(logger: logger))
          .first;
    }
    logger?.finer('No compiler set in config[${BuildConfig.ccConfigKey}].');
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
    // First, check if the launcher provided a direct path to the compiler.
    var result = await _tryLoadArchiverFromConfig(
      BuildConfig.arConfigKey,
      (buildConfig) => buildConfig.ar,
    );

    // Then, try to detect on the host machine.
    final tool = _selectArchiver();
    if (tool != null) {
      result ??= await _tryLoadToolFromNativeToolchain(tool);
    }

    if (result != null) {
      return result;
    }

    final target = buildConfig.target;
    final errorMessage =
        "No tools configured on host '$host' with target '$target'.";
    logger?.severe(errorMessage);
    throw ToolError(errorMessage);
  }

  /// Select the right archiver for cross compiling to the specified target.
  Tool? _selectArchiver() {
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

    return null;
  }

  Future<ToolInstance?> _tryLoadArchiverFromConfig(
      String configKey, Uri? Function(BuildConfig) getter) async {
    final configArUri = getter(buildConfig);
    if (configArUri != null) {
      assert(await File.fromUri(configArUri).exists());
      logger?.finer('Using archiver ${configArUri.path} '
          'from config[${BuildConfig.arConfigKey}].');
      return (await ArchiverRecognizer(configArUri).resolve(logger: logger))
          .first;
    }
    logger?.finer('No archiver set in config[${BuildConfig.arConfigKey}].');
    return null;
  }
}
