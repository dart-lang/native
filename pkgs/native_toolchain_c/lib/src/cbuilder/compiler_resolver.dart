// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:native_assets_cli/native_assets_cli.dart';

import '../native_toolchain/android_ndk.dart';
import '../native_toolchain/apple_clang.dart';
import '../native_toolchain/clang.dart';
import '../native_toolchain/gcc.dart';
import '../native_toolchain/msvc.dart';
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
      CCompilerConfig.ccConfigKeyFull,
      (buildConfig) => buildConfig.cCompiler.cc,
    );

    // Then, try to detect on the host machine.
    final tool = _selectCompiler();
    if (tool != null) {
      result ??= await _tryLoadToolFromNativeToolchain(tool);
    }

    if (result != null) {
      return result;
    }

    final targetOs = buildConfig.targetOs;
    final targetArchitecture = buildConfig.targetArchitecture;
    final errorMessage = "No tools configured on host '$host' with target "
        "'${targetOs}_$targetArchitecture'.";
    logger?.severe(errorMessage);
    throw ToolError(errorMessage);
  }

  /// Select the right compiler for cross compiling to the specified target.
  Tool? _selectCompiler() {
    final targetOs = buildConfig.targetOs;
    final targetArch = buildConfig.targetArchitecture;

    // TODO(dacoharkes): Support falling back on other tools.
    if (targetArch == host.architecture &&
        targetOs == host.os &&
        host.os == OS.linux) return clang;
    if (targetOs == OS.macOS || targetOs == OS.iOS) return appleClang;
    if (targetOs == OS.android) return androidNdkClang;
    if (host.os == OS.linux) {
      switch (targetArch) {
        case Architecture.arm:
          return armLinuxGnueabihfGcc;
        case Architecture.arm64:
          return aarch64LinuxGnuGcc;
        case Architecture.ia32:
          return i686LinuxGnuGcc;
        case Architecture.x64:
          return x86_64LinuxGnuGcc;
        case Architecture.riscv64:
          return riscv64LinuxGnuGcc;
      }
    }

    if (host.os == OS.windows) {
      switch (targetArch) {
        case Architecture.ia32:
          return clIA32;
        case Architecture.arm64:
          return clArm64;
        case Architecture.x64:
          return cl;
      }
    }

    return null;
  }

  Future<ToolInstance?> _tryLoadCompilerFromConfig(
      String configKey, Uri? Function(BuildConfig) getter) async {
    final configCcUri = getter(buildConfig);
    if (configCcUri != null) {
      assert(await File.fromUri(configCcUri).exists());
      logger?.finer('Using compiler ${configCcUri.toFilePath()} '
          'from config[${CCompilerConfig.ccConfigKeyFull}].');
      return (await CompilerRecognizer(configCcUri).resolve(logger: logger))
          .first;
    }
    logger?.finer(
        'No compiler set in config[${CCompilerConfig.ccConfigKeyFull}].');
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
      CCompilerConfig.arConfigKeyFull,
      (buildConfig) => buildConfig.cCompiler.ar,
    );

    // Then, try to detect on the host machine.
    final tool = _selectArchiver();
    if (tool != null) {
      result ??= await _tryLoadToolFromNativeToolchain(tool);
    }

    if (result != null) {
      return result;
    }

    final targetOs = buildConfig.targetOs;
    final targetArchitecture = buildConfig.targetArchitecture;
    final errorMessage = "No tools configured on host '$host' with target "
        "'${targetOs}_$targetArchitecture'.";
    logger?.severe(errorMessage);
    throw ToolError(errorMessage);
  }

  /// Select the right archiver for cross compiling to the specified target.
  Tool? _selectArchiver() {
    final targetOs = buildConfig.targetOs;
    final targetArchitecture = buildConfig.targetArchitecture;

    // TODO(dacoharkes): Support falling back on other tools.
    if (targetArchitecture == host.architecture &&
        targetOs == host.os &&
        host.os == OS.linux) {
      return llvmAr;
    }
    if (targetOs == OS.macOS || targetOs == OS.iOS) return appleAr;
    if (targetOs == OS.android) return androidNdkLlvmAr;
    if (host.os == OS.linux) {
      switch (targetArchitecture) {
        case Architecture.arm:
          return armLinuxGnueabihfGccAr;
        case Architecture.arm64:
          return aarch64LinuxGnuGccAr;
        case Architecture.ia32:
          return i686LinuxGnuGccAr;
        case Architecture.x64:
          return x86_64LinuxGnuGccAr;
        case Architecture.riscv64:
          return riscv64LinuxGnuGccAr;
      }
    }
    if (host.os == OS.windows) {
      switch (targetArchitecture) {
        case Architecture.ia32:
          return libIA32;
        case Architecture.arm64:
          return libArm64;
        case Architecture.x64:
          return lib;
      }
    }

    return null;
  }

  Future<ToolInstance?> _tryLoadArchiverFromConfig(
      String configKey, Uri? Function(BuildConfig) getter) async {
    final configArUri = getter(buildConfig);
    if (configArUri != null) {
      assert(await File.fromUri(configArUri).exists());
      logger?.finer('Using archiver ${configArUri.toFilePath()} '
          'from config[${CCompilerConfig.arConfigKeyFull}].');
      return (await ArchiverRecognizer(configArUri).resolve(logger: logger))
          .first;
    }
    logger?.finer(
        'No archiver set in config[${CCompilerConfig.arConfigKeyFull}].');
    return null;
  }

  Future<Uri?> toolchainEnvironmentScript(ToolInstance compiler) async {
    final fromConfig = buildConfig.cCompiler.envScript;
    if (fromConfig != null) {
      logger?.fine('Using envScript from config: $fromConfig');
      return fromConfig;
    }

    final compilerTool = compiler.tool;
    assert(compilerTool == cl);
    final vcvarsScript =
        (await vcvars(compiler).defaultResolver!.resolve(logger: logger)).first;
    return vcvarsScript.uri;
  }

  List<String>? toolchainEnvironmentScriptArguments() {
    final fromConfig = buildConfig.cCompiler.envScriptArgs;
    if (fromConfig != null) {
      logger?.fine('Using envScriptArgs from config: $fromConfig');
      return fromConfig;
    }

    // vcvars above already has x64 or x86 in the script name.
    return null;
  }
}
