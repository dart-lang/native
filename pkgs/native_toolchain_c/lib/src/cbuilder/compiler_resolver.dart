// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:logging/logging.dart';

import '../native_toolchain/android_ndk.dart';
import '../native_toolchain/apple_clang.dart';
import '../native_toolchain/clang.dart';
import '../native_toolchain/gcc.dart';
import '../native_toolchain/msvc.dart';
import '../native_toolchain/recognizer.dart';
import '../tool/tool.dart';
import '../tool/tool_error.dart';
import '../tool/tool_instance.dart';
import '../utils/env_from_bat.dart';

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
  }) : hostOS = hostOS ?? OS.current,
       hostArchitecture = hostArchitecture ?? Architecture.current;

  Future<ToolInstance> resolveCompiler() async {
    // First, check if the launcher provided a direct path to the compiler.
    var result = await _tryLoadCompilerFromInput();

    // Then, try to detect on the host machine.
    for (final possibleTool in _selectPossibleCompilers()) {
      result ??= await _tryLoadToolFromNativeToolchain(possibleTool);
    }

    if (result != null) {
      return result;
    }

    final targetOS = codeConfig.targetOS;
    final targetArchitecture = codeConfig.targetArchitecture;
    final errorMessage =
        "No compiler configured on host '${hostOS}_$hostArchitecture' with "
        "target '${targetOS}_$targetArchitecture'.";
    logger?.severe(errorMessage);
    throw ToolError(errorMessage);
  }

  /// Select possible compilers for cross compiling to the specified target.
  Iterable<Tool> _selectPossibleCompilers() sync* {
    final targetOS = codeConfig.targetOS;
    final targetArch = codeConfig.targetArchitecture;

    switch ((hostOS, targetOS, targetArch)) {
      case (_, OS.android, _):
        yield androidNdkClang;
      case (OS.macOS, OS.macOS || OS.iOS, _):
        yield appleClang;
        yield clang;
      case (OS.linux, OS.linux, _) when hostArchitecture == targetArch:
        yield clang;
      case (OS.linux, _, Architecture.arm):
        yield armLinuxGnueabihfGcc;
      case (OS.linux, _, Architecture.arm64):
        yield aarch64LinuxGnuGcc;
      case (OS.linux, _, Architecture.ia32):
        yield i686LinuxGnuGcc;
      case (OS.linux, _, Architecture.x64):
        yield x86_64LinuxGnuGcc;
      case (OS.linux, _, Architecture.riscv64):
        yield riscv64LinuxGnuGcc;
      case (OS.windows, _, Architecture.ia32):
        yield clIA32;
      case (OS.windows, _, Architecture.arm64):
        yield clArm64;
      case (OS.windows, _, Architecture.x64):
        yield cl;
    }
  }

  Future<ToolInstance?> _tryLoadCompilerFromInput() async {
    final inputCcUri = codeConfig.cCompiler?.compiler;
    if (inputCcUri != null) {
      assert(await File.fromUri(inputCcUri).exists());
      logger?.finer(
        'Using compiler ${inputCcUri.toFilePath()} '
        'from BuildInput.cCompiler.cc.',
      );
      return (await CompilerRecognizer(
        inputCcUri,
      ).resolve(logger: logger)).first;
    }
    logger?.finer('No compiler set in BuildInput.cCompiler.cc.');
    return null;
  }

  Future<ToolInstance?> _tryLoadToolFromNativeToolchain(Tool tool) async {
    final resolved = (await tool.defaultResolver!.resolve(
      logger: logger,
    )).where((i) => i.tool == tool).toList()..sort();
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
        "No archiver configured on host '${hostOS}_$hostArchitecture' with "
        "target '${targetOS}_$targetArchitecture'.";
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
      logger?.finer(
        'Using archiver ${inputArUri.toFilePath()} '
        'from BuildInput.cCompiler.ar.',
      );
      return (await ArchiverRecognizer(
        inputArUri,
      ).resolve(logger: logger)).first;
    }
    logger?.finer('No archiver set in BuildInput.cCompiler.ar.');
    return null;
  }

  Future<Map<String, String>> resolveEnvironment(ToolInstance compiler) async {
    if (codeConfig.targetOS != OS.windows) {
      return {};
    }

    final cCompilerConfig = codeConfig.cCompiler;
    if (cCompilerConfig != null &&
        cCompilerConfig.windows.developerCommandPrompt != null) {
      final envScriptFromConfig =
          cCompilerConfig.windows.developerCommandPrompt!.script;
      final vcvarsArgs =
          cCompilerConfig.windows.developerCommandPrompt!.arguments;
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
    final vcvarsScript = (await vcvars(
      compiler,
    ).defaultResolver!.resolve(logger: logger)).first;
    return await environmentFromBatchFile(
      vcvarsScript.uri,
      arguments: [
        /* vcvarsScript already has x64 or x86 in the script name. */
      ],
    );
  }
}
