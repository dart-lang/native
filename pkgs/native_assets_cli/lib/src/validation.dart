// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import '../native_assets_cli_builder.dart';

typedef ValidationErrors = List<String>;

Future<ValidationErrors> validateBuildConfig(BuildConfig config) async =>
    _validateHookConfig(config);

Future<ValidationErrors> validateLinkConfig(LinkConfig config) async {
  final errors = <String>[
    ..._validateHookConfig(config),
  ];
  final recordUses = config.recordedUsagesFile;
  if (recordUses != null && !File.fromUri(recordUses).existsSync()) {
    errors.add('Config.recordUses ($recordUses) does not exist.');
  }
  return errors;
}

ValidationErrors _validateHookConfig(HookConfig config) {
  final errors = <String>[];
  if (!Directory.fromUri(config.packageRoot).existsSync()) {
    errors.add('Config.packageRoot (${config.packageRoot}) '
        'has to be an existing directory.');
  }
  if (!Directory.fromUri(config.outputDirectory).existsSync()) {
    errors.add('Config.outputDirectory (${config.outputDirectory}) '
        'has to be an existing directory.');
  }
  if (!Directory.fromUri(config.outputDirectoryShared).existsSync()) {
    errors.add('Config.outputDirectoryShared (${config.outputDirectoryShared}) '
        'has to be an existing directory');
  }
  return errors;
}

/// Invoked by package:native_assets_builder
Future<ValidationErrors> validateBuildOutput(
  BuildConfig config,
  BuildOutput output,
) async {
  final errors = [
    ..._validateAssetsForLinking(config, output),
    ..._validateOutputAssetTypes(config, output.encodedAssets),
  ];
  if (config.linkingEnabled) {
    for (final assets in output.encodedAssetsForLinking.values) {
      errors.addAll(_validateOutputAssetTypes(config, assets));
    }
  }
  return errors;
}

/// Invoked by package:native_assets_builder
Future<ValidationErrors> validateLinkOutput(
  LinkConfig config,
  LinkOutput output,
) async {
  final errors = [
    ..._validateOutputAssetTypes(config, output.encodedAssets),
  ];
  return errors;
}

/// Only output asset types that are supported by the embedder.
List<String> _validateOutputAssetTypes(
  HookConfig config,
  Iterable<EncodedAsset> assets,
) {
  final errors = <String>[];
  final buildAssetTypes = config.buildAssetTypes;
  for (final asset in assets) {
    if (!buildAssetTypes.contains(asset.type)) {
      final error =
          'Asset with type "${asset.type}" is not a supported asset type '
          '(${buildAssetTypes.join(' ')} are supported)';
      errors.add(error);
    }
  }
  return errors;
}

/// EncodedAssetsForLinking should be empty if linking is not supported.
List<String> _validateAssetsForLinking(
  BuildConfig config,
  BuildOutput output,
) {
  final errors = <String>[];
  if (!config.linkingEnabled) {
    if (output.encodedAssetsForLinking.isNotEmpty) {
      const error = 'BuildOutput.assetsForLinking is not empty while '
          'BuildConfig.linkingEnabled is false';
      errors.add(error);
    }
  }
  return errors;
}

class ValidationFailure implements Exception {
  final String? message;

  ValidationFailure(this.message);

  @override
  String toString() => message.toString();
}
