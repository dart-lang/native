// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../data_assets_builder.dart';
import 'validation.dart';

/// The protocol extension for the `hook/build.dart` and `hook/link.dart`
/// with [DataAsset]s.
final class DataAssetsExtension implements ProtocolExtension {
  DataAssetsExtension();

  @override
  List<String> get buildAssetTypes => [DataAsset.type];

  @override
  void setupBuildInput(BuildInputBuilder input) {}

  @override
  void setupLinkInput(LinkInputBuilder input) {}

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
