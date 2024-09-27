// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import '../../native_assets_cli_internal.dart';
import '../link_mode.dart';

Future<ValidationErrors> validateCodeAssetBuildOutput(
  HookConfig config,
  BuildOutput output,
) =>
    _validateCodeAssetBuildOrLinkOutput(config, output as HookOutputImpl, true);

Future<ValidationErrors> validateCodeAssetLinkOutput(
  HookConfig config,
  LinkOutput output,
) =>
    _validateCodeAssetBuildOrLinkOutput(
        config, output as HookOutputImpl, false);

/// Validates that the given code assets can be used together in an application.
///
/// Some restrictions - e.g. unique shared library names - have to be validated
/// on the entire application build and not on individual `hook/build.dart`
/// invocations.
Future<ValidationErrors> validateCodeAssetsInApplication(
    List<EncodedAsset> assets) async {
  final fileNameToEncodedAssetId = <String, Set<String>>{};
  for (final asset in assets) {
    if (asset.type != CodeAsset.type) continue;
    _groupCodeAssetsByFilename(
        CodeAsset.fromEncoded(asset), fileNameToEncodedAssetId);
  }
  final errors = <String>[];
  _validateNoDuplicateDylibNames(errors, fileNameToEncodedAssetId);
  return errors;
}

Future<ValidationErrors> _validateCodeAssetBuildOrLinkOutput(
  HookConfig config,
  HookOutputImpl output,
  bool isBuild,
) async {
  final errors = <String>[];
  final ids = <String>{};
  final fileNameToEncodedAssetId = <String, Set<String>>{};

  for (final asset in output.encodedAssets) {
    if (asset.type != CodeAsset.type) continue;
    _validateCodeAssets(
      config,
      config.dryRun,
      CodeAsset.fromEncoded(asset),
      errors,
      ids,
      isBuild,
    );
    _groupCodeAssetsByFilename(
        CodeAsset.fromEncoded(asset), fileNameToEncodedAssetId);
  }
  _validateNoDuplicateDylibNames(errors, fileNameToEncodedAssetId);
  return errors;
}

void _validateCodeAssets(
  HookConfig config,
  bool dryRun,
  CodeAsset codeAsset,
  List<String> errors,
  Set<String> ids,
  bool isBuild,
) {
  final id = codeAsset.id;
  final prefix = 'package:${config.packageName}/';
  if (isBuild && !id.startsWith(prefix)) {
    errors.add('Code asset "$id" does not start with "$prefix".');
  }
  if (!ids.add(id)) {
    errors.add('More than one code asset with same "$id" id.');
  }

  final preference = config.linkModePreference;
  final linkMode = codeAsset.linkMode;
  if ((linkMode is DynamicLoading && preference == LinkModePreference.static) ||
      (linkMode is StaticLinking && preference == LinkModePreference.dynamic)) {
    errors.add('CodeAsset "$id" has a link mode "$linkMode", which '
        'is not allowed by by the config link mode preference '
        '"$preference".');
  }

  final os = codeAsset.os;
  if (config.targetOS != os) {
    final error = 'CodeAsset "$id" has a os "$os", which '
        'is not the target os "${config.targetOS}".';
    errors.add(error);
  }

  final architecture = codeAsset.architecture;
  if (!dryRun) {
    if (architecture == null) {
      errors.add('CodeAsset "$id" has no architecture.');
    } else if (architecture != config.targetArchitecture) {
      errors.add('CodeAsset "$id" has an architecture "$architecture", which '
          'is not the target architecture "${config.targetArchitecture}".');
    }
  }

  final file = codeAsset.file;
  if (file == null && !dryRun) {
    errors.add('CodeAsset "$id" has no file.');
  }
  if (file != null && !dryRun && !File.fromUri(file).existsSync()) {
    errors.add('CodeAsset "$id" has a file "${file.toFilePath()}", which '
        'does not exist.');
  }
}

void _groupCodeAssetsByFilename(
  CodeAsset codeAsset,
  Map<String, Set<String>> fileNameToEncodedAssetId,
) {
  final file = codeAsset.file;
  if (file != null) {
    final fileName = file.pathSegments.where((s) => s.isNotEmpty).last;
    fileNameToEncodedAssetId[fileName] ??= {};
    fileNameToEncodedAssetId[fileName]!.add(codeAsset.id);
  }
}

void _validateNoDuplicateDylibNames(
    List<String> errors, Map<String, Set<String>> fileNameToEncodedAssetId) {
  for (final fileName in fileNameToEncodedAssetId.keys) {
    final assetIds = fileNameToEncodedAssetId[fileName]!;
    if (assetIds.length > 1) {
      final assetIdsString = assetIds.map((e) => '"$e"').join(', ');
      final error =
          'Duplicate dynamic library file name "$fileName" for the following'
          ' asset ids: $assetIdsString.';
      errors.add(error);
    }
  }
}
