// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import '../../data_assets_builder.dart';

Future<ValidationErrors> validateDataAssetBuildInput(BuildInput input) async =>
    const [];

Future<ValidationErrors> validateDataAssetLinkInput(LinkInput input) async {
  final errors = <String>[
    for (final asset in input.assets.data)
      ..._validateFile(
        'LinkInput.assets.data asset "${asset.id}" file',
        asset.file,
      ),
  ];
  return errors;
}

Future<ValidationErrors> validateDataAssetBuildOutput(
  BuildInput input,
  BuildOutput output,
) => _validateDataAssetBuildOrLinkOutput(
  input,
  output.assets.encodedAssets,
  // ignore: deprecated_member_use_from_same_package
  input.config.dryRun,
  true,
);

Future<ValidationErrors> validateDataAssetLinkOutput(
  LinkInput input,
  LinkOutput output,
) => _validateDataAssetBuildOrLinkOutput(
  input,
  output.assets.encodedAssets,
  false,
  false,
);

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
    _validateDataAsset(
      input,
      dryRun,
      DataAsset.fromEncoded(asset),
      errors,
      ids,
      isBuild,
    );
  }
  return errors;
}

void _validateDataAsset(
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
    errors.add('More than one data asset with same "${dataAsset.name}" name.');
  }
  final file = dataAsset.file;
  errors.addAll(
    _validateFile(
      'Data asset ${dataAsset.name} file',
      file,
      mustExist: !dryRun,
    ),
  );
}

ValidationErrors _validateFile(
  String name,
  Uri uri, {
  bool mustExist = true,
  bool mustBeAbsolute = true,
}) {
  final errors = <String>[];
  if (mustBeAbsolute && !uri.isAbsolute) {
    errors.add('$name (${uri.toFilePath()}) must be an absolute path.');
  }
  if (mustExist && !File.fromUri(uri).existsSync()) {
    errors.add('$name (${uri.toFilePath()}) does not exist as a file.');
  }
  return errors;
}
