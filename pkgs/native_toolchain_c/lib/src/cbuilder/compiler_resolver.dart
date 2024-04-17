// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:native_assets_cli/native_assets_cli.dart'
    show Architecture, CCompilerConfig, OS;

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
  final CCompilerConfig cCompiler;
  final OS targetOS;
  final Architecture? targetArchitecture;
  final Logger? logger;
  final OS hostOS;
  final Architecture hostArchitecture;

  CompilerResolver({
    required this.targetOS,
    required this.targetArchitecture,
    required this.cCompiler,
    required this.logger,
    OS? hostOS, // Only visible for testing.
    Architecture? hostArchitecture, // Only visible for testing.
  })  : hostOS = hostOS ?? OS.current,
        hostArchitecture = hostArchitecture ?? Architecture.current;

  Future<ToolInstance> resolveCompiler() async {
    // First, check if the launcher provided a direct path to the compiler.
    var result = await _tryLoadCompilerFromConfig();

    // Then, try to detect on the host machine.
    final tool = _selectCompiler();
    if (tool != null) {
      result ??= await _tryLoadToolFromNativeToolchain(tool);
    }

    if (result != null) {
      return result;
    }

    final errorMessage =
        "No tools configured on host '${hostOS}_$hostArchitecture' with target "
        "'${targetOS}_$targetArchitecture'.";
    logger?.severe(errorMessage);
    throw ToolError(errorMessage);
  }

  /// Select the right compiler for cross compiling to the specified target.
  Tool? _selectCompiler() {
    // TODO(dacoharkes): Support falling back on other tools.
    if (targetArchitecture == hostArchitecture &&
        targetOS == hostOS &&
        hostOS == OS.linux) return clang;
    if (targetOS == OS.macOS || targetOS == OS.iOS) return appleClang;
    if (targetOS == OS.android) return androidNdkClang;
    if (hostOS == OS.linux) {
      switch (targetArchitecture) {
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

    if (hostOS == OS.windows) {
      switch (targetArchitecture) {
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

  Future<ToolInstance?> _tryLoadCompilerFromConfig() async {
    final configCcUri = cCompiler.compiler;
    if (configCcUri != null) {
      assert(await File.fromUri(configCcUri).exists());
      logger?.finer('Using compiler ${configCcUri.toFilePath()} '
          'from cCompiler.cc.');
      return (await CompilerRecognizer(configCcUri).resolve(logger: logger))
          .first;
    }
    logger?.finer('No compiler set in cCompiler.cc.');
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
    var result = await _tryLoadArchiverFromConfig();

    // Then, try to detect on the host machine.
    final tool = _selectArchiver();
    if (tool != null) {
      result ??= await _tryLoadToolFromNativeToolchain(tool);
    }

    if (result != null) {
      return result;
    }

    final errorMessage =
        "No tools configured on host '${hostOS}_$hostArchitecture' with target "
        "'${targetOS}_$targetArchitecture'.";
    logger?.severe(errorMessage);
    throw ToolError(errorMessage);
  }

  /// Select the right archiver for cross compiling to the specified target.
  Tool? _selectArchiver() {
    // TODO(dacoharkes): Support falling back on other tools.
    if (targetArchitecture == hostArchitecture &&
        targetOS == hostOS &&
        hostOS == OS.linux) {
      return llvmAr;
    }
    if (targetOS == OS.macOS || targetOS == OS.iOS) return appleAr;
    if (targetOS == OS.android) return androidNdkLlvmAr;
    if (hostOS == OS.linux) {
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
    if (hostOS == OS.windows) {
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

  Future<ToolInstance?> _tryLoadArchiverFromConfig() async {
    final configArUri = cCompiler.archiver;
    if (configArUri != null) {
      assert(await File.fromUri(configArUri).exists());
      logger?.finer('Using archiver ${configArUri.toFilePath()} '
          'from cCompiler.ar.');
      return (await ArchiverRecognizer(configArUri).resolve(logger: logger))
          .first;
    }
    logger?.finer('No compiler set in cCompiler.ar.');
    return null;
  }

  Future<ToolInstance> resolveLinker() async {
    // First, check if the launcher provided a direct path to the compiler.
    var result = await _tryLoadLinkerFromConfig();

    // Then, try to detect on the host machine.
    final tool = _selectLinker();
    if (tool != null) {
      result ??= await _tryLoadToolFromNativeToolchain(tool);
    }

    if (result != null) {
      return result;
    }

    final errorMessage =
        "No tools configured on host '${hostOS}_$hostArchitecture' with target "
        "'${targetOS}_$targetArchitecture'.";
    logger?.severe(errorMessage);
    throw ToolError(errorMessage);
  }

  Future<ToolInstance?> _tryLoadLinkerFromConfig() async {
    final configLdUri = cCompiler.linker;
    if (configLdUri != null) {
      assert(await File.fromUri(configLdUri).exists());
      logger?.finer('Using linker ${configLdUri.toFilePath()} '
          'from cCompiler.ld.');
      return (await LinkerRecognizer(configLdUri, hostOS)
              .resolve(logger: logger))
          .first;
    }
    logger?.finer('No linker set in cCompiler.ld.');
    return null;
  }

  /// Select the right compiler for cross compiling to the specified target.
  Tool? _selectLinker() {
    final targetOs = targetOS;
    final targetArch = targetArchitecture;

    // TODO(dacoharkes): Support falling back on other tools.
    if (targetArch == hostArchitecture &&
        targetOs == hostOS &&
        hostOS == OS.linux) return clang;
    if (targetOs == OS.macOS || targetOs == OS.iOS) return appleClang;
    if (targetOs == OS.android) return androidNdkClang;
    if (hostOS == OS.linux) {
      switch (targetArch) {
        case Architecture.arm:
          return armLinuxGnueabihfLd;
        case Architecture.arm64:
          return aarch64LinuxGnuLd;
        case Architecture.ia32:
          return i686LinuxGnuLd;
        case Architecture.x64:
          return x86_64LinuxGnuLd;
        case Architecture.riscv64:
          return riscv64LinuxGnuLd;
      }
    }

    if (hostOS == OS.windows) {
      switch (targetArch) {
        case Architecture.ia32:
          return linkIA32;
        case Architecture.arm64:
          return linkArm64;
        case Architecture.x64:
          return link;
      }
    }

    return null;
  }

  Future<Uri?> toolchainEnvironmentScript(ToolInstance compiler) async {
    final fromConfig = cCompiler.envScript;
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
    final fromConfig = cCompiler.envScriptArgs;
    if (fromConfig != null) {
      logger?.fine('Using envScriptArgs from config: $fromConfig');
      return fromConfig;
    }

    // vcvars above already has x64 or x86 in the script name.
    return null;
  }
}
