// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:cli_config/cli_config.dart';
import 'package:pub_semver/pub_semver.dart';

import '../model/build_config.dart' as model;
import '../model/build_mode.dart' as model;
import '../model/ios_sdk.dart' as model;
import '../model/link_mode_preference.dart' as model;
import '../model/target.dart' as model;
import 'build_mode.dart';
import 'ios_sdk.dart';
import 'link_mode_preference.dart';
import 'metadata.dart';
import 'target.dart';

abstract class BuildConfig {
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

  /// The target being compiled for.
  ///
  /// Not available in [dryRun].
  Target get target;

  /// The architecture being compiled for.
  ///
  /// Not available in [dryRun].
  Architecture get targetArchitecture;

  /// The operating system being compiled for.
  OS get targetOs;

  /// When compiling for iOS, whether to target device or simulator.
  ///
  /// Required when [targetOs] equals [OS.iOS].
  ///
  /// Not available in [dryRun].s
  IOSSdk? get targetIOSSdk;

  /// When compiling for Android, the minimum Android SDK API version to that
  /// the compiled code will be compatible with.
  ///
  /// Required when [targetOs] equals [OS.android].
  ///
  /// Not available in [dryRun].
  ///
  /// For more information about the Android API version, refer to
  /// [`minSdkVersion`](https://developer.android.com/ndk/guides/sdk-versions#minsdkversion)
  /// in the Android documentation.
  int? get targetAndroidNdkApi;

  /// Preferred linkMode method for library.
  LinkModePreference get linkModePreference;

  /// Metadata from direct dependencies.
  ///
  /// The key in the map is the package name of the dependency.
  ///
  /// The key in the nested map is the key for the metadata from the dependency.
  ///
  /// Not available in [dryRun].
  Map<String, Metadata>? get dependencyMetadata;

  /// The configuration for invoking the C compiler.
  ///
  /// Not available in [dryRun].
  CCompilerConfig get cCompiler;

  /// Don't run the build, only report the native assets produced.
  bool get dryRun;

  /// The build mode that the code should be compiled in.
  ///
  /// Not available in [dryRun].
  BuildMode get buildMode;

  /// The underlying config.
  ///
  /// Can be used for easier access to values on [dependencyMetadata].
  Config get config;

  /// The version of [BuildConfig].
  ///
  /// This class is used in the protocol between the Dart and Flutter SDKs
  /// and packages through `build.dart` invocations.
  ///
  /// If we ever were to make breaking changes, it would be useful to give
  /// proper error messages rather than just fail to parse the YAML
  /// representation in the protocol.
  static Version get version => model.BuildConfig.version;

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
    Map<String, Metadata>? dependencyMetadata,
  }) =>
      model.BuildConfig(
        outDir: outDir,
        packageName: packageName,
        packageRoot: packageRoot,
        buildMode: buildMode as model.BuildMode,
        targetArchitecture: targetArchitecture as model.Architecture,
        targetOs: targetOs as model.OS,
        targetIOSSdk: targetIOSSdk as model.IOSSdk?,
        targetAndroidNdkApi: targetAndroidNdkApi,
        cCompiler: cCompiler as model.CCompilerConfig?,
        linkModePreference: linkModePreference as model.LinkModePreference,
        dependencyMetadata: dependencyMetadata?.cast(),
      );

  factory BuildConfig.dryRun({
    required Uri outDir,
    required String packageName,
    required Uri packageRoot,
    required OS targetOs,
    required LinkModePreference linkModePreference,
  }) =>
      model.BuildConfig.dryRun(
        outDir: outDir,
        packageName: packageName,
        packageRoot: packageRoot,
        targetOs: targetOs as model.OS,
        linkModePreference: linkModePreference as model.LinkModePreference,
      );

  factory BuildConfig.fromConfig(Config config) =>
      model.BuildConfig.fromConfig(config);

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
      model.BuildConfig.fromArgs(
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
  }) = model.CCompilerConfig;
}
