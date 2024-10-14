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
  factory CCompilerConfig.fromJson(Map<String, Object?> json) =>
      CCompilerConfig(
        archiver: json.optionalPath(_arConfigKey),
        compiler: json.optionalPath(_ccConfigKey),
        envScript: json.optionalPath(_envScriptConfigKey),
        envScriptArgs: json.optionalStringList(_envScriptArgsConfigKey),
        linker: json.optionalPath(_ldConfigKey),
      );

  /// The json representation of this [CCompilerConfig].
  ///
  /// The returned json can be used in [CCompilerConfig.fromJson] to
  /// obtain a [CCompilerConfig] again.
  Map<String, Object> toJson() => {
        if (archiver != null) _arConfigKey: archiver!.toFilePath(),
        if (compiler != null) _ccConfigKey: compiler!.toFilePath(),
        if (linker != null) _ldConfigKey: linker!.toFilePath(),
        if (envScript != null) _envScriptConfigKey: envScript!.toFilePath(),
        if (envScriptArgs != null) _envScriptArgsConfigKey: envScriptArgs!,
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

const _arConfigKey = 'ar';
const _ccConfigKey = 'cc';
const _ldConfigKey = 'ld';
const _envScriptConfigKey = 'env_script';
const _envScriptArgsConfigKey = 'env_script_arguments';
