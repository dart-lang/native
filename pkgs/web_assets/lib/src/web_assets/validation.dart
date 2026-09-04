// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:hooks/hooks.dart';

import 'syntax.g.dart';
import 'web_asset.dart';

Future<ValidationErrors> validateWebAssetBuildInput(BuildInput input) async => [
  ..._validateHookInput([
    for (final assets in input.assets.encodedAssets.values) ...assets,
  ]),
];

Future<ValidationErrors> validateWebAssetLinkInput(LinkInput input) async =>
    _validateHookInput(input.assets.encodedAssets);

List<String> _validateHookInput(List<EncodedAsset> assets) {
  final errors = <String>[];
  for (final asset in assets) {
    final syntaxErrors = _validateWebAssetSyntax(asset);
    if (!asset.isWebAsset) continue;
    if (syntaxErrors.isNotEmpty) {
      errors.addAll(syntaxErrors);
      continue;
    }
    final dataAsset = WebAsset.fromEncoded(asset);
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
    if (!asset.isWebAsset) continue;
    final syntaxErrors = _validateWebAssetSyntax(asset);
    if (syntaxErrors.isNotEmpty) {
      errors.addAll(syntaxErrors);
      continue;
    }
    _validateWebAsset(input, WebAsset.fromEncoded(asset), errors, ids, isBuild);
  }
  return errors;
}

void _validateWebAsset(
  HookInput input,
  WebAsset dataAsset,
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

ValidationErrors _validateWebAssetSyntax(EncodedAsset encodedAsset) {
  if (!encodedAsset.isWebAsset) {
    return [];
  }
  final syntaxNode = WebAssetEncodingSyntax.fromJson(
    encodedAsset.encoding,
    path: encodedAsset.encodingJsonPath ?? [],
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
    errors.add(
      '$name (${uri.toFilePath()}) must be an absolute path. '
      'Prefer constructing it via `input.outputDirectoryShared` or '
      '`input.packageRoot`.',
    );
  }
  if (mustExist && !File.fromUri(uri).existsSync()) {
    errors.add('$name (${uri.toFilePath()}) does not exist as a file.');
  }
  return errors;
}
