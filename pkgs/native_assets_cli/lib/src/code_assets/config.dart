// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../config.dart';
import '../encoded_asset.dart';
import '../json_utils.dart';
import 'architecture.dart';
import 'c_compiler_config.dart';
import 'code_asset.dart';
import 'ios_sdk.dart';
import 'link_mode_preference.dart';
import 'os.dart';

/// Extension to the [BuildConfig] providing access to configuration specific to
/// code assets (only available if code assets are supported).
extension CodeAssetBuildConfig on BuildConfig {
  /// Code asset specific configuration.
  CodeConfig get code => CodeConfig(this);
}

/// Extension to the [LinkConfig] providing access to configuration specific to
/// code assets as well as code asset inputs to the linker (only available if
/// code assets are supported).
extension CodeAssetLinkConfig on LinkConfig {
  /// Code asset specific configuration.
  CodeConfig get code => CodeConfig(this);
}

extension CodeAssetEncodedAsset on Iterable<EncodedAsset> {
  // Returns the code assets in this iterable.
  Iterable<CodeAsset> get code =>
      where((e) => e.type == CodeAsset.type).map(CodeAsset.fromEncoded);
}

/// Configuration for hook writers if code assets are supported.
class CodeConfig {
  final Architecture? _targetArchitecture;

  final LinkModePreference linkModePreference;
  final CCompilerConfig? cCompiler;

  /// The operating system being compiled for.
  final OS targetOS;

  late final IOSConfig? _iOSConfig;
  late final AndroidConfig? _androidConfig;
  late final MacOSConfig? _macOSConfig;

  CodeConfig(HookConfig config)
      : linkModePreference = LinkModePreference.fromString(
            config.json.string(_linkModePreferenceKey)),
        // ignore: deprecated_member_use_from_same_package
        _targetArchitecture = (config is BuildConfig && config.dryRun)
            ? null
            : Architecture.fromString(config.json.string(_targetArchitectureKey,
                validValues: Architecture.values.map((a) => a.name))),
        targetOS = OS.fromString(config.json.string(_targetOSConfigKey)),
        cCompiler = switch (config.json.optionalMap(_compilerKey)) {
          final Map<String, Object?> map => CCompilerConfig.fromJson(map),
          null => null,
        } {
    // ignore: deprecated_member_use_from_same_package
    _iOSConfig = (config is BuildConfig && config.dryRun) || targetOS != OS.iOS
        ? null
        : IOSConfig.fromHookConfig(config);
    _androidConfig =
        // ignore: deprecated_member_use_from_same_package
        (config is BuildConfig && config.dryRun) || targetOS != OS.android
            ? null
            : AndroidConfig.fromHookConfig(config);
    _macOSConfig =
        // ignore: deprecated_member_use_from_same_package
        (config is BuildConfig && config.dryRun) || targetOS != OS.macOS
            ? null
            : MacOSConfig.fromHookConfig(config);
  }

  Architecture get targetArchitecture {
    // TODO: Remove once Dart 3.7 stable is out and we bump the minimum SDK to
    // 3.7.
    if (_targetArchitecture == null) {
      throw StateError('Cannot access target architecture in dry runs.');
    }
    return _targetArchitecture;
  }

  /// Configuration provided when [CodeConfig.targetOS] is [OS.macOS].
  IOSConfig get iOS => switch (_iOSConfig) {
        null => throw StateError('Cannot access iOS if targetOS is not iOS'
            ' or in dry runs.'),
        final c => c,
      };

  /// Configuration provided when [CodeConfig.targetOS] is [OS.android].
  AndroidConfig get android => switch (_androidConfig) {
        null =>
          throw StateError('Cannot access android if targetOS is not android'
              ' or in dry runs.'),
        final c => c,
      };

  /// Configuration provided when [CodeConfig.targetOS] is [OS.macOS].
  MacOSConfig get macOS => switch (_macOSConfig) {
        null => throw StateError('Cannot access macOS if targetOS is not MacOS'
            ' or in dry runs.'),
        final c => c,
      };
}

/// Configuration provided when [CodeConfig.targetOS] is [OS.iOS].
class IOSConfig {
  /// Whether to target device or simulator.
  IOSSdk get targetSdk => _targetSdk!;

  final IOSSdk? _targetSdk;

  /// The lowest iOS version that the compiled code will be compatible with.
  int get targetVersion => _targetVersion!;

  final int? _targetVersion;

  IOSConfig({
    required IOSSdk targetSdk,
    required int targetVersion,
  })  : _targetSdk = targetSdk,
        _targetVersion = targetVersion;

  IOSConfig.fromHookConfig(HookConfig config)
      : _targetVersion = config.json.optionalInt(_targetIOSVersionKey),
        _targetSdk = switch (config.json.optionalString(_targetIOSSdkKey)) {
          null => null,
          String e => IOSSdk.fromString(e)
        };
}

extension IOSConfigSyntactic on IOSConfig {
  IOSSdk? get targetSdkSyntactic => _targetSdk;
  int? get targetVersionSyntactic => _targetVersion;
}

