// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:collection/collection.dart';

import 'json_utils.dart';
import 'utils/map.dart';

/// The configuration for a C toolchain.
final class CCompilerConfig {
  /// Path to a C compiler.
  late final Uri? compiler;

  /// Path to a native linker.
  late final Uri? linker;

  /// Path to a native archiver.
  late final Uri? archiver;

  /// Path to script that sets environment variables for [compiler], [linker],
  /// and [archiver].
  late final Uri? envScript;

  /// Arguments for [envScript].
  late final List<String>? envScriptArgs;

  /// Constructs a new [CCompilerConfig] based on the given toolchain tools.
  CCompilerConfig({
    this.archiver,
    this.compiler,
    this.linker,
    this.envScript,
    this.envScriptArgs,
  });

  /// Constructs a [CCompilerConfig] from the given [json].
  ///
  /// The json is expected to be valid encoding obtained via
  /// [CCompilerConfig.toJson].
  factory CCompilerConfig.fromJson(Map<String, Object?> json) {
    final compiler = _parseCompiler(json);
    return CCompilerConfig(
      archiver: _parseArchiver(json),
      compiler: compiler,
      envScript: _parseEnvScript(json, compiler),
      envScriptArgs: _parseEnvScriptArgs(json),
      linker: _parseLinker(json),
    );
  }

  // TODO(https://github.com/dart-lang/native/issues/1599): The main reason
  // these keys are exposed is due to usage on Dart CI testing infrastructure.
  // If our infrastructure supplies the native toolchains via passing those down
  // to the `dart build/run` via overrides we should no longer need to expose
  // these here.
  static const configKey = 'c_compiler';
  static const arConfigKey = 'ar';
  static const arConfigKeyFull = '$configKey.$arConfigKey';
  static const ccConfigKey = 'cc';
  static const ccConfigKeyFull = '$configKey.$ccConfigKey';
  static const ldConfigKey = 'ld';
  static const ldConfigKeyFull = '$configKey.$ldConfigKey';
  static const envScriptConfigKey = 'env_script';
  static const envScriptConfigKeyFull = '$configKey.$envScriptConfigKey';
  static const envScriptArgsConfigKey = 'env_script_arguments';
  static const envScriptArgsConfigKeyFull =
      '$configKey.$envScriptArgsConfigKey';

  /// The json representation of this [CCompilerConfig].
  ///
  /// The returned json can be used in [CCompilerConfig.fromJson] to
  /// obtain a [CCompilerConfig] again.
  Map<String, Object> toJson() => {
        if (archiver != null) arConfigKey: archiver!.toFilePath(),
        if (compiler != null) ccConfigKey: compiler!.toFilePath(),
        if (linker != null) ldConfigKey: linker!.toFilePath(),
        if (envScript != null) envScriptConfigKey: envScript!.toFilePath(),
        if (envScriptArgs != null) envScriptArgsConfigKey: envScriptArgs!,
      }.sortOnKey();

  @override
  bool operator ==(Object other) {
    if (other is! CCompilerConfig) {
      return false;
    }
    if (other.archiver != archiver) return false;
    if (other.compiler != compiler) return false;
    if (other.linker != linker) return false;
    if (other.envScript != envScript) return false;
    if (!const ListEquality<String>()
        .equals(other.envScriptArgs, envScriptArgs)) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        archiver,
        compiler,
        linker,
        envScript,
        const ListEquality<String>().hash(envScriptArgs),
      );
}

Uri? _parseArchiver(Map<String, Object?> config) => config.optionalPath(
      CCompilerConfig.arConfigKey,
      mustExist: true,
    );

Uri? _parseCompiler(Map<String, Object?> config) => config.optionalPath(
      CCompilerConfig.ccConfigKey,
      mustExist: true,
    );

Uri? _parseLinker(Map<String, Object?> config) => config.optionalPath(
      CCompilerConfig.ldConfigKey,
      mustExist: true,
    );

Uri? _parseEnvScript(Map<String, Object?> config, Uri? compiler) =>
    (compiler != null && compiler.toFilePath().endsWith('cl.exe'))
        ? config.path(CCompilerConfig.envScriptConfigKey, mustExist: true)
        : null;

List<String>? _parseEnvScriptArgs(Map<String, Object?> config) =>
    config.optionalStringList(CCompilerConfig.envScriptArgsConfigKey);
