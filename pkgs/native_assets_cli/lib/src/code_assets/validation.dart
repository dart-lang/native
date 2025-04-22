// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import '../config.dart';
import '../encoded_asset.dart';
import '../validation.dart';
import 'code_asset.dart';
import 'config.dart';
import 'link_mode.dart';
import 'link_mode_preference.dart';
import 'os.dart';
import 'syntax.g.dart' as syntax;

Future<ValidationErrors> validateCodeAssetBuildInput(BuildInput input) async =>
    [
      ..._validateConfig('BuildInput.config.code', input.config),
      ...await _validateCodeAssetHookInput([
        for (final assets in input.assets.encodedAssets.values) ...assets,
      ]),
    ];

Future<ValidationErrors> validateCodeAssetLinkInput(LinkInput input) async => [
  ..._validateConfig('LinkInput.config.code', input.config),
  ...await _validateCodeAssetHookInput(input.assets.encodedAssets),
];

ValidationErrors _validateConfig(String inputName, HookConfig config) {
  final syntaxErrors = _validateConfigSyntax(config);
  if (syntaxErrors.isNotEmpty) {
    return syntaxErrors;
  }

  final code = config.code;
  final errors = <String>[];
  final cCompiler = code.cCompiler;
  if (cCompiler != null) {
    errors.addAll([
      ..._validateFile('$inputName.cCompiler.compiler', cCompiler.compiler),
      ..._validateFile('$inputName.cCompiler.linker', cCompiler.linker),
      ..._validateFile('$inputName.cCompiler.archiver', cCompiler.archiver),
    ]);
    if (code.targetOS == OS.windows &&
        cCompiler.windows.developerCommandPrompt != null) {
      errors.addAll([
        ..._validateFile(
          '$inputName.cCompiler.windows.developerCommandPrompt.script',
          cCompiler.windows.developerCommandPrompt!.script,
        ),
      ]);
    }
  }
  return errors;
}

ValidationErrors _validateConfigSyntax(HookConfig config) {
  final syntaxNode = syntax.Config.fromJson(config.json, path: config.path);
  final syntaxErrors = syntaxNode.validate();
  if (syntaxErrors.isEmpty) {
    return [];
  }
  return [...syntaxErrors, _semanticValidationSkippedMessage(syntaxNode.path)];
}

Future<ValidationErrors> _validateCodeAssetHookInput(
  List<EncodedAsset> encodedAssets,
) async {
  final errors = <String>[];
  for (final asset in encodedAssets) {
    if (!asset.isCodeAsset) continue;
    final syntaxErrors = _validateCodeAssetSyntax(asset);
    if (syntaxErrors.isNotEmpty) {
      errors.addAll(syntaxErrors);
      continue;
    }
    errors.addAll(_validateCodeAssetFile(CodeAsset.fromEncoded(asset)));
  }
  return errors;
}

Future<ValidationErrors> validateCodeAssetBuildOutput(
  BuildInput input,
  BuildOutput output,
) => _validateCodeAssetBuildOrLinkOutput(
  input,
  input.config.code,
  output.assets.encodedAssets,
  [
    ...output.assets.encodedAssetsForBuild,
    for (final assetList in output.assets.encodedAssetsForLinking.values)
      ...assetList,
  ],
  output,
  true,
);

Future<ValidationErrors> validateCodeAssetLinkOutput(
  LinkInput input,
  LinkOutput output,
) => _validateCodeAssetBuildOrLinkOutput(
  input,
  input.config.code,
  output.assets.encodedAssets,
  [],
  output,
  false,
);

/// Validates that the given code assets can be used together in an application.
///
/// Some restrictions - e.g. unique shared library names - have to be validated
/// on the entire application build and not on individual `hook/build.dart`
/// invocations.
Future<ValidationErrors> validateCodeAssetInApplication(
  List<EncodedAsset> assets,
) async {
  final fileNameToEncodedAssetId = <String, Set<String>>{};
  for (final asset in assets) {
    if (!asset.isCodeAsset) continue;
    _groupCodeAssetsByFilename(
      CodeAsset.fromEncoded(asset),
      fileNameToEncodedAssetId,
    );
  }
  final errors = <String>[];
  _validateNoDuplicateDylibNames(errors, fileNameToEncodedAssetId);
  return errors;
}

