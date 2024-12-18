// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import '../../code_assets_builder.dart';
import 'config.dart';
import 'link_mode.dart';

Future<ValidationErrors> validateCodeAssetBuildConfig(
        BuildConfig config) async =>
    _validateCodeConfig(
      'BuildConfig',
      // ignore: deprecated_member_use_from_same_package
      config.dryRun,
      config.code,
    );

Future<ValidationErrors> validateCodeAssetLinkConfig(LinkConfig config) async =>
    _validateCodeConfig(
      'LinkConfig',
      false,
      config.code,
    );

ValidationErrors _validateCodeConfig(
  String configName,
  bool dryRun,
  CodeConfig codeConfig,
) {
  // The dry run will be removed soon.
  if (dryRun) return const [];

  final errors = <String>[];
  final targetOS = codeConfig.targetOS;
  switch (targetOS) {
    case OS.macOS:
      if (codeConfig.macOS.targetVersionSyntactic == null) {
        errors.add('$configName.targetOS is OS.macOS but '
            '$configName.code.macOS.targetVersion was missing');
      }
      break;
    case OS.iOS:
      if (codeConfig.iOS.targetSdkSyntactic == null) {
        errors.add('$configName.targetOS is OS.iOS but '
            '$configName.code.iOS.targetSdk was missing');
      }
      if (codeConfig.iOS.targetVersionSyntactic == null) {
        errors.add('$configName.targetOS is OS.iOS but '
            '$configName.code.iOS.targetVersion was missing');
      }
      break;
    case OS.android:
      if (codeConfig.android.targetNdkApiSyntactic == null) {
        errors.add('$configName.targetOS is OS.android but '
            '$configName.code.android.targetNdkApi was missing');
      }
      break;
  }
  final compilerConfig = codeConfig.cCompiler;
  if (compilerConfig != null) {
    final compiler = compilerConfig.compiler.toFilePath();
    if (!File(compiler).existsSync()) {
      errors.add('$configName.code.compiler ($compiler) does not exist.');
    }
    final linker = compilerConfig.linker.toFilePath();
    if (!File(linker).existsSync()) {
      errors.add('$configName.code.linker ($linker) does not exist.');
    }
    final archiver = compilerConfig.archiver.toFilePath();
    if (!File(archiver).existsSync()) {
      errors.add('$configName.code.archiver ($archiver) does not exist.');
    }
    final envScript = compilerConfig.envScript?.toFilePath();
    if (envScript != null && !File(envScript).existsSync()) {
      errors.add('$configName.code.envScript ($envScript) does not exist.');
    }
  }
  return errors;
}

Future<ValidationErrors> validateCodeAssetBuildOutput(
  BuildConfig config,
  BuildOutput output,
) =>
    _validateCodeAssetBuildOrLinkOutput(
      config,
      config.code,
      output.encodedAssets,
      // ignore: deprecated_member_use_from_same_package
      config.dryRun,
      output,
      true,
    );

Future<ValidationErrors> validateCodeAssetLinkOutput(
  LinkConfig config,
  LinkOutput output,
) =>
    _validateCodeAssetBuildOrLinkOutput(
        config, config.code, output.encodedAssets, false, output, false);

/// Validates that the given code assets can be used together in an application.
///
/// Some restrictions - e.g. unique shared library names - have to be validated
/// on the entire application build and not on individual `hook/build.dart`
/// invocations.
Future<ValidationErrors> validateCodeAssetInApplication(
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
  CodeConfig codeConfig,
  List<EncodedAsset> encodedAssets,
  bool dryRun,
  HookOutput output,
  bool isBuild,
) async {
  final errors = <String>[];
  final ids = <String>{};
  final fileNameToEncodedAssetId = <String, Set<String>>{};

  for (final asset in encodedAssets) {
    if (asset.type != CodeAsset.type) continue;
    _validateCodeAssets(
      config,
      codeConfig,
      dryRun,
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
  CodeConfig codeConfig,
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

  final preference = codeConfig.linkModePreference;
  final linkMode = codeAsset.linkMode;
  if ((linkMode is DynamicLoading && preference == LinkModePreference.static) ||
      (linkMode is StaticLinking && preference == LinkModePreference.dynamic)) {
    errors.add('CodeAsset "$id" has a link mode "$linkMode", which '
        'is not allowed by by the config link mode preference '
        '"$preference".');
  }

  final os = codeAsset.os;
  if (codeConfig.targetOS != os) {
    final error = 'CodeAsset "$id" has a os "$os", which '
        'is not the target os "${codeConfig.targetOS}".';
    errors.add(error);
  }

  final architecture = codeAsset.architecture;
  if (!dryRun) {
    if (architecture == null) {
      errors.add('CodeAsset "$id" has no architecture.');
    } else if (architecture != codeConfig.targetArchitecture) {
      errors.add('CodeAsset "$id" has an architecture "$architecture", which '
          'is not the target architecture "${codeConfig.targetArchitecture}".');
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
