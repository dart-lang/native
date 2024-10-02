// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import '../../native_assets_cli_internal.dart';

Future<ValidationErrors> validateDataAssetBuildOutput(
  HookConfig config,
  BuildOutput output,
) =>
    _validateDataAssetBuildOrLinkOutput(config, output as HookOutputImpl, true);

Future<ValidationErrors> validateDataAssetLinkOutput(
  HookConfig config,
  LinkOutput output,
) =>
    _validateDataAssetBuildOrLinkOutput(
        config, output as HookOutputImpl, false);

Future<ValidationErrors> _validateDataAssetBuildOrLinkOutput(
  HookConfig config,
  HookOutputImpl output,
  bool isBuild,
) async {
  final errors = <String>[];
  final ids = <String>{};

  for (final asset in output.encodedAssets) {
    if (asset.type != DataAsset.type) continue;
    _validateDataAssets(config, config.dryRun, DataAsset.fromEncoded(asset),
        errors, ids, isBuild);
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
