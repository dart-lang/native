// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:collection/collection.dart';

import '../../code_assets.dart';
import '../json_utils.dart';
import '../utils/map.dart';

/// The configuration for a C toolchain.
final class CCompilerConfig {
  /// Path to a C compiler.
  final Uri compiler;

  /// Path to a native linker.
  final Uri linker;

  /// Path to a native archiver.
  final Uri archiver;

  final WindowsCCompilerConfig? _windows;

  /// Configuration provided when [CodeConfig.targetOS] is [OS.windows].
  WindowsCCompilerConfig get windows => switch (_windows) {
        null => throw StateError(
            'Cannot access windows if CodeConfig.targetOS is not Windows'),
        final c => c,
      };

  /// Constructs a new [CCompilerConfig] based on the given toolchain tools.
  CCompilerConfig({
    required this.archiver,
    required this.compiler,
    required this.linker,
    WindowsCCompilerConfig? windows,
  }) : _windows = windows;

  /// Constructs a [CCompilerConfig] from the given [json].
  ///
  /// The json is expected to be valid encoding obtained via
  /// [CCompilerConfig.toJson].
  factory CCompilerConfig.fromJson(Map<String, Object?> json) {
    WindowsCCompilerConfig? winConfig;
    if (json[_windowsConfigKey] != null) {
      final dcpJson =
          json.map$(_windowsConfigKey).map$(_developerCommandPromptConfigKey);
      winConfig = WindowsCCompilerConfig(
        developerCommandPrompt: DeveloperCommandPrompt(
          script: dcpJson.path(_scriptConfigKey),
          arguments: dcpJson.stringList(_argumentsConfigKey),
        ),
      );
    } else if (json[_envScriptConfigKeyDeprecated] != null) {
      winConfig = WindowsCCompilerConfig(
        developerCommandPrompt: DeveloperCommandPrompt(
          script: json.path(_envScriptConfigKeyDeprecated),
          arguments: json.stringList(_envScriptArgsConfigKeyDeprecated),
        ),
      );
    }
    return CCompilerConfig(
      archiver: json.path(_arConfigKey),
      compiler: json.path(_ccConfigKey),
      linker: json.path(_ldConfigKey),
      windows: winConfig,
    );
  }

  /// The json representation of this [CCompilerConfig].
  ///
  /// The returned json can be used in [CCompilerConfig.fromJson] to
  /// obtain a [CCompilerConfig] again.
  Map<String, Object> toJson({bool deprecatedTopLevel = false}) => {
        _arConfigKey: archiver.toFilePath(),
        _ccConfigKey: compiler.toFilePath(),
        _ldConfigKey: linker.toFilePath(),
        if (_windows?.developerCommandPrompt?.script != null)
          _envScriptConfigKeyDeprecated:
              _windows!.developerCommandPrompt!.script.toFilePath(),
        if (_windows?.developerCommandPrompt?.arguments != null)
          _envScriptArgsConfigKeyDeprecated:
              _windows!.developerCommandPrompt!.arguments,
        if (_windows != null && !deprecatedTopLevel)
          _windowsConfigKey: {
            if (_windows.developerCommandPrompt != null)
              _developerCommandPromptConfigKey: {
                _argumentsConfigKey: _windows.developerCommandPrompt!.arguments,
                _scriptConfigKey:
                    _windows.developerCommandPrompt!.script.toFilePath(),
              }
          }
      }.sortOnKey();

  @override
  bool operator ==(Object other) {
    if (other is! CCompilerConfig) {
      return false;
    }
    if (other.archiver != archiver) return false;
    if (other.compiler != compiler) return false;
    if (other.linker != linker) return false;
    if (other._windows?.developerCommandPrompt?.script !=
        _windows?.developerCommandPrompt?.script) {
      return false;
    }
    if (!const ListEquality<String>().equals(
        other._windows?.developerCommandPrompt?.arguments,
        _windows?.developerCommandPrompt?.arguments)) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        archiver,
        compiler,
        linker,
        _windows?.developerCommandPrompt?.script,
        const ListEquality<String>()
            .hash(_windows?.developerCommandPrompt?.arguments),
      );
}

const _arConfigKey = 'ar';
const _ccConfigKey = 'cc';
const _ldConfigKey = 'ld';
const _envScriptConfigKeyDeprecated = 'env_script';
const _envScriptArgsConfigKeyDeprecated = 'env_script_arguments';
const _windowsConfigKey = 'windows';
const _developerCommandPromptConfigKey = 'developer_command_prompt';
const _scriptConfigKey = 'script';
const _argumentsConfigKey = 'arguments';

/// Configuration provided when [CodeConfig.targetOS] is [OS.windows].
final class WindowsCCompilerConfig {
  final DeveloperCommandPrompt? developerCommandPrompt;

  WindowsCCompilerConfig({
    required this.developerCommandPrompt,
  });
}

/// The Windows Developer Command Prompt.
///
/// Sets up the environment variables for [CCompilerConfig.compiler],
/// [CCompilerConfig.linker], and [CCompilerConfig.archiver].
///
/// Specific to [CodeConfig.targetArchitecture].
final class DeveloperCommandPrompt {
  /// The path to the batch script that sets up the environment variables.
  ///
  /// Must be invoked with [arguments].
  ///
  /// This path is typically something such as:
  /// - `C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\VsDevCmd.bat`
  /// - `C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\vsdevcmd\ext\vcvars.bat`
  /// - `C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat`
  /// - `C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsamd64_x86.bat`
  ///
  /// Typically run with `%comspec% /k` on Windows to have a terminal with the
  /// right environment variables for subsequent commands.
  final Uri script;

  /// Arguments to invoke [script] with.
  ///
  /// This is empty if [script] already contains [CodeConfig.targetArchitecture]
  /// in its name, and contains the [CodeConfig.targetArchitecture] if the
  /// script name does not.
  final List<String> arguments;

  DeveloperCommandPrompt({
    required this.script,
    required this.arguments,
  });
}
