// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:native_assets_cli/code_assets.dart';

import '../../native_toolchain_c.dart';
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
  final CodeConfig codeConfig;
  final Logger? logger;
  final OS hostOS;
  final Architecture hostArchitecture;

  CompilerResolver({
    required this.codeConfig,
    required this.logger,
    OS? hostOS, // Only visible for testing.
    Architecture? hostArchitecture, // Only visible for testing.
  })  : hostOS = hostOS ?? OS.current,
        hostArchitecture = hostArchitecture ?? Architecture.current;

  Future<ToolInstance> resolveCompiler() async {
    // First, check if the launcher provided a direct path to the compiler.
    var result = await _tryLoadCompilerFromInput();

    // Then, try to detect on the host machine.
    final tool = _selectCompiler();
    if (tool != null) {
      result ??= await _tryLoadToolFromNativeToolchain(tool);
    }

    if (result != null) {
      return result;
    }

    final targetOS = codeConfig.targetOS;
    final targetArchitecture = codeConfig.targetArchitecture;
    final errorMessage =
        "No tools configured on host '${hostOS}_$hostArchitecture' with target "
        "'${targetOS}_$targetArchitecture'.";
    logger?.severe(errorMessage);
    throw ToolError(errorMessage);
  }

  /// Select the right compiler for cross compiling to the specified target.
  Tool? _selectCompiler() {
    final targetOS = codeConfig.targetOS;
    final targetArch = codeConfig.targetArchitecture;

    // TODO(dacoharkes): Support falling back on other tools.
    if (targetArch == hostArchitecture &&
        targetOS == hostOS &&
        hostOS == OS.linux) {
      return clang;
    }
    if (targetOS == OS.macOS || targetOS == OS.iOS) return appleClang;
    if (targetOS == OS.android) return androidNdkClang;
    if (hostOS == OS.linux) {
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

    if (hostOS == OS.windows) {
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

  Future<ToolInstance?> _tryLoadCompilerFromInput() async {
    final inputCcUri = codeConfig.cCompiler?.compiler;
    if (inputCcUri != null) {
      assert(await File.fromUri(inputCcUri).exists());
      logger?.finer('Using compiler ${inputCcUri.toFilePath()} '
          'from BuildInput.cCompiler.cc.');
      return (await CompilerRecognizer(inputCcUri).resolve(logger: logger))
          .first;
    }
    logger?.finer('No compiler set in BuildInput.cCompiler.cc.');
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
    var result = await _tryLoadArchiverFromInput();

    // Then, try to detect on the host machine.
    final tool = _selectArchiver();
    if (tool != null) {
      result ??= await _tryLoadToolFromNativeToolchain(tool);
    }

    if (result != null) {
      return result;
    }

    final targetOS = codeConfig.targetOS;
    final targetArchitecture = codeConfig.targetArchitecture;
    final errorMessage =
        "No tools configured on host '${hostOS}_$hostArchitecture' with target "
        "'${targetOS}_$targetArchitecture'.";
    logger?.severe(errorMessage);
    throw ToolError(errorMessage);
  }

  /// Select the right archiver for cross compiling to the specified target.
  Tool? _selectArchiver() {
    final targetOS = codeConfig.targetOS;
    final targetArchitecture = codeConfig.targetArchitecture;

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

  Future<ToolInstance?> _tryLoadArchiverFromInput() async {
    final inputArUri = codeConfig.cCompiler?.archiver;
    if (inputArUri != null) {
      assert(await File.fromUri(inputArUri).exists());
      logger?.finer('Using archiver ${inputArUri.toFilePath()} '
          'from BuildInput.cCompiler.ar.');
      return (await ArchiverRecognizer(inputArUri).resolve(logger: logger))
          .first;
    }
    logger?.finer('No archiver set in BuildInput.cCompiler.ar.');
    return null;
  }

  Future<Map<String, String>> resolveEnvironment(ToolInstance compiler) async {
    if (codeConfig.targetOS != OS.windows) {
      return {};
    }

    final cCompilerConfig = codeConfig.cCompiler;
    if (cCompilerConfig != null) {
      final envScriptFromConfig =
          cCompilerConfig.windows.developerCommandPrompt.script;
      final vcvarsArgs =
          cCompilerConfig.windows.developerCommandPrompt.arguments;
      logger?.fine('Using envScript from input: $envScriptFromConfig');
      if (vcvarsArgs.isNotEmpty) {
        logger?.fine('Using envScriptArgs from input: $vcvarsArgs');
      }
      return await environmentFromBatchFile(
        envScriptFromConfig,
        arguments: vcvarsArgs,
      );
    }

    final compilerTool = compiler.tool;
    if (compilerTool != cl) {
      // If Clang is used on Windows, and we could discover the MSVC
      // installation, then Clang should be able to discover it as well.
      return {};
    }
    final vcvarsScript =
        (await vcvars(compiler).defaultResolver!.resolve(logger: logger)).first;
    return await environmentFromBatchFile(
      vcvarsScript.uri,
      arguments: [
        /* vcvarsScript already has x64 or x86 in the script name. */
      ],
    );
  }

  Future<ToolInstance> resolveLinker() async {
    final targetOS = codeConfig.targetOS;
    final targetArchitecture = codeConfig.targetArchitecture;
    // First, check if the launcher provided a direct path to the compiler.
    var result = await _tryLoadLinkerFromInput();

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

  Future<ToolInstance?> _tryLoadLinkerFromInput() async {
    final inputLdUri = codeConfig.cCompiler?.linker;
    if (inputLdUri != null) {
      assert(await File.fromUri(inputLdUri).exists());
      logger?.finer('Using linker ${inputLdUri.toFilePath()} '
          'from cCompiler.ld.');
      final tools = await LinkerRecognizer(inputLdUri).resolve(logger: logger);
      return tools.first;
    }
    logger?.finer('No linker set in cCompiler.ld.');
    return null;
  }

  /// Select the right compiler for cross compiling to the specified target.
  Tool? _selectLinker() {
    final targetOS = codeConfig.targetOS;
    final targetArchitecture = codeConfig.targetArchitecture;

    if (targetOS == OS.macOS || targetOS == OS.iOS) return appleLd;
    if (targetOS == OS.android) return androidNdkLld;
    if (hostOS == OS.linux) {
      switch (targetArchitecture) {
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
      switch (targetArchitecture) {
        case Architecture.ia32:
          return linkIA32;
        case Architecture.arm64:
          return linkArm64;
        case Architecture.x64:
          return msvcLink;
      }
    }

    return null;
  }
}
