// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import '../../data_assets_builder.dart';

Future<ValidationErrors> validateDataAssetBuildInput(BuildInput input) async =>
    const [];

Future<ValidationErrors> validateDataAssetLinkInput(LinkInput input) async {
  final errors = <String>[];
  for (final asset in input.dataAssets) {
    if (!File.fromUri(asset.file).existsSync()) {
      errors.add('LinkInput.dataAssets contained asset ${asset.id} with file '
          '(${asset.file}) which does not exist.');
    }
  }
  return errors;
}

Future<ValidationErrors> validateDataAssetBuildOutput(
  BuildInput input,
  BuildOutput output,
) =>
    _validateDataAssetBuildOrLinkOutput(
      input,
      output.encodedAssets,
      // ignore: deprecated_member_use_from_same_package
      input.targetConfig.dryRun,
      true,
    );

Future<ValidationErrors> validateDataAssetLinkOutput(
  LinkInput input,
  LinkOutput output,
) =>
    _validateDataAssetBuildOrLinkOutput(
        input, output.encodedAssets, false, false);

Future<ValidationErrors> _validateDataAssetBuildOrLinkOutput(
  HookInput input,
  List<EncodedAsset> encodedAssets,
  bool dryRun,
  bool isBuild,
) async {
  final errors = <String>[];
  final ids = <String>{};

  for (final asset in encodedAssets) {
    if (asset.type != DataAsset.type) continue;
    _validateDataAssets(
        input, dryRun, DataAsset.fromEncoded(asset), errors, ids, isBuild);
  }
  return errors;
}

void _validateDataAssets(
  HookInput input,
  bool dryRun,
  DataAsset dataAsset,
  List<String> errors,
  Set<String> ids,
  bool isBuild,
) {
  if (isBuild && dataAsset.package != input.packageName) {
    errors.add('Data asset must have package name ${input.packageName}');
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
