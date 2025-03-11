// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'config.dart';
import 'encoded_asset.dart';

typedef ValidationErrors = List<String>;

/// An extension to the base protocol for `hook/build.dart` and
/// `hook/link.dart`.
///
/// The extension contains callbacks to
/// 1. setup the input, and
/// 2. validate semantic constraints.
abstract interface class ProtocolExtension {
  /// The [HookConfig.buildAssetTypes] this extension adds.
  List<String> get buildAssetTypes;

  /// Setup the [BuildConfig] for this extension.
  void setupBuildInput(BuildInputBuilder input);

  /// Setup the [HookConfig] for this extension.
  void setupLinkInput(LinkInputBuilder input);

  /// Reports semantic errors from this extension on the [BuildInput].
  Future<ValidationErrors> validateBuildInput(BuildInput input);

  /// Reports semantic errors from this extension on the [LinkInput].
  Future<ValidationErrors> validateBuildOutput(
    BuildInput input,
    BuildOutput output,
  );

  /// Reports semantic errors from this extension on the [LinkInput].
  Future<ValidationErrors> validateLinkInput(LinkInput input);

  /// Reports semantic errors from this extension on the [LinkOutput].
  Future<ValidationErrors> validateLinkOutput(
    LinkInput input,
    LinkOutput output,
  );

  /// Reports errors on the complete set of assets after all hooks are run.
  ///
  /// Can be used to validate that there are no asset-id or shared library name
  /// collisions.
  Future<ValidationErrors> validateApplicationAssets(List<EncodedAsset> assets);
}
