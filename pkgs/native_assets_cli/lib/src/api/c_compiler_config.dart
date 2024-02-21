// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of 'build_config.dart';

abstract final class CCompilerConfig {
  /// Path to a C compiler.
  Uri? get cc;

  /// Path to a native linker.
  Uri? get ld;

  /// Path to a native archiver.
  Uri? get ar;

  /// Path to script that sets environment variables for [cc], [ld], and [ar].
  Uri? get envScript;

  /// Arguments for [envScript].
  List<String>? get envScriptArgs;

  factory CCompilerConfig({
    Uri? ar,
    Uri? cc,
    Uri? ld,
    Uri? envScript,
    List<String>? envScriptArgs,
  }) = CCompilerConfigImpl;
}
