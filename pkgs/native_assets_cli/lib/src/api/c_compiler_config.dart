// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of 'build_config.dart';

/// The configuration for a C toolchain.
abstract final class CCompilerConfig {
  /// Path to a C compiler.
  Uri? get compiler;

  /// Path to a native linker.
  Uri? get linker;

  /// Path to a native archiver.
  Uri? get archiver;

  /// Path to script that sets environment variables for [compiler], [linker],
  /// and [archiver].
  Uri? get envScript;

  /// Arguments for [envScript].
  List<String>? get envScriptArgs;

  factory CCompilerConfig({
    Uri? archiver,
    Uri? compiler,
    Uri? linker,
    Uri? envScript,
    List<String>? envScriptArgs,
  }) = CCompilerConfigImpl;
}
