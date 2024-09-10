// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:cli_config/cli_config.dart';
import 'package:collection/collection.dart';
import 'package:pub_semver/pub_semver.dart';

import '../model/hook.dart';
import '../model/metadata.dart';
import '../utils/json.dart';
import '../utils/map.dart';
import 'architecture.dart';
import 'asset.dart';
import 'build.dart';
import 'build_mode.dart';
import 'build_output.dart';
import 'deprecation_messages.dart';
import 'hook_config.dart';
import 'ios_sdk.dart';
import 'link_mode_preference.dart';
import 'os.dart';

part '../model/build_config.dart';
part '../model/c_compiler_config.dart';
part 'c_compiler_config.dart';

/// The configuration for a build hook (`hook/build.dart`) invocation.
///
/// A package can optionally provide build hook. If such a hook exists, it will
/// be automatically run, by the Flutter and Dart SDK tools. The hook will be
/// run with specific commandline arguments, which [BuildConfig] can parse and
/// provide more convenient access to.
abstract final class BuildConfig implements HookConfig {
  /// Metadata from a direct dependency.
  ///
  /// The [packageName] of is the package name of the direct dependency.
  ///
  /// Returns `null` if metadata was not provided.
  ///
  /// Not available during a [dryRun]. Will throw a [StateError] if accessed
  /// during a [dryRun].
  @Deprecated(metadataDeprecation)
  Object? metadatum(String packageName, String key);

  /// Whether link hooks will be run after the build hooks.
  ///
  /// If [linkingEnabled] is true, [BuildOutput.addAsset] may be called with the
  /// `linkInPackage` parameter so that assets can be linked in a link hook.
  /// Linking is enabled in Flutter release builds and Dart AOT configurations.
  /// These configurations are optimized for app size.
  /// - `flutter build`
  /// - `flutter run --release`
  /// - `dart build`
  ///
  /// If [linkingEnabled] is false, no assets should be added with the
  /// `linkInPackage` parameter set. All assets must be ready for bundling.
  /// Linking is disabled in Flutter debug builds and Dart JIT configurations.
  /// These configurations are optimized for development speed.
  /// - `dart run`
  /// - `flutter run` (debug mode)
  bool get linkingEnabled;

  /// The version of [BuildConfig].
  ///
  /// The build config is used in the protocol between the Dart and Flutter SDKs
  /// and packages through build hook invocations.
  ///
  /// We're trying to avoid breaking changes. However, in the case that we have
  /// to, the major version mismatch between the Dart or Flutter SDK and build
  /// hook (`hook/build.dart`) will lead to a nice error message.
  static Version get latestVersion => HookConfigImpl.latestVersion;

  /// Constructs a config by parsing CLI arguments and loading the config file.
  ///
  /// Build hooks will most likely use [build] instead of this constructor.
  ///
  /// The [arguments] must be commandline arguments.
  ///
  /// If provided, [environment] must be a map containing environment variables.
  /// If not provided, [environment] defaults to [Platform.environment].
  ///
  /// If provided, [workingDirectory] is used to resolves paths inside
  /// [environment]. If not provided, [workingDirectory] defaults to
  /// [Directory.current].
  ///
  /// This async constructor is intended to be used directly in CLI files.
  factory BuildConfig(
    List<String> arguments, {
    Map<String, String>? environment,
    Uri? workingDirectory,
  }) =>
      BuildConfigImpl.fromArguments(
        arguments,
        environment: environment,
        workingDirectory: workingDirectory,
      );

  /// Constructs a config for a non-dry run by providing values for each field.
  ///
  /// Build hooks will most likely use [build] instead of this constructor.
  /// However, for unit testing code which consumes a [BuildConfig], this
  /// constructor facilitates easy construction.
  ///
  /// For the documentation of the parameters, see the equally named fields.
  ///
  /// Parameter [dependencyMetadata] must be a nested map `{'packageName' :
  /// {'key' : 'value'}}` where `packageName` and `key` correspond to the
  // ignore: deprecated_member_use_from_same_package
  /// parameters in [metadatum].
  factory BuildConfig.build({
    required Uri outputDirectory,
    required Uri outputDirectoryShared,
    required String packageName,
    required Uri packageRoot,
    required BuildMode buildMode,
    required Architecture targetArchitecture,
    required OS targetOS,
    IOSSdk? targetIOSSdk,
    int? targetIOSVersion,
    int? targetMacOSVersion,
    int? targetAndroidNdkApi,
    CCompilerConfig? cCompiler,
    required LinkModePreference linkModePreference,
    @Deprecated(metadataDeprecation)
    Map<String, Map<String, Object>>? dependencyMetadata,
    Iterable<String>? supportedAssetTypes,
    required bool linkingEnabled,
  }) =>
      BuildConfigImpl(
        outputDirectory: outputDirectory,
        outputDirectoryShared: outputDirectoryShared,
        packageName: packageName,
        packageRoot: packageRoot,
        buildMode: buildMode as BuildModeImpl,
        targetArchitecture: targetArchitecture as ArchitectureImpl,
        targetOS: targetOS as OSImpl,
        targetIOSSdk: targetIOSSdk as IOSSdkImpl?,
        targetIOSVersion: targetIOSVersion,
        targetMacOSVersion: targetMacOSVersion,
        targetAndroidNdkApi: targetAndroidNdkApi,
        cCompiler: cCompiler as CCompilerConfigImpl?,
        linkModePreference: linkModePreference as LinkModePreferenceImpl,
        dependencyMetadata: dependencyMetadata != null
            ? {
                for (final entry in dependencyMetadata.entries)
                  entry.key: Metadata(entry.value.cast())
              }
            : null,
        linkingEnabled: linkingEnabled,
        supportedAssetTypes: supportedAssetTypes,
      );

  /// Constructs a config for a dry run by providing values for each field.
  ///
  /// Build hooks will most likely use [build] instead of this constructor.
  /// However, for unit testing code which consumes a [BuildConfig], this
  /// constructor facilitates easy construction.
  ///
  /// For the documentation of the parameters, see the equally named fields.
  factory BuildConfig.dryRun({
    required Uri outputDirectory,
    required Uri outputDirectoryShared,
    required String packageName,
    required Uri packageRoot,
    required OS targetOS,
    required LinkModePreference linkModePreference,
    required bool linkingEnabled,
    Iterable<String>? supportedAssetTypes,
  }) =>
      BuildConfigImpl.dryRun(
        outputDirectory: outputDirectory,
        outputDirectoryShared: outputDirectoryShared,
        packageName: packageName,
        packageRoot: packageRoot,
        targetOS: targetOS as OSImpl,
        linkModePreference: linkModePreference as LinkModePreferenceImpl,
        supportedAssetTypes: supportedAssetTypes,
        linkingEnabled: linkingEnabled,
      );
}
