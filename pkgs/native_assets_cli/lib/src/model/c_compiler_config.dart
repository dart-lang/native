// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../api/build_config.dart';

class CCompilerConfigImpl implements CCompilerConfig {
  /// Path to a C compiler.
  @override
  Uri? get cc => _cc;
  late final Uri? _cc;

  /// Path to a native linker.
  @override
  Uri? get ld => _ld;
  late final Uri? _ld;

  /// Path to a native archiver.
  @override
  Uri? get ar => _ar;
  late final Uri? _ar;

  /// Path to script that sets environment variables for [cc], [ld], and [ar].
  @override
  Uri? get envScript => _envScript;
  late final Uri? _envScript;

  /// Arguments for [envScript].
  @override
  List<String>? get envScriptArgs => _envScriptArgs;
  late final List<String>? _envScriptArgs;

  factory CCompilerConfigImpl({
    Uri? ar,
    Uri? cc,
    Uri? ld,
    Uri? envScript,
    List<String>? envScriptArgs,
  }) =>
      CCompilerConfigImpl._()
        .._ar = ar
        .._cc = cc
        .._ld = ld
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

  Map<String, Object> toYaml() => {
        if (_ar != null) arConfigKey: _ar.toFilePath(),
        if (_cc != null) ccConfigKey: _cc.toFilePath(),
        if (_ld != null) ldConfigKey: _ld.toFilePath(),
        if (_envScript != null) envScriptConfigKey: _envScript.toFilePath(),
        if (_envScriptArgs != null) envScriptArgsConfigKey: _envScriptArgs,
      }.sortOnKey();

  @override
  bool operator ==(Object other) {
    if (other is! CCompilerConfigImpl) {
      return false;
    }
    if (other.ar != ar) return false;
    if (other.cc != cc) return false;
    if (other.ld != ld) return false;
    if (other.envScript != envScript) return false;
    if (!const ListEquality<String>()
        .equals(other.envScriptArgs, envScriptArgs)) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        _ar,
        _cc,
        _ld,
        _envScript,
        const ListEquality<String>().hash(envScriptArgs),
      );
}
