// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:code_assets/code_assets.dart';
import 'package:file/file.dart' show FileSystem;
import 'package:file/local.dart';
import 'package:logging/logging.dart';
import 'package:process/process.dart';

import '../native_toolchain/android_ndk.dart';
import '../native_toolchain/apple_clang.dart';
import '../native_toolchain/clang.dart';
import '../native_toolchain/dart_sdk.dart';
import '../native_toolchain/gcc.dart';
import '../native_toolchain/msvc.dart';
import '../native_toolchain/recognizer.dart';
import '../tool/tool.dart';
import '../tool/tool_error.dart';
import '../tool/tool_instance.dart';
import '../tool/tool_resolver.dart';
import '../utils/env_from_bat.dart';

// TODO(dacoharkes): This should support alternatives.
// For example use Clang or MSVC on Windows.
class CompilerResolver {
  final CodeConfig codeConfig;
  final Logger? logger;
  final ProcessManager processManager;
  final FileSystem fileSystem;
  final OS hostOS;
  final Architecture hostArchitecture;
  final ToolResolvingContext context;

  CompilerResolver({
    required this.codeConfig,
    required this.logger,
    ProcessManager? processManager,
    FileSystem? fileSystem,
    OS? hostOS, // Only visible for testing.
    Architecture? hostArchitecture, // Only visible for testing.
  }) : processManager = processManager ?? const LocalProcessManager(),
       fileSystem = fileSystem ?? const LocalFileSystem(),
       hostOS = hostOS ?? .current,
       hostArchitecture = hostArchitecture ?? .current,
       context = ToolResolvingContext(
         logger: logger,
         processManager: processManager,
         fileSystem: fileSystem,
       );

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

  /// Resolves a linker for [codeConfig].
  ///
  /// Prioritizes [CCompilerConfig.linker] when configured, then the Dart SDK's
  /// bundled `lld`, then host `lld` and platform-specific linkers.
  Future<ToolInstance> resolveLinker() async {
    var result = await _tryLoadLinkerFromInput();

    for (final possibleTool in _selectPossibleLinkers()) {
      result ??= await _tryLoadToolFromNativeToolchain(possibleTool);
    }

    if (result != null) {
      return result;
    }

    final targetOS = codeConfig.targetOS;
    final targetArchitecture = codeConfig.targetArchitecture;
    final errorMessage =
        "No linker configured on host '${hostOS}_$hostArchitecture' with "
        "target '${targetOS}_$targetArchitecture'.";
    logger?.severe(errorMessage);
    throw ToolError(errorMessage);
  }

  Iterable<Tool> _selectPossibleLinkers() sync* {
    if (hostOS != .linux && hostOS != .macOS && hostOS != .windows) {
      return;
    }
    yield sdkLld;
    yield lld;
    final targetOS = codeConfig.targetOS;
    final targetArch = codeConfig.targetArchitecture;
    switch ((hostOS, targetOS, targetArch)) {
      case (_, .android, _):
        yield androidNdkLld;
      case (.macOS, .macOS || .iOS, _):
        yield appleLd;
      case (.linux, .linux, .arm):
        yield armLinuxGnueabihfLd;
      case (.linux, .linux, .arm64):
        yield aarch64LinuxGnuLd;
      case (.linux, .linux, .ia32):
        yield i686LinuxGnuLd;
      case (.linux, .linux, .x64):
        yield x86_64LinuxGnuLd;
      case (.linux, .linux, .riscv64):
        yield riscv64LinuxGnuLd;
      case (.windows, .windows, .ia32):
        yield linkIA32;
      case (.windows, .windows, .arm64):
        yield linkArm64;
      case (.windows, .windows, .x64):
        yield msvcLink;
    }
  }

  Future<ToolInstance?> _tryLoadLinkerFromInput() async {
    final inputLdUri = codeConfig.cCompiler?.linker;
    if (inputLdUri != null) {
      assert(await fileSystem.file(inputLdUri).exists());
      logger?.finer(
        'Using linker ${inputLdUri.toFilePath()} '
        'from BuildInput.cCompiler.ld.',
      );
      final recognized = await LinkerRecognizer(inputLdUri).resolve(context);
      if (recognized.isNotEmpty) {
        final instance = recognized.first;
        final targetOS = codeConfig.targetOS;
        // A non-LLD host linker (e.g. GNU ld, Apple ld, or MSVC link.exe) only
        // supports its native binary format. If cross-linking to another OS
        // format, allow fallback to LLD when the configured linker cannot
        // target targetOS.
        final compatibleWithTarget = switch (instance.tool) {
          final t when t == lld => true,
          final t when t == gnuLinker =>
            targetOS == .linux || targetOS == .android,
          final t when t == appleLd => targetOS == .macOS || targetOS == .iOS,
          final t when t == msvcLink || t == linkIA32 || t == linkArm64 =>
            targetOS == .windows,
          _ => true,
        };
        if (compatibleWithTarget) {
          return instance;
        }
      }
    }
    logger?.finer('No linker set in BuildInput.cCompiler.ld.');
    return null;
  }

