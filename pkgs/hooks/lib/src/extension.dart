// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:logging/logging.dart';

import 'config.dart';
import 'encoded_asset.dart';
import 'validation.dart';

/// A list of error messages from validation.
typedef ValidationErrors = List<String>;

/// An extension to the [ProtocolBase] for `hook/build.dart` and
/// `hook/link.dart`.
///
/// The extension contains callbacks to
/// 1. setup the input, and
/// 2. validate syntactic and semantic constraints.
///
/// This is an `abstract base class` rather than an interface so that adding new
/// methods is not a breaking change. This avoids major-version conflicts across
/// the ecosystem: `package:hooks` is a dependency of many packages, whereas
/// [ProtocolExtension] is only extended by a small number of asset type
/// definitions.
///
/// New methods must be added with default implementations such that not
/// overriding them is semantically correct. If a new method cannot have a
/// semantically correct default implementation, downstream maintainers of
/// protocol extensions must be notified.
abstract base class ProtocolExtension {
  /// The [HookConfig.buildAssetTypes] this extension adds.
  // List<String> get buildAssetTypes;

  late Logger _logger;

  /// The logger of the hooks_runner that drives this extension.
  ///
  /// Only valid after [setupLogger] has run, which the hooks_runner guarantees
  /// to do before invoking any other method on this object.
  Logger get logger => _logger;

  /// Sets up the [logger] used by the hooks_runner that drives this extension.
  ///
  /// Guaranteed to be run before any other method is called on this object.
  ///
  /// The field backing [logger] is not `final` because the same extension
  /// object can be reused across the build and link of a single run.
  void setupLogger(Logger logger) {
    _logger = logger;
  }

  /// Setup the [BuildConfig] for this extension.
  void setupBuildInput(BuildInputBuilder input) {}

  /// Setup the [HookConfig] for this extension.
  void setupLinkInput(LinkInputBuilder input) {}

  /// Reports errors from this extension on the [BuildInput].
  Future<ValidationErrors> validateBuildInput(BuildInput input) async => [];

  /// Reports errors from this extension on the [LinkInput].
  Future<ValidationErrors> validateBuildOutput(
    BuildInput input,
    BuildOutput output,
  ) async => [];

  /// Reports errors from this extension on the [LinkInput].
  Future<ValidationErrors> validateLinkInput(LinkInput input) async => [];

  /// Reports errors from this extension on the [LinkOutput].
  Future<ValidationErrors> validateLinkOutput(
    LinkInput input,
    LinkOutput output,
  ) async => [];

  /// Reports errors on the complete set of assets after all hooks are run.
  ///
  /// Can be used to validate that there are no asset-id or shared library name
  /// collisions.
  Future<ValidationErrors> validateApplicationAssets(
    List<EncodedAsset> assets,
  ) async => [];

  /// Returns any files emitted by the hook output for this extension.
  ///
  /// If any of these output files are modified or deleted, the hook needs to be
  /// rerun.
  Iterable<Uri> outputFiles(List<EncodedAsset> assets) => [];
}
