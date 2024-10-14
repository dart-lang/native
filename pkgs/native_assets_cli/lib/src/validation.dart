// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../native_assets_cli_internal.dart';

typedef ValidationErrors = List<String>;

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
  final supportedAssetTypes = config.supportedAssetTypes;
  for (final asset in assets) {
    if (!supportedAssetTypes.contains(asset.type)) {
      final error =
          'Asset with type "${asset.type}" is not a supported asset type '
          '(${supportedAssetTypes.join(' ')} are supported)';
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
