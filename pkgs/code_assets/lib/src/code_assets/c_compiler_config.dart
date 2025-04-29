// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:collection/collection.dart';

import 'config.dart';
import 'os.dart';
import 'syntax.g.dart';

/// The configuration for a C toolchain inside [CodeConfig.cCompiler].
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
    null =>
      throw StateError(
        'Cannot access windows if CodeConfig.targetOS is not Windows',
      ),
    final c => c,
  };

  /// Constructs a new [CCompilerConfig] based on the given toolchain tools.
  CCompilerConfig({
    required this.archiver,
    required this.compiler,
    required this.linker,
    WindowsCCompilerConfig? windows,
  }) : _windows = windows;

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
      _windows?.developerCommandPrompt?.arguments,
    )) {
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
    const ListEquality<String>().hash(
      _windows?.developerCommandPrompt?.arguments,
    ),
  );
}

/// The configuration provided in [CCompilerConfig.windows] when
/// [CodeConfig.targetOS] is [OS.windows].
final class WindowsCCompilerConfig {
  final DeveloperCommandPrompt? developerCommandPrompt;

  WindowsCCompilerConfig({this.developerCommandPrompt});
}

/// The configuration for the Windows Developer Command Prompt in
/// [WindowsCCompilerConfig.developerCommandPrompt].
///
/// Sets up the environment variables for [CCompilerConfig.compiler],
/// [CCompilerConfig.linker], and [CCompilerConfig.archiver] on Windows.
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

  DeveloperCommandPrompt({required this.script, required this.arguments});
}

extension CCompilerConfigSyntaxExtension on CCompilerConfig {
  CCompilerConfigSyntax toSyntax() => CCompilerConfigSyntax(
    ar: archiver,
    cc: compiler,
    ld: linker,
    windows: _windows?.toSyntax(),
  );

  static CCompilerConfig fromSyntax(CCompilerConfigSyntax cCompiler) =>
      CCompilerConfig(
        archiver: cCompiler.ar,
        compiler: cCompiler.cc,
        linker: cCompiler.ld,
        windows: switch (cCompiler.windows) {
          null => null,
          final windows => WindowsCCompilerConfigSyntaxExtension.fromSyntax(
            windows,
          ),
        },
      );
}

extension WindowsCCompilerConfigSyntaxExtension on WindowsCCompilerConfig {
  WindowsSyntax toSyntax() =>
      WindowsSyntax(developerCommandPrompt: developerCommandPrompt?.toSyntax());

  static WindowsCCompilerConfig fromSyntax(WindowsSyntax windows) =>
      WindowsCCompilerConfig(
        developerCommandPrompt: switch (windows.developerCommandPrompt) {
          null => null,
          final dcp => DeveloperCommandPromptSyntaxExtension.fromSyntax(dcp),
        },
      );
}

extension DeveloperCommandPromptSyntaxExtension on DeveloperCommandPrompt {
  DeveloperCommandPromptSyntax toSyntax() =>
      DeveloperCommandPromptSyntax(script: script, arguments: arguments);

  static DeveloperCommandPrompt fromSyntax(DeveloperCommandPromptSyntax dcp) =>
      DeveloperCommandPrompt(script: dcp.script, arguments: dcp.arguments);
}
