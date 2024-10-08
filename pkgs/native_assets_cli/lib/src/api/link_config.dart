// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:pub_semver/pub_semver.dart';

import '../architecture.dart';
import '../args_parser.dart';
import '../build_mode.dart';
import '../c_compiler_config.dart';
import '../encoded_asset.dart';
import '../ios_sdk.dart';
import '../json_utils.dart';
import '../link_mode_preference.dart';
import '../model/hook.dart';
import '../os.dart';
import '../utils/map.dart';
import 'build_config.dart';
import 'hook_config.dart';

part '../model/link_config.dart';

/// The configuration for a link hook (`hook/link.dart`) invocation.
///
/// It consists of a subset of the fields from the [BuildConfig] already passed
/// to the build hook and the [encodedAssets] from the build step.
abstract class LinkConfig implements HookConfig {
  /// The list of assets to be linked. These are the assets generated by a
  /// `build.dart` script destined for this packages `link.dart`.
  Iterable<EncodedAsset> get encodedAssets;

  /// The path to the file containing recorded uses after kernel tree-shaking.
  ///
  /// The file contents can be parsed using `package:record_use`.
  @experimental
  Uri? get recordedUsagesFile;

  /// Generate the [LinkConfig] from the input arguments to the linking script.
  factory LinkConfig.fromArguments(List<String> arguments) =>
      LinkConfigImpl.fromArguments(arguments);

  factory LinkConfig.build({
    required Uri outputDirectory,
    required Uri outputDirectoryShared,
    required String packageName,
    required Uri packageRoot,
    Architecture? targetArchitecture,
    required OS targetOS,
    IOSSdk? targetIOSSdk,
    int? targetIOSVersion,
    int? targetMacOSVersion,
    CCompilerConfig? cCompiler,
    BuildMode? buildMode,
    required Iterable<String> supportedAssetTypes,
    int? targetAndroidNdkApi,
    required Iterable<EncodedAsset> assets,
    required LinkModePreference linkModePreference,
    bool? dryRun,
    Version? version,
  }) =>
      LinkConfigImpl(
        encodedAssets: assets,
        outputDirectory: outputDirectory,
        outputDirectoryShared: outputDirectoryShared,
        packageName: packageName,
        packageRoot: packageRoot,
        buildMode: buildMode,
        cCompiler: cCompiler,
        targetAndroidNdkApi: targetAndroidNdkApi,
        targetArchitecture: targetArchitecture,
        targetIOSSdk: targetIOSSdk,
        targetOS: targetOS,
        targetIOSVersion: targetIOSVersion,
        targetMacOSVersion: targetMacOSVersion,
        dryRun: dryRun,
        linkModePreference: linkModePreference,
        supportedAssetTypes: supportedAssetTypes,
        version: version,
      );

  factory LinkConfig.dryRun({
    required Uri outputDirectory,
    required Uri outputDirectoryShared,
    required String packageName,
    required Uri packageRoot,
    required OS targetOS,
    required Iterable<String> supportedAssetTypes,
    required Iterable<EncodedAsset> assets,
    required LinkModePreference linkModePreference,
    Version? version,
  }) =>
      LinkConfigImpl.dryRun(
        encodedAssets: assets,
        outputDirectory: outputDirectory,
        outputDirectoryShared: outputDirectoryShared,
        packageName: packageName,
        packageRoot: packageRoot,
        targetOS: targetOS,
        supportedAssetTypes: supportedAssetTypes,
        linkModePreference: linkModePreference,
        version: version,
      );

  /// The version of [BuildConfig].
  ///
  /// The build config is used in the protocol between the Dart and Flutter SDKs
  /// and packages through build hook invocations.
  ///
  /// We're trying to avoid breaking changes. However, in the case that we have
  /// to, the major version mismatch between the Dart or Flutter SDK and build
  /// hook (`hook/build.dart`) will lead to a nice error message.
  static Version get latestVersion => HookConfigImpl.latestVersion;
}
