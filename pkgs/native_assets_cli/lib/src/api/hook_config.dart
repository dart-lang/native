// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';
import 'package:pub_semver/pub_semver.dart';

import '../architecture.dart';
import '../build_mode.dart';
import '../c_compiler_config.dart';
import '../code_assets/code_asset.dart';
import '../data_assets/data_asset.dart';
import '../ios_sdk.dart';
import '../json_utils.dart';
import '../link_mode.dart';
import '../link_mode_preference.dart';
import '../model/hook.dart';
import '../model/metadata.dart';
import '../model/target.dart';
import '../os.dart';
import '../utils/map.dart';
import 'build_config.dart';
import 'link_config.dart';

part '../model/hook_config.dart';

/// The shared properties of a [LinkConfig] and a [BuildConfig].
///
/// This abstraction makes it easier to design APIs intended for both kinds of
/// build hooks, building and linking.
abstract class HookConfig {
  /// The directory in which output and intermediate artifacts that are unique
  /// to this configuration can be placed.
  ///
  /// This directory is unique per hook and per configuration.
  ///
  /// The contents of this directory will not be modified by anything else than
  /// the hook itself.
  ///
  /// The invoker of the the hook will ensure concurrent invocations wait on
  /// each other.
  Uri get outputDirectory;

  /// The directory in which shared output and intermediate artifacts can be
  /// placed.
  ///
  /// This directory is unique per hook.
  ///
  /// The contents of this directory will not be modified by anything else than
  /// the hook itself.
  ///
  /// The invoker of the the hook will ensure concurrent invocations wait on
  /// each other.
  Uri get outputDirectoryShared;

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
  /// Only available if [targetOS] is [OS.iOS]. Will throw a [StateError] if
  /// accessed otherwise.
  ///
  /// Not available during a [dryRun]. Will throw a [StateError] if accessed
  /// during a [dryRun].
  IOSSdk? get targetIOSSdk;

  /// When compiling for iOS, the lowest iOS version that the compiled code
  /// will be compatible with.
  ///
  /// Only available if [targetOS] is [OS.iOS]. Will throw a [StateError] if
  /// accessed otherwise.
  ///
  /// Not available during a [dryRun]. Will throw a [StateError] if accessed
  /// during a [dryRun].
  ///
  /// Corresponds to `-mios-version-min=<value>` for the Apple clang compiler.
  int? get targetIOSVersion;

  /// When compiling for MacOS, the lowest MacOS version that the compiled code
  /// will be compatible with.
  ///
  /// Only available if [targetOS] is [OS.macOS]. Will throw a [StateError] if
  /// accessed otherwise.
  ///
  /// Not available during a [dryRun]. Will throw a [StateError] if accessed
  /// during a [dryRun].
  ///
  /// Corresponds to `-mmacosx-version-min=<value>` for the Apple clang
  /// compiler.
  int? get targetMacOSVersion;

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

  /// The asset types that the invoker of this hook supports.
  ///
  /// Currently known values:
  /// * [CodeAsset.type]
  /// * [DataAsset.type]
  Iterable<String> get supportedAssetTypes;

  /// The preferred [LinkMode] method for [CodeAsset]s.
  LinkModePreference get linkModePreference;
}
