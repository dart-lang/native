// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import '../../code_assets_builder.dart';
import 'config.dart';
import 'link_mode.dart';

Future<ValidationErrors> validateCodeAssetBuildInput(BuildInput input) async =>
    _validateCodeConfig(
      'BuildInput',
      // ignore: deprecated_member_use_from_same_package
      input.targetConfig.dryRun,
      input.targetConfig.codeConfig,
    );

Future<ValidationErrors> validateCodeAssetLinkInput(LinkInput input) async =>
    _validateCodeConfig(
      'LinkInput',
      false,
      input.targetConfig.codeConfig,
    );

ValidationErrors _validateCodeConfig(
  String inputName,
  bool dryRun,
  CodeConfig codeConfig,
) {
  // The dry run will be removed soon.
  if (dryRun) return const [];

  final errors = <String>[];
  final targetOS = codeConfig.targetOS;
  switch (targetOS) {
    case OS.macOS:
      if (codeConfig.macOSConfig.targetVersionSyntactic == null) {
        errors.add('$inputName.targetOS is OS.macOS but '
            '$inputName.targetConfig.codeConfig.macOSConfig.targetVersion'
            ' was missing');
      }
      break;
    case OS.iOS:
      if (codeConfig.iOSConfig.targetSdkSyntactic == null) {
        errors.add('$inputName.targetOS is OS.iOS but '
            '$inputName.targetConfig.codeConfig.targetIOSSdk was missing');
      }
      if (codeConfig.iOSConfig.targetVersionSyntactic == null) {
        errors.add('$inputName.targetOS is OS.iOS but '
            '$inputName.targetConfig.codeConfig.iOSConfig.targetVersion'
            ' was missing');
      }
      break;
    case OS.android:
      if (codeConfig.androidConfig.targetNdkApiSyntactic == null) {
        errors.add('$inputName.targetOS is OS.android but '
            '$inputName.targetConfig.codeConfig.androidConfig.targetNdkApi'
            ' was missing');
      }
      break;
  }
  final compilerConfig = codeConfig.cCompiler;
  if (compilerConfig != null) {
    final compiler = compilerConfig.compiler.toFilePath();
    if (!File(compiler).existsSync()) {
      errors.add('$inputName.targetConfig.codeConfig.compiler ($compiler) does'
          ' not exist.');
    }
    final linker = compilerConfig.linker.toFilePath();
    if (!File(linker).existsSync()) {
      errors.add(
        '$inputName.targetConfig.codeConfig.linker ($linker) does not exist.',
      );
    }
    final archiver = compilerConfig.archiver.toFilePath();
    if (!File(archiver).existsSync()) {
      errors.add('$inputName.targetConfig.codeConfig.archiver ($archiver) does'
          ' not exist.');
    }
    final envScript = compilerConfig.envScript?.toFilePath();
    if (envScript != null && !File(envScript).existsSync()) {
      errors
          .add('$inputName.targetConfig.codeConfig.envScript ($envScript) does'
              ' not exist.');
    }
  }
  return errors;
}

Future<ValidationErrors> validateCodeAssetBuildOutput(
  BuildInput input,
  BuildOutput output,
) =>
    _validateCodeAssetBuildOrLinkOutput(
      input,
      input.targetConfig.codeConfig,
      output.encodedAssets,
      // ignore: deprecated_member_use_from_same_package
      input.targetConfig.dryRun,
      output,
      true,
    );

Future<ValidationErrors> validateCodeAssetLinkOutput(
  LinkInput input,
  LinkOutput output,
) =>
    _validateCodeAssetBuildOrLinkOutput(input, input.targetConfig.codeConfig,
        output.encodedAssets, false, output, false);

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
  HookInput input,
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
      input,
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
  HookInput input,
  CodeConfig codeConfig,
  bool dryRun,
  CodeAsset codeAsset,
  List<String> errors,
  Set<String> ids,
  bool isBuild,
) {
  final id = codeAsset.id;
  final prefix = 'package:${input.packageName}/';
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
        'is not allowed by by the input link mode preference '
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
