// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../config.dart';
import '../json_utils.dart';

import 'architecture.dart';
import 'build_mode.dart';
import 'c_compiler_config.dart';
import 'code_asset.dart';
import 'ios_sdk.dart';
import 'link_mode_preference.dart';

/// Extension to the [BuildConfig] providing access to configuration specific to
/// code assets (only available if code assets are supported).
extension CodeAssetBuildConfig on BuildConfig {
  /// Code asset specific configuration.
  CodeConfig get codeConfig => CodeConfig(this);
}

/// Extension to the [LinkConfig] providing access to configuration specific to
/// code assets as well as code asset inputs to the linker (only available if
/// code assets are supported).
extension CodeAssetLinkConfig on LinkConfig {
  /// Code asset specific configuration.
  CodeConfig get codeConfig => CodeConfig(this);

  // Returns the code assets that were sent to this linker.
  //
  // NOTE: If the linker implementation depends on the contents of the files the
  // code assets refer (e.g. looks at static archives and links them) then the
  // linker script has to add those files as dependencies via
  // [LinkOutput.addDependency] to ensure the linker script will be re-run if
  // the content of the files changes.
  Iterable<CodeAsset> get codeAssets => encodedAssets
      .where((e) => e.type == CodeAsset.type)
      .map(CodeAsset.fromEncoded);
}

/// Configuration for hook writers if code assets are supported.
class CodeConfig {
  final Architecture? _targetArchitecture;

  final LinkModePreference linkModePreference;
  final CCompilerConfig cCompiler;
  final int? targetIOSVersion;
  final int? targetMacOSVersion;
  final int? targetAndroidNdkApi;
  final IOSSdk? targetIOSSdk;
  final BuildMode? _buildMode;

  CodeConfig(HookConfig config)
      : linkModePreference = LinkModePreference.fromString(
            config.json.string(_linkModePreferenceKey)),
        // ignore: deprecated_member_use_from_same_package
        _targetArchitecture = (config is BuildConfig && config.dryRun)
            ? null
            : Architecture.fromString(config.json.string(_targetArchitectureKey,
                validValues: Architecture.values.map((a) => a.name))),
        cCompiler = switch (config.json.optionalMap(_compilerKey)) {
          final Map<String, Object?> map => CCompilerConfig.fromJson(map),
          null => CCompilerConfig(),
        },
        targetIOSVersion = config.json.optionalInt(_targetIOSVersionKey),
        targetMacOSVersion = config.json.optionalInt(_targetMacOSVersionKey),
        targetAndroidNdkApi = config.json.optionalInt(_targetAndroidNdkApiKey),
        targetIOSSdk = switch (config.json.optionalString(_targetIOSSdkKey)) {
          final String value => IOSSdk.fromString(value),
          null => null,
        },
        _buildMode = switch (config.json.optionalString(_buildModeConfigKey)) {
          String value => BuildMode.fromString(value),
          null => null,
        };

  Architecture get targetArchitecture {
    if (_targetArchitecture == null) {
      throw StateError('Cannot access target architecture in dry runs');
    }
    return _targetArchitecture;
  }

  /// The [BuildMode] that the code should be compiled in.
  ///
  /// Currently [BuildMode.debug] and [BuildMode.release] are the only modes.
  ///
  /// Not available during a dry run.
  BuildMode get buildMode {
    if (_buildMode == null) {
      throw StateError('Build mode should not be accessed in dry-run mode.');
    }
    return _buildMode;
  }
}

/// Extension to the [BuildOutputBuilder] providing access to emitting code
/// assets (only available if code assets are supported).
extension CodeAssetBuildOutputBuilder on BuildOutputBuilder {
  /// Provides access to emitting code assets.
  CodeAssetBuildOutputBuilderAdd get codeAssets =>
      CodeAssetBuildOutputBuilderAdd._(this);
}

