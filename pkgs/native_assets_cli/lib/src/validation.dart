// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import '../native_assets_cli_builder.dart';

typedef ValidationErrors = List<String>;

Future<ValidationErrors> validateBuildInput(BuildInput input) async =>
    _validateHookInput('BuildInput', input);

Future<ValidationErrors> validateLinkInput(LinkInput input) async {
  final recordUses = input.recordedUsagesFile;
  return <String>[
    ..._validateHookInput('LinkInput', input),
    if (recordUses != null)
      ..._validateDirectory(
        '$LinkInput.recordUses',
        input.outputDirectoryShared,
      ),
  ];
}

ValidationErrors _validateHookInput(String inputName, HookInput input) {
  final errors = <String>[
    ..._validateDirectory('$inputName.packageRoot', input.packageRoot),
    ..._validateDirectory('$inputName.outputDirectory', input.outputDirectory),
    ..._validateDirectory(
      '$inputName.outputDirectoryShared',
      input.outputDirectoryShared,
    ),
    ..._validateDirectory(
      '$inputName.outputFile',
      input.outputFile,
      mustExist: false,
    ),
  ];
  return errors;
}

ValidationErrors _validateDirectory(
  String name,
  Uri uri, {
  bool mustExist = true,
  bool mustBeAbsolute = true,
}) {
  final errors = <String>[];
  if (mustBeAbsolute && !uri.isAbsolute) {
    errors.add('$name (${uri.toFilePath()}) must be an absolute path.');
  }
  if (mustExist && !Directory.fromUri(uri).existsSync()) {
    errors.add('$name (${uri.toFilePath()}) does not exist as a directory.');
  }
  return errors;
}

/// Invoked by package:native_assets_builder
Future<ValidationErrors> validateBuildOutput(
  BuildInput input,
  BuildOutput output,
) async {
  final errors = [
    ..._validateAssetsForLinking(input, output),
    ..._validateOutputAssetTypes(input, output.assets.encodedAssets),
  ];
  if (input.config.linkingEnabled) {
    for (final assets in output.assets.encodedAssetsForLinking.values) {
      errors.addAll(_validateOutputAssetTypes(input, assets));
    }
  }
  return errors;
}

/// Invoked by package:native_assets_builder
Future<ValidationErrors> validateLinkOutput(
  LinkInput input,
  LinkOutput output,
) async {
  final errors = [
    ..._validateOutputAssetTypes(input, output.assets.encodedAssets),
  ];
  return errors;
}

/// Only output asset types that are supported by the embedder.
List<String> _validateOutputAssetTypes(
  HookInput input,
  Iterable<EncodedAsset> assets,
) {
  final errors = <String>[];
  final List<String> buildAssetTypes;
  if (input is BuildInput) {
    buildAssetTypes = input.config.buildAssetTypes;
  } else {
    buildAssetTypes = (input as LinkInput).config.buildAssetTypes;
  }
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
  BuildInput input,
  BuildOutput output,
) {
  final errors = <String>[];
  if (!input.config.linkingEnabled) {
    if (output.assets.encodedAssetsForLinking.isNotEmpty) {
      const error = 'BuildOutput.assetsForLinking is not empty while '
          'BuildInput.config.linkingEnabled is false';
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
