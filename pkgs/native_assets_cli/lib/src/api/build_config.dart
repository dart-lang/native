// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:cli_config/cli_config.dart';
import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';
import 'package:pub_semver/pub_semver.dart';

import '../model/metadata.dart';
import '../utils/map.dart';
import '../utils/yaml.dart';
import 'build_mode.dart';
import 'ios_sdk.dart';
import 'link_mode_preference.dart';
import 'target.dart';

part '../model/build_config.dart';

/// The configuration for a `build.dart` invocation.
///
/// A package can choose to have a toplevel `build.dart` script. If such a
/// script exists, it will be automatically run, by the Flutter and Dart SDK
/// tools. The script will then be run with specific commandline arguments,
/// which [BuildConfig] can parse and provide more convenient access to.
abstract final class BuildConfig {
  /// The folder in which all output and intermediate artifacts should be
  /// placed.
  Uri get outDir;

  /// The name of the package the native assets are built for.
  String get packageName;

  /// The root of the package the native assets are built for.
  ///
  /// Often a package's native assets are built because a package is a
  /// dependency of another. For this it is convenient to know the packageRoot.
  Uri get packageRoot;

  // /// The target being compiled for.
  // ///
  // /// Not available during a [dryRun].
  // Target get target;

  /// The architecture being compiled for.
  ///
  /// Not available during a [dryRun].
  Architecture get targetArchitecture;

  /// The operating system being compiled for.
  OS get targetOs;

  /// When compiling for iOS, whether to target device or simulator.
  ///
  /// Required when [targetOs] equals [OS.iOS].
  ///
  /// Not available during a [dryRun].
  IOSSdk? get targetIOSSdk;

  /// When compiling for Android, the minimum Android SDK API version to that
  /// the compiled code will be compatible with.
  ///
  /// Required when [targetOs] equals [OS.android].
  ///
  /// Not available during a [dryRun].
  ///
  /// For more information about the Android API version, refer to
  /// [`minSdkVersion`](https://developer.android.com/ndk/guides/sdk-versions#minsdkversion)
  /// in the Android documentation.
  int? get targetAndroidNdkApi;

  /// Preferred linkMode method for library.
  LinkModePreference get linkModePreference;

  /// Get the metadata from a direct dependency.
  ///
  /// The [packageName] of is the package name of the direct dependency.
  ///
  /// Returns `null` if metadata was not provided.
  ///
  /// Not available during a [dryRun].
  Object? metadatum(String packageName, String key);

  /// The configuration for invoking the C compiler.
  ///
  /// Not available during a [dryRun].
  CCompilerConfig get cCompiler;

  /// Whether the current run is a "dry run".
  ///
  /// If so, the build won't actually be run, but will report the native assets
  /// which would have been produced.
  bool get dryRun;

  /// The build mode that the code should be compiled in.
  ///
  /// Not available during a [dryRun].
  BuildMode get buildMode;

  /// The underlying config.
  Config get config;

  /// The version of [BuildConfig].
  ///
  /// This class is used in the protocol between the Dart and Flutter SDKs
  /// and packages through `build.dart` invocations.
  ///
  /// If we ever were to make breaking changes, it would be useful to give
  /// proper error messages rather than just fail to parse the YAML
  /// representation in the protocol.
  static Version get version => BuildConfigImpl.version;

  factory BuildConfig({
    required Uri outDir,
    required String packageName,
    required Uri packageRoot,
    required BuildMode buildMode,
    required Architecture targetArchitecture,
    required OS targetOs,
    IOSSdk? targetIOSSdk,
    int? targetAndroidNdkApi,
    CCompilerConfig? cCompiler,
    required LinkModePreference linkModePreference,
    Map<String, Map<String, Object>>? dependencyMetadata,
  }) =>
      BuildConfigImpl(
        outDir: outDir,
        packageName: packageName,
        packageRoot: packageRoot,
        buildMode: buildMode as BuildModeImpl,
        targetArchitecture: targetArchitecture as ArchitectureImpl,
        targetOs: targetOs as OSImpl,
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
      );

  factory BuildConfig.dryRun({
    required Uri outDir,
    required String packageName,
    required Uri packageRoot,
    required OS targetOs,
    required LinkModePreference linkModePreference,
  }) =>
      BuildConfigImpl.dryRun(
        outDir: outDir,
        packageName: packageName,
        packageRoot: packageRoot,
        targetOs: targetOs as OSImpl,
        linkModePreference: linkModePreference as LinkModePreferenceImpl,
      );

  factory BuildConfig.fromConfig(Config config) =>
      BuildConfigImpl.fromConfig(config);

  /// Constructs a config by parsing CLI arguments and loading the config file.
  ///
  /// The [args] must be commandline arguments.
  ///
  /// If provided, [environment] must be a map containing environment variables.
  /// If not provided, [environment] defaults to [Platform.environment].
  ///
  /// If provided, [workingDirectory] is used to resolves paths inside
  /// [environment].
  /// If not provided, [workingDirectory] defaults to [Directory.current].
  ///
  /// This async constructor is intended to be used directly in CLI files.
  static Future<BuildConfig> fromArgs(
    List<String> args, {
    Map<String, String>? environment,
    Uri? workingDirectory,
  }) =>
      BuildConfigImpl.fromArgs(
        args,
        environment: environment,
        workingDirectory: workingDirectory,
      );
}

abstract class CCompilerConfig {
  /// Path to a C compiler.
  Uri? get cc;

  /// Path to a native linker.
  Uri? get ld;

  /// Path to a native archiver.
  Uri? get ar;

  /// Path to script that sets environment variables for [cc], [ld], and [ar].
  Uri? get envScript;

  /// Arguments for [envScript].
  List<String>? get envScriptArgs;

  factory CCompilerConfig({
    Uri? ar,
    Uri? cc,
    Uri? ld,
    Uri? envScript,
    List<String>? envScriptArgs,
  }) = CCompilerConfigImpl;
}
