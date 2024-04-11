// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:cli_config/cli_config.dart';
import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';
import 'package:pub_semver/pub_semver.dart';

import '../model/hook.dart';
import '../model/hook_config.dart';
import '../model/metadata.dart';
import '../model/target.dart';
import '../utils/json.dart';
import '../utils/map.dart';
import 'architecture.dart';
import 'asset.dart';
import 'build.dart';
import 'build_mode.dart';
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
  /// The directory in which all output and intermediate artifacts should be
  /// placed.
  Uri get outputDirectory;

  /// The name of the package the assets are built for.
  String get packageName;

  /// The root of the package the assets are built for.
  ///
  /// Often a package's assets are built because a package is a dependency of
  /// another. For this it is convenient to know the packageRoot.
  Uri get packageRoot;

  /// The architecture being compiled for.
  ///
  /// Not specified (`null`) during a [dryRun].
  Architecture? get targetArchitecture;

  /// The operating system being compiled for.
  OS get targetOS;

  /// When compiling for iOS, whether to target device or simulator.
  ///
  /// Not available if [targetOS] is [OS.iOS]. Will throw a [StateError] if
  /// accessed during a [dryRun].
  ///
  /// Not available during a [dryRun]. Will throw a [StateError] if accessed
  /// during a [dryRun].
  IOSSdk get targetIOSSdk;

  /// When compiling for Android, the minimum Android SDK API version to that
  /// the compiled code will be compatible with.
  ///
  /// Required when [targetOS] equals [OS.android].
  ///
  /// Not available during a [dryRun]. Will throw a [StateError] if accessed
  /// during a [dryRun].
  ///
  /// For more information about the Android API version, refer to
  /// [`minSdkVersion`](https://developer.android.com/ndk/guides/sdk-versions#minsdkversion)
  /// in the Android documentation.
  int? get targetAndroidNdkApi;

  /// The preferred [LinkMode] method for [NativeCodeAsset]s.
  LinkModePreference get linkModePreference;

  /// Metadata from a direct dependency.
  ///
  /// The [packageName] of is the package name of the direct dependency.
  ///
  /// Returns `null` if metadata was not provided.
  ///
  /// Not available during a [dryRun]. Will throw a [StateError] if accessed
  /// during a [dryRun].
  Object? metadatum(String packageName, String key);

  /// The configuration for invoking the C compiler.
  ///
  /// Not available during a [dryRun]. Will throw a [StateError] if accessed
  /// during a [dryRun].
  CCompilerConfig get cCompiler;

  /// Whether this run is a dry-run, which doesn't build anything.
  ///
  /// A dry-run only reports information about which assets a build would
  /// create, but doesn't actually create files.
  bool get dryRun;

  /// The [BuildMode] that the code should be compiled in.
  ///
  /// Currently [BuildMode.debug] and [BuildMode.release] are the only modes.
  ///
  /// Not available during a [dryRun]. Will throw a [StateError] if accessed
  /// during a [dryRun].
  BuildMode get buildMode;

  /// The asset types that the invoker of this build supports.
  ///
  /// Currently known values:
  /// * [NativeCodeAsset.type]
  /// * [DataAsset.type]
  Iterable<String> get supportedAssetTypes;

  /// The version of [BuildConfig].
  ///
  /// The build config is used in the protocol between the Dart and Flutter SDKs
  /// and packages through build hook invocations.
  ///
  /// We're trying to avoid breaking changes. However, in the case that we have
  /// to, the major version mismatch between the Dart or Flutter SDK and build
  /// hook (`hook/build.dart`) will lead to a nice error message.
  static Version get latestVersion => BuildConfigImpl.latestVersion;

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
  /// parameters in [metadatum].
  factory BuildConfig.build({
    required Uri outputDirectory,
    required String packageName,
    required Uri packageRoot,
    required BuildMode buildMode,
    required Architecture targetArchitecture,
    required OS targetOS,
    IOSSdk? targetIOSSdk,
    int? targetAndroidNdkApi,
    CCompilerConfig? cCompiler,
    required LinkModePreference linkModePreference,
    Map<String, Map<String, Object>>? dependencyMetadata,
    Iterable<String>? supportedAssetTypes,
  }) =>
      BuildConfigImpl(
        outDir: outputDirectory,
        packageName: packageName,
        packageRoot: packageRoot,
        buildMode: buildMode as BuildModeImpl,
        targetArchitecture: targetArchitecture as ArchitectureImpl,
        targetOS: targetOS as OSImpl,
        targetIOSSdk: targetIOSSdk as IOSSdkImpl?,
        targetAndroidNdkApi: targetAndroidNdkApi,
        cCompiler: cCompiler as CCompilerConfigImpl?,
        linkModePreference: linkModePreference as LinkModePreferenceImpl,
        dependencyMetadata: dependencyMetadata != null
            ? {
                for (final entry in dependencyMetadata.entries)
                  entry.key: Metadata(entry.value.cast())
              }
            : {},
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
    required Uri outDir,
    required String packageName,
    required Uri packageRoot,
    required OS targetOS,
    required LinkModePreference linkModePreference,
    Iterable<String>? supportedAssetTypes,
  }) =>
      BuildConfigImpl.dryRun(
        outDir: outDir,
        packageName: packageName,
        packageRoot: packageRoot,
        targetOS: targetOS as OSImpl,
        linkModePreference: linkModePreference as LinkModePreferenceImpl,
        supportedAssetTypes: supportedAssetTypes,
      );
}