/// Supports emitting code assets for build hooks.
extension type CodeAssetBuildOutputBuilderAdd._(BuildOutputBuilder _output) {
  /// Adds the given [asset] to the hook output (or send to [linkInPackage]
  /// for linking if provided).
  void add(CodeAsset asset, {String? linkInPackage}) =>
      _output.addEncodedAsset(asset.encode(), linkInPackage: linkInPackage);

  /// Adds the given [assets] to the hook output (or send to [linkInPackage]
  /// for linking if provided).
  void addAll(Iterable<CodeAsset> assets, {String? linkInPackage}) {
    for (final asset in assets) {
      add(asset, linkInPackage: linkInPackage);
    }
  }
}

/// Extension to the [LinkOutputBuilder] providing access to emitting code
/// assets (only available if code assets are supported).
extension CodeAssetLinkOutputBuilder on LinkOutputBuilder {
  /// Provides access to emitting code assets.
  CodeAssetLinkOutputBuilderAdd get codeAssets =>
      CodeAssetLinkOutputBuilderAdd._(this);
}

/// Extension on [LinkOutputBuilder] to emit code assets.
extension type CodeAssetLinkOutputBuilderAdd._(LinkOutputBuilder _output) {
  /// Adds the given [asset] to the link hook output.
  void add(CodeAsset asset) => _output.addEncodedAsset(asset.encode());

  /// Adds the given [assets] to the link hook output.
  void addAll(Iterable<CodeAsset> assets) => assets.forEach(add);
}

/// Extension to initialize code specific configuration on link/build configs.
extension CodeAssetBuildConfigBuilder on HookConfigBuilder {
  void setupCodeConfig({
    required Architecture? targetArchitecture,
    required LinkModePreference linkModePreference,
    CCompilerConfig? cCompilerConfig,
    int? targetIOSVersion,
    int? targetMacOSVersion,
    int? targetAndroidNdkApi,
    IOSSdk? targetIOSSdk,
    required BuildMode? buildMode,
  }) {
    if (targetArchitecture != null) {
      json[_targetArchitectureKey] = targetArchitecture.toString();
    }
    json[_linkModePreferenceKey] = linkModePreference.toString();
    if (cCompilerConfig != null) {
      json[_compilerKey] = cCompilerConfig.toJson();
    }

    if (targetIOSVersion != null) {
      json[_targetIOSVersionKey] = targetIOSVersion;
    }
    if (targetMacOSVersion != null) {
      json[_targetMacOSVersionKey] = targetMacOSVersion;
    }
    if (targetAndroidNdkApi != null) {
      json[_targetAndroidNdkApiKey] = targetAndroidNdkApi;
    }
    if (targetIOSSdk != null) {
      json[_targetIOSSdkKey] = targetIOSSdk.toString();
    }
    if (buildMode != null) {
      json[_buildModeConfigKey] = buildMode.toString();
    }
  }
}

/// Provides access to [CodeAsset]s from a build hook output.
extension CodeAssetBuildOutput on BuildOutput {
  /// The code assets emitted by the build hook.
  List<CodeAsset> get codeAssets => encodedAssets
      .where((asset) => asset.type == CodeAsset.type)
      .map<CodeAsset>(CodeAsset.fromEncoded)
      .toList();
}

/// Provides access to [CodeAsset]s from a link hook output.
extension CodeAssetLinkOutput on LinkOutput {
  /// The code assets emitted by the link hook.
  List<CodeAsset> get codeAssets => encodedAssets
      .where((asset) => asset.type == CodeAsset.type)
      .map<CodeAsset>(CodeAsset.fromEncoded)
      .toList();
}

const _buildModeConfigKey = 'build_mode';
const String _compilerKey = 'c_compiler';
const String _targetArchitectureKey = 'target_architecture';
const String _targetIOSSdkKey = 'target_ios_sdk';
const String _linkModePreferenceKey = 'link_mode_preference';
const String _targetIOSVersionKey = 'target_ios_version';
const String _targetMacOSVersionKey = 'target_macos_version';
const String _targetAndroidNdkApiKey = 'target_android_ndk_api';
