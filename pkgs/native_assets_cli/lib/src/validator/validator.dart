// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import '../api/asset.dart';
import '../api/build_config.dart';
import '../api/build_output.dart';
import '../api/hook_config.dart';
import '../api/link_config.dart';
import '../api/link_mode_preference.dart';

typedef ValidateResult = ({
  bool success,
  List<String> errors,
});

Future<ValidateResult> validateBuild(
  BuildConfig config,
  BuildOutput output,
) async {
  output as HookOutputImpl;
  final errors = [
    ...validateAssetsForLinking(config, output),
    ...validateOutputAssetTypes(config, output),
    if (!config.dryRun) ...await validateFilesExist(config, output),
    ...validateNativeCodeAssets(config, output),
    ...validateAssetId(config, output),
    if (!config.dryRun) ...validateNoDuplicateAssetIds(output),
    ...validateNoDuplicateDylibs(output.assets),
  ];
  return (
    success: errors.isEmpty,
    errors: errors,
  );
}

Future<ValidateResult> validateLink(
  LinkConfig config,
  LinkOutput output,
) async {
  output as HookOutputImpl;
  final errors = [
    ...validateOutputAssetTypes(config, output),
    if (!config.dryRun) ...await validateFilesExist(config, output),
    ...validateNativeCodeAssets(config, output),
    if (!config.dryRun) ...validateNoDuplicateAssetIds(output),
    ...validateNoDuplicateDylibs(output.assets),
  ];

  return (
    success: errors.isEmpty,
    errors: errors,
  );
}

/// AssetsForLinking should be empty if linking is not supported.
List<String> validateAssetsForLinking(
  BuildConfig config,
  BuildOutput output,
) {
  final errors = <String>[];
  if (!config.linkingEnabled) {
    if (output.assetsForLinking.isNotEmpty) {
      const error = 'BuildOutput.assetsForLinking is not empty while '
          'BuildConfig.linkingEnabled is false';
      errors.add(error);
    }
  }
  return errors;
}

/// Only output asset types that are supported by the embedder.
List<String> validateOutputAssetTypes(
  HookConfig config,
  HookOutputImpl output,
) {
  final errors = <String>[];
  final supportedAssetTypes = config.supportedAssetTypes;
  for (final asset in output.assets) {
    if (!supportedAssetTypes.contains(asset.type)) {
      // Note that DataAssets don't have an ID in their API, so error messages
      // might be confusing.
      final error =
          'Asset "${asset.id}" has asset type "${asset.type}", which is '
          'not in supportedAssetTypes';
      errors.add(error);
    }
  }
  return errors;
}

/// Files mentioned in assets must exist.
Future<List<String>> validateFilesExist(
  HookConfig config,
  HookOutputImpl output,
) async {
  final errors = <String>[];

  await Future.wait(output.allAssets.map((asset) async {
    final file = asset.file;
    asset as AssetImpl;
    // Note that DataAssets don't have an ID in their API, so error messages
    // might be confusing.
    if (file == null && !config.dryRun) {
      final error = 'Asset "${asset.id}" has no file.';
      errors.add(error);
    }
    if (file != null && !config.dryRun && !await File.fromUri(file).exists()) {
      final error =
          'Asset "${asset.id}" has a file "${asset.file!.toFilePath()}", which '
          'does not exist.';
      errors.add(error);
    }
  }));

  return errors;
}

extension on Asset {
  String get type {
    switch (this) {
      case NativeCodeAsset _:
        return NativeCodeAsset.type;
      case DataAsset _:
        return DataAsset.type;
    }
    throw UnsupportedError('Unknown asset type');
  }
}

extension on HookOutputImpl {
  Iterable<Asset> get allAssets =>
      [...assets, ...assetsForLinking.values.expand((e) => e)];
}

/// Native code assets for bundling should have a supported linking type.
List<String> validateNativeCodeAssets(
  HookConfig config,
  HookOutputImpl output,
) {
  final errors = <String>[];
  final linkModePreference = config.linkModePreference;
  for (final asset in output.assets.whereType<NativeCodeAsset>()) {
    final linkMode = asset.linkMode;
    if ((linkMode is DynamicLoading &&
            linkModePreference == LinkModePreference.static) ||
        (linkMode is StaticLinking &&
            linkModePreference == LinkModePreference.dynamic)) {
      final error = 'Asset "${asset.id}" has a link mode "$linkMode", which '
          'is not allowed by by the config link mode preference '
          '"$linkModePreference".';
      errors.add(error);
    }

    final os = asset.os;
    if (config.targetOS != os) {
      final error = 'Asset "${asset.id}" has a os "$os", which '
          'is not the target os "${config.targetOS}".';
      errors.add(error);
    }

    final architecture = asset.architecture;
    if (!config.dryRun) {
      if (architecture == null) {
        final error = 'Asset "${asset.id}" has no architecture.';
        errors.add(error);
      } else if (architecture != config.targetArchitecture) {
        final error =
            'Asset "${asset.id}" has an architecture "$architecture", which '
            'is not the target architecture "${config.targetArchitecture}".';
        errors.add(error);
      }
    }
  }
  return errors;
}

/// Build hooks must only output assets in their own package namespace.
List<String> validateAssetId(
  HookConfig config,
  BuildOutput output,
) {
  final errors = <String>[];
  final packageName = config.packageName;
  for (final asset in output.assets) {
    asset as AssetImpl;
    // Note that DataAssets don't have an ID in their API, so error messages
    // might be confusing.
    if (!asset.id.startsWith('package:$packageName/')) {
      final error = 'Asset "${asset.id}" does not start with '
          '"package:$packageName/".';
      errors.add(error);
    }
  }
  return errors;
}

List<String> validateNoDuplicateAssetIds(
  BuildOutput output,
) {
  final errors = <String>[];
  final assetIds = <String>{};
  for (final asset in output.assets) {
    asset as AssetImpl;
    // Note that DataAssets don't have an ID in their API, so error messages
    // might be confusing.
    if (assetIds.contains(asset.id)) {
      final error = 'Duplicate asset id: "${asset.id}".';
      errors.add(error);
    } else {
      assetIds.add(asset.id);
    }
  }
  return errors;
}

List<String> validateNoDuplicateDylibs(
  Iterable<Asset> assets,
) {
  final errors = <String>[];
  final fileNameToAssetId = <String, Set<String>>{};
  for (final asset in assets.whereType<NativeCodeAsset>()) {
    if (asset.linkMode is! DynamicLoadingBundled) {
      continue;
    }
    final file = asset.file;
    if (file == null) {
      continue;
    }
    final fileName = file.pathSegments.where((s) => s.isNotEmpty).last;
    fileNameToAssetId[fileName] ??= {};
    fileNameToAssetId[fileName]!.add(asset.id);
  }
  for (final fileName in fileNameToAssetId.keys) {
    final assetIds = fileNameToAssetId[fileName]!;
    if (assetIds.length > 1) {
      final assetIdsString = assetIds.map((e) => '"$e"').join(', ');
      final error =
          'Duplicate dynamic library file name "$fileName" for the following'
          ' asset ids: $assetIdsString.';
      errors.add(error);
    }
  }
  return errors;
}
