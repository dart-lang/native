// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import '../../data_assets.dart';
import '../../native_assets_cli.dart';
import '../../native_assets_cli_builder.dart';
import 'syntax.g.dart' as syntax;

Future<ValidationErrors> validateDataAssetBuildInput(BuildInput input) async =>
    [
      ..._validateHookInput([
        for (final assets in input.assets.encodedAssets.values) ...assets,
      ]),
    ];

Future<ValidationErrors> validateDataAssetLinkInput(LinkInput input) async =>
    _validateHookInput(input.assets.encodedAssets);

List<String> _validateHookInput(List<EncodedAsset> assets) {
  final errors = <String>[];
  for (final asset in assets) {
    final syntaxErrors = _validateDataAssetSyntax(asset);
    if (!asset.isDataAsset) continue;
    if (syntaxErrors.isNotEmpty) {
      errors.addAll(syntaxErrors);
      continue;
    }
    final dataAsset = DataAsset.fromEncoded(asset);
    errors.addAll(
      _validateFile(
        'LinkInput.assets.data asset "${dataAsset.id}" file',
        dataAsset.file,
      ),
    );
  }
  return errors;
}

Future<ValidationErrors> validateDataAssetBuildOutput(
  BuildInput input,
  BuildOutput output,
) => _validateDataAssetBuildOrLinkOutput(input, [
  ...output.assets.encodedAssets,
  ...output.assets.encodedAssetsForBuild,
  for (final assetList in output.assets.encodedAssetsForLinking.values)
    ...assetList,
], true);

Future<ValidationErrors> validateDataAssetLinkOutput(
  LinkInput input,
  LinkOutput output,
) => _validateDataAssetBuildOrLinkOutput(
  input,
  output.assets.encodedAssets,
  false,
);

Future<ValidationErrors> _validateDataAssetBuildOrLinkOutput(
  HookInput input,
  List<EncodedAsset> encodedAssets,
  bool isBuild,
) async {
  final errors = <String>[];
  final ids = <String>{};

  for (final asset in encodedAssets) {
    if (!asset.isDataAsset) continue;
    final syntaxErrors = _validateDataAssetSyntax(asset);
    if (syntaxErrors.isNotEmpty) {
      errors.addAll(syntaxErrors);
      continue;
    }
    _validateDataAsset(
      input,
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
  DataAsset dataAsset,
  ValidationErrors errors,
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
  errors.addAll(_validateFile('Data asset ${dataAsset.name} file', file));
}

ValidationErrors _validateDataAssetSyntax(EncodedAsset encodedAsset) {
  if (!encodedAsset.isDataAsset) {
    return [];
  }
  final syntaxNode = syntax.DataAssetEncoding.fromJson(
    encodedAsset.encoding,
    path: encodedAsset.jsonPath ?? [],
  );
  final syntaxErrors = syntaxNode.validate();
  if (syntaxErrors.isEmpty) {
    return [];
  }
  return [...syntaxErrors, semanticValidationSkippedMessage(syntaxNode.path)];
}

String semanticValidationSkippedMessage(List<Object> jsonPath) {
  final pathString = jsonPath.join('.');
  return "Syntax errors in '$pathString'. Semantic validation skipped.";
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
