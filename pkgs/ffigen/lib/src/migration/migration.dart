// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'migrator.dart';

/// Migrates a YAML configuration file to a Dart configuration script.
///
/// Reads [yamlConfig] (or file at [yamlPath]) and writes a Dart configuration
/// script to [outputDart] (or file at [outputPath]).
void migrate({
  File? yamlConfig,
  File? outputDart,
  String? yamlPath,
  String? outputPath,
}) {
  final configFile = yamlConfig ?? (yamlPath != null ? File(yamlPath) : null);
  final dartFile = outputDart ?? (outputPath != null ? File(outputPath) : null);

  if (configFile == null) {
    throw ArgumentError('Either yamlConfig or yamlPath must be provided.');
  }
  if (dartFile == null) {
    throw ArgumentError('Either outputDart or outputPath must be provided.');
  }

  if (!configFile.existsSync()) {
    throw FileSystemException(
      'YAML config file does not exist',
      configFile.path,
    );
  }

  YamlMigrator(yamlConfig: configFile, outputDart: dartFile).migrate();
}