  /// Select possible compilers for cross compiling to the specified target.
  Iterable<Tool> _selectPossibleCompilers() sync* {
    final targetOS = codeConfig.targetOS;
    final targetArch = codeConfig.targetArchitecture;

    switch ((hostOS, targetOS, targetArch)) {
      case (_, .android, _):
        yield androidNdkClang;
      case (.macOS, .macOS || .iOS, _):
        yield appleClang;
        yield clang;
      case (.linux, .linux, _) when hostArchitecture == targetArch:
        yield clang;
      case (.linux, _, .arm):
        yield armLinuxGnueabihfGcc;
      case (.linux, _, .arm64):
        yield aarch64LinuxGnuGcc;
      case (.linux, _, .ia32):
        yield i686LinuxGnuGcc;
      case (.linux, _, .x64):
        yield x86_64LinuxGnuGcc;
      case (.linux, _, .riscv64):
        yield riscv64LinuxGnuGcc;
      case (.macOS, .linux, .arm):
        yield armLinuxGnueabihfGcc;
      case (.macOS, .linux, .arm64):
        yield aarch64LinuxGnuGcc;
      case (.macOS, .linux, .ia32):
        yield i686LinuxGnuGcc;
      case (.macOS, .linux, .x64):
        yield x86_64LinuxGnuGcc;
      case (.macOS, .linux, .riscv64):
        yield riscv64LinuxGnuGcc;
      case (.windows, .linux, .arm):
        yield armLinuxGnueabihfGccWsl;
        yield armLinuxGnueabihfGcc;
      case (.windows, .linux, .arm64):
        yield aarch64LinuxGnuGccWsl;
        yield aarch64LinuxGnuGcc;
      case (.windows, .linux, .ia32):
        yield i686LinuxGnuGccWsl;
        yield i686LinuxGnuGcc;
      case (.windows, .linux, .x64):
        yield x86_64LinuxGnuGccWsl;
        yield x86_64LinuxGnuGcc;
      case (.windows, .linux, .riscv64):
        yield riscv64LinuxGnuGccWsl;
        yield riscv64LinuxGnuGcc;
      case (.windows, _, .ia32):
        yield clIA32;
      case (.windows, _, .arm64):
        yield clArm64;
      case (.windows, _, .x64):
        yield cl;
    }
  }

  Future<ToolInstance?> _tryLoadCompilerFromInput() async {
    final inputCcUri = codeConfig.cCompiler?.compiler;
    if (inputCcUri != null) {
      assert(await fileSystem.file(inputCcUri).exists());
      logger?.finer(
        'Using compiler ${inputCcUri.toFilePath()} '
        'from BuildInput.cCompiler.cc.',
      );
      return (await CompilerRecognizer(inputCcUri).resolve(context)).first;
    }
    logger?.finer('No compiler set in BuildInput.cCompiler.cc.');
    return null;
  }

  Future<ToolInstance?> _tryLoadToolFromNativeToolchain(Tool tool) async {
    final resolved = (await tool.defaultResolver!.resolve(
      context,
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
        hostOS == .linux) {
      return llvmAr;
    }
    if (targetOS == .macOS || targetOS == .iOS) return appleAr;
    if (targetOS == .android) return androidNdkLlvmAr;
    if (hostOS == .linux) {
      switch (targetArchitecture) {
        case .arm:
          return armLinuxGnueabihfGccAr;
        case .arm64:
          return aarch64LinuxGnuGccAr;
        case .ia32:
          return i686LinuxGnuGccAr;
        case .x64:
          return x86_64LinuxGnuGccAr;
        case .riscv64:
          return riscv64LinuxGnuGccAr;
      }
    }
    if (targetOS == .linux && hostOS == .windows) {
      switch (targetArchitecture) {
        case .arm:
          return armLinuxGnueabihfGccArWsl;
        case .arm64:
          return aarch64LinuxGnuGccArWsl;
        case .ia32:
          return i686LinuxGnuGccArWsl;
        case .x64:
          return x86_64LinuxGnuGccArWsl;
        case .riscv64:
          return riscv64LinuxGnuGccArWsl;
      }
    }
    if (targetOS == .linux && hostOS != .linux) {
      switch (targetArchitecture) {
        case .arm:
          return armLinuxGnueabihfGccAr;
        case .arm64:
          return aarch64LinuxGnuGccAr;
        case .ia32:
          return i686LinuxGnuGccAr;
        case .x64:
          return x86_64LinuxGnuGccAr;
        case .riscv64:
          return riscv64LinuxGnuGccAr;
      }
    }
    if (hostOS == .windows) {
      switch (targetArchitecture) {
        case .ia32:
          return libIA32;
        case .arm64:
          return libArm64;
        case .x64:
          return lib;
      }
    }

    return null;
  }

  Future<ToolInstance?> _tryLoadArchiverFromInput() async {
    final inputArUri = codeConfig.cCompiler?.archiver;
    if (inputArUri != null) {
      assert(await fileSystem.file(inputArUri).exists());
      logger?.finer(
        'Using archiver ${inputArUri.toFilePath()} '
        'from BuildInput.cCompiler.ar.',
      );
      return (await ArchiverRecognizer(inputArUri).resolve(context)).first;
    }
    logger?.finer('No archiver set in BuildInput.cCompiler.ar.');
    return null;
  }

  Future<Map<String, String>> resolveEnvironment(ToolInstance compiler) async {
    if (codeConfig.targetOS != .windows) {
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
        processManager: processManager,
      );
    }

    final compilerTool = compiler.tool;
    if (compilerTool != cl && compilerTool != msvcLink) {
      // If Clang or LLD is used on Windows, no vcvars batch script is needed
      // unless explicitly configured.
      return {};
    }
    final vcvarsScript = (await vcvars(
      compiler,
    ).defaultResolver!.resolve(context)).first;
    return await environmentFromBatchFile(
      vcvarsScript.uri,
      arguments: [
        /* vcvarsScript already has x64 or x86 in the script name. */
      ],
      processManager: processManager,
    );
  }
}
