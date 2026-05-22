// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:hooks/hooks.dart';

import '../hooks_runner/syntax.g.dart';

/// The configuration for the recorded use file (`package:record_use`) used in
/// link hooks.
final class RecordUseConfig {
  /// The absolute URI to the file containing recorded usages on disk.
  final Uri file;

  /// The entry point file URIs compiled under this target.
  ///
  /// Unique entry points means separate caching for link hooks.
  final List<Uri> entryPoints;

  /// The compiler (e.g. compiler version and runtime environment path) plus
  /// any compiler options that influence record use and for which separate
  /// caching is wanted.
  ///
  /// Unique compilers means separate caching for link hooks.
  final String compiler;

  RecordUseConfig({
    required this.file,
    required this.entryPoints,
    required this.compiler,
  });
}

/// Extension to initialize hooks runner specific target configurations on hook
/// configs.
extension HooksRunnerBuildInputBuilder on HookConfigBuilder {
  /// Sets up the hooks runner caching targets under extensions map key
  /// "hooks_runner".
  void setupHooksRunner({
    RecordUseConfig? recordUse,
  }) {
    if (recordUse == null) return;

    final baseHookConfig = ConfigSyntax.fromJson(json);
    baseHookConfig.extensions ??= ConfigExtensionsSyntax.fromJson({});

    final hookConfig = ConfigSyntax.fromJson(baseHookConfig.json);
    hookConfig.extensions!.hooksRunner = HooksRunnerConfigSyntax(
      recordUse: RecordUseConfigSyntax(
        entryPoints: [for (final e in recordUse.entryPoints) e.toFilePath()],
        compiler: recordUse.compiler,
      ),
    );
  }
}