Future<ValidationErrors> _validateCodeAssetBuildOrLinkOutput(
  HookInput input,
  CodeConfig codeConfig,
  List<EncodedAsset> encodedAssetsBundled,
  List<EncodedAsset> encodedAssetsNotBundled,
  HookOutput output,
  bool isBuild,
) async {
  final errors = <String>[];
  final idsBundled = <String>{};
  final fileNameToEncodedAssetId = <String, Set<String>>{};

  for (final asset in encodedAssetsBundled) {
    if (!asset.isCodeAsset) continue;
    final syntaxErrors = _validateCodeAssetSyntax(asset);
    if (syntaxErrors.isNotEmpty) {
      errors.addAll(syntaxErrors);
      continue;
    }
    _validateCodeAsset(
      input,
      codeConfig,
      CodeAsset.fromEncoded(asset),
      errors,
      idsBundled,
      isBuild,
      true,
    );
    _groupCodeAssetsByFilename(
      CodeAsset.fromEncoded(asset),
      fileNameToEncodedAssetId,
    );
  }

  final idsNotBundled = <String>{};
  for (final asset in encodedAssetsNotBundled) {
    if (!asset.isCodeAsset) continue;
    final syntaxErrors = _validateCodeAssetSyntax(asset);
    if (syntaxErrors.isNotEmpty) {
      errors.addAll(syntaxErrors);
      continue;
    }
    _validateCodeAsset(
      input,
      codeConfig,
      CodeAsset.fromEncoded(asset),
      errors,
      idsNotBundled,
      isBuild,
      false,
    );
  }
  _validateNoDuplicateDylibNames(errors, fileNameToEncodedAssetId);
  return errors;
}

ValidationErrors _validateCodeAssetSyntax(EncodedAsset encodedAsset) {
  if (!encodedAsset.isCodeAsset) {
    return [];
  }
  final syntaxNode = syntax.NativeCodeAssetEncoding.fromJson(
    encodedAsset.encoding,
    path: encodedAsset.jsonPath ?? [],
  );
  final syntaxErrors = syntaxNode.validate();
  if (syntaxErrors.isEmpty) {
    return [];
  }
  return [...syntaxErrors, _semanticValidationSkippedMessage(syntaxNode.path)];
}

String _semanticValidationSkippedMessage(List<Object> jsonPath) {
  final pathString = jsonPath.join('.');
  return "Syntax errors in '$pathString'. Semantic validation skipped.";
}

void _validateCodeAsset(
  HookInput input,
  CodeConfig codeConfig,
  CodeAsset codeAsset,
  ValidationErrors errors,
  Set<String> ids,
  bool validateAssetId,
  bool validateLinkMode,
) {
  final id = codeAsset.id;
  final prefix = 'package:${input.packageName}/';
  if (validateAssetId && !id.startsWith(prefix)) {
    errors.add('Code asset "$id" does not start with "$prefix".');
  }
  if (!ids.add(id)) {
    errors.add('More than one code asset with same "$id" id.');
  }

  if (validateLinkMode) {
    final preference = codeConfig.linkModePreference;
    final linkMode = codeAsset.linkMode;
    if ((linkMode is DynamicLoading &&
            preference == LinkModePreference.static) ||
        (linkMode is StaticLinking &&
            preference == LinkModePreference.dynamic)) {
      errors.add(
        'CodeAsset "$id" has a link mode "$linkMode", which '
        'is not allowed by by the input link mode preference '
        '"$preference".',
      );
    }
  }

  errors.addAll(_validateCodeAssetFile(codeAsset));
}

ValidationErrors _validateCodeAssetFile(CodeAsset codeAsset) {
  final id = codeAsset.id;
  final file = codeAsset.file;
  return [
    if (file == null && _mustHaveFile(codeAsset.linkMode))
      'CodeAsset "$id" has no file.',
    if (file != null) ..._validateFile('Code asset "$id" file', file),
  ];
}

bool _mustHaveFile(LinkMode linkMode) => switch (linkMode) {
  LookupInExecutable _ => false,
  LookupInProcess _ => false,
  DynamicLoadingSystem _ => false,
  DynamicLoadingBundled _ => true,
  StaticLinking _ => true,
  _ => throw UnsupportedError('Unknown link mode: $linkMode.'),
};

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
  ValidationErrors errors,
  Map<String, Set<String>> fileNameToEncodedAssetId,
) {
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
