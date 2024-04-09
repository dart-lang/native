// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../api/build_config.dart';

final class CCompilerConfigImpl implements CCompilerConfig {
  /// Path to a C compiler.
  @override
  Uri? get compiler => _compiler;
  late final Uri? _compiler;

  /// Path to a native linker.
  @override
  Uri? get linker => _linker;
  late final Uri? _linker;

  /// Path to a native archiver.
  @override
  Uri? get archiver => _archiver;
  late final Uri? _archiver;

  /// Path to script that sets environment variables for [compiler], [linker],
  /// and [archiver].
  @override
  Uri? get envScript => _envScript;
  late final Uri? _envScript;

  /// Arguments for [envScript].
  @override
  List<String>? get envScriptArgs => _envScriptArgs;
  late final List<String>? _envScriptArgs;

  factory CCompilerConfigImpl({
    Uri? archiver,
    Uri? compiler,
    Uri? linker,
    Uri? envScript,
    List<String>? envScriptArgs,
  }) =>
      CCompilerConfigImpl._()
        .._archiver = archiver
        .._compiler = compiler
        .._linker = linker
        .._envScript = envScript
        .._envScriptArgs = envScriptArgs;

  CCompilerConfigImpl._();

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

  Map<String, Object> toJson() => {
        if (_archiver != null) arConfigKey: _archiver.toFilePath(),
        if (_compiler != null) ccConfigKey: _compiler.toFilePath(),
        if (_linker != null) ldConfigKey: _linker.toFilePath(),
        if (_envScript != null) envScriptConfigKey: _envScript.toFilePath(),
        if (_envScriptArgs != null) envScriptArgsConfigKey: _envScriptArgs,
      }.sortOnKey();

  @override
  bool operator ==(Object other) {
    if (other is! CCompilerConfigImpl) {
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
        _archiver,
        _compiler,
        _linker,
        _envScript,
        const ListEquality<String>().hash(envScriptArgs),
      );
}