/// Configuration provided when [CodeConfig.targetOS] is [OS.macOS].
class AndroidConfig {
  /// The minimum Android SDK API version to that the compiled code will be
  /// compatible with.
  int get targetNdkApi => _targetNdkApi!;

  final int? _targetNdkApi;

  AndroidConfig({
    required int targetNdkApi,
  }) : _targetNdkApi = targetNdkApi;

  AndroidConfig.fromHookConfig(HookConfig config)
      : _targetNdkApi = config.json.optionalInt(_targetAndroidNdkApiKey);
}

extension AndroidConfigSyntactic on AndroidConfig {
  int? get targetNdkApiSyntactic => _targetNdkApi;
}

//// Configuration provided when [CodeConfig.targetOS] is [OS.macOS].
class MacOSConfig {
  /// The lowest MacOS version that the compiled code will be compatible with.
  int get targetVersion => _targetVersion!;

  final int? _targetVersion;

  MacOSConfig({
    required int targetVersion,
  }) : _targetVersion = targetVersion;

  MacOSConfig.fromHookConfig(HookConfig config)
      : _targetVersion = config.json.optionalInt(_targetMacOSVersionKey);
}

extension MacOSConfigSyntactic on MacOSConfig {
  int? get targetVersionSyntactic => _targetVersion;
}

/// Extension to the [BuildOutputBuilder] providing access to emitting code
/// assets (only available if code assets are supported).
extension CodeAssetBuildOutputBuilder on BuildOutputBuilder {
  /// Provides access to emitting code assets.
  CodeAssetBuildOutputBuilderAdd get code =>
      CodeAssetBuildOutputBuilderAdd._(this);
}

/// Supports emitting code assets for build hooks.
extension type CodeAssetBuildOutputBuilderAdd._(BuildOutputBuilder _output) {
  /// Adds the given [asset] to the hook output (or send to [linkInPackage]
  /// for linking if provided).
  void addAsset(CodeAsset asset, {String? linkInPackage}) =>
      _output.addEncodedAsset(asset.encode(), linkInPackage: linkInPackage);

  /// Adds the given [assets] to the hook output (or send to [linkInPackage]
  /// for linking if provided).
  void addAssets(Iterable<CodeAsset> assets, {String? linkInPackage}) {
    for (final asset in assets) {
      addAsset(asset, linkInPackage: linkInPackage);
    }
  }
}

/// Extension to the [LinkOutputBuilder] providing access to emitting code
/// assets (only available if code assets are supported).
extension CodeAssetLinkOutputBuilder on LinkOutputBuilder {
  /// Provides access to emitting code assets.
  CodeAssetLinkOutputBuilderAdd get code =>
      CodeAssetLinkOutputBuilderAdd._(this);
}

/// Extension on [LinkOutputBuilder] to emit code assets.
extension type CodeAssetLinkOutputBuilderAdd._(LinkOutputBuilder _output) {
  /// Adds the given [asset] to the link hook output.
  void addAsset(CodeAsset asset) => _output.addEncodedAsset(asset.encode());

  /// Adds the given [assets] to the link hook output.
  void addAssets(Iterable<CodeAsset> assets) => assets.forEach(addAsset);
}

/// Extension to initialize code specific configuration on link/build configs.
extension CodeAssetBuildConfigBuilder on HookConfigBuilder {
  void setupCode({
    required Architecture? targetArchitecture,
    required OS targetOS,
    required LinkModePreference linkModePreference,
    CCompilerConfig? cCompiler,
    AndroidConfig? android,
    IOSConfig? iOS,
    MacOSConfig? macOS,
  }) {
    if (targetArchitecture != null) {
      json[_targetArchitectureKey] = targetArchitecture.toString();
    }
    json[_targetOSConfigKey] = targetOS.toString();
    json[_linkModePreferenceKey] = linkModePreference.toString();
    if (cCompiler != null) {
      json[_compilerKey] = cCompiler.toJson();
    }

    // Note, using ?. instead of !. makes missing data be a semantic error
    // rather than a syntactic error to be caught in the validation.
    if (targetOS == OS.android) {
      json[_targetAndroidNdkApiKey] = android?.targetNdkApi;
    } else if (targetOS == OS.iOS) {
      json[_targetIOSSdkKey] = iOS?.targetSdk.toString();
      json[_targetIOSVersionKey] = iOS?.targetVersion;
    } else if (targetOS == OS.macOS) {
      json[_targetMacOSVersionKey] = macOS?.targetVersion;
    }
  }
}

const String _compilerKey = 'c_compiler';
const String _linkModePreferenceKey = 'link_mode_preference';
const String _targetAndroidNdkApiKey = 'target_android_ndk_api';
const String _targetArchitectureKey = 'target_architecture';
const String _targetIOSSdkKey = 'target_ios_sdk';
const String _targetIOSVersionKey = 'target_ios_version';
const String _targetMacOSVersionKey = 'target_macos_version';
const String _targetOSConfigKey = 'target_os';
