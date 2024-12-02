// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import '../../data_assets_builder.dart';

Future<ValidationErrors> validateDataAssetBuildConfig(
        BuildConfig config) async =>
    const [];

Future<ValidationErrors> validateDataAssetLinkConfig(LinkConfig config) async {
  final errors = <String>[];
  for (final asset in config.dataAssets) {
    if (!File.fromUri(asset.file).existsSync()) {
      errors.add('LinkConfig.dataAssets contained asset ${asset.id} with file '
          '(${asset.file}) which does not exist.');
    }
  }
  return errors;
}

Future<ValidationErrors> validateDataAssetBuildOutput(
  BuildConfig config,
  BuildOutput output,
) =>
    _validateDataAssetBuildOrLinkOutput(
      config,
      output.encodedAssets,
      // ignore: deprecated_member_use_from_same_package
      config.dryRun,
      true,
    );

Future<ValidationErrors> validateDataAssetLinkOutput(
  LinkConfig config,
  LinkOutput output,
) =>
    _validateDataAssetBuildOrLinkOutput(
        config, output.encodedAssets, false, false);

Future<ValidationErrors> _validateDataAssetBuildOrLinkOutput(
  HookConfig config,
  List<EncodedAsset> encodedAssets,
  bool dryRun,
  bool isBuild,
) async {
  final errors = <String>[];
  final ids = <String>{};

  for (final asset in encodedAssets) {
    if (asset.type != DataAsset.type) continue;
    _validateDataAssets(
        config, dryRun, DataAsset.fromEncoded(asset), errors, ids, isBuild);
  }
  return errors;
}

void _validateDataAssets(
  HookConfig config,
  bool dryRun,
  DataAsset dataAsset,
  List<String> errors,
  Set<String> ids,
  bool isBuild,
) {
  if (isBuild && dataAsset.package != config.packageName) {
    errors.add('Data asset must have package name ${config.packageName}');
  }
  if (!ids.add(dataAsset.name)) {
    errors.add('More than one code asset with same "${dataAsset.name}" name.');
  }
  final file = dataAsset.file;
  if (!dryRun && (!File.fromUri(file).existsSync())) {
    errors.add(
        'EncodedAsset "${dataAsset.name}" has a file "${file.toFilePath()}", '
        'which does not exist.');
  }
}
