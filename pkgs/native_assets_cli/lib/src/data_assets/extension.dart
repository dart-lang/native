// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../config.dart';
import '../encoded_asset.dart';
import '../extension.dart';
import 'data_asset.dart';
import 'validation.dart';

/// The protocol extension for the `hook/build.dart` and `hook/link.dart`
/// with [DataAsset]s.
final class DataAssetsExtension implements ProtocolExtension {
  DataAssetsExtension();

  @override
  void setupBuildInput(BuildInputBuilder input) {
    _setupConfig(input);
  }

  @override
  void setupLinkInput(LinkInputBuilder input) {
    _setupConfig(input);
  }

  void _setupConfig(HookInputBuilder input) {
    input.config.addBuildAssetTypes(DataAssetType.typesForBuildAssetTypes);
  }

  @override
  Future<ValidationErrors> validateBuildInput(BuildInput input) =>
      validateDataAssetBuildInput(input);

  @override
  Future<ValidationErrors> validateLinkInput(LinkInput input) =>
      validateDataAssetLinkInput(input);

  @override
  Future<ValidationErrors> validateBuildOutput(
    BuildInput input,
    BuildOutput output,
  ) => validateDataAssetBuildOutput(input, output);

  @override
  Future<ValidationErrors> validateLinkOutput(
    LinkInput input,
    LinkOutput output,
  ) => validateDataAssetLinkOutput(input, output);

  @override
  Future<ValidationErrors> validateApplicationAssets(
    List<EncodedAsset> assets,
  ) async => [];
}
