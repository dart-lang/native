// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../config.dart';
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
  CodeConfig get codeConfig => CodeConfig.fromJson(json);
}

/// Extension to the [LinkConfig] providing access to configuration specific to
/// code assets as well as code asset inputs to the linker (only available if
/// code assets are supported).
extension CodeAssetLinkConfig on LinkConfig {
  /// Code asset specific configuration.
  CodeConfig get codeConfig => CodeConfig.fromJson(json);

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
  final CCompilerConfig? cCompiler;

  /// The operating system being compiled for.
  final OS targetOS;

  late final IOSConfig? _iOSConfig;
  late final AndroidConfig? _androidConfig;
  late final MacOSConfig? _macOSConfig;

  CodeConfig({
    required Architecture? targetArchitecture,
    required this.targetOS,
    required this.linkModePreference,
    CCompilerConfig? cCompilerConfig,
    AndroidConfig? androidConfig,
    IOSConfig? iOSConfig,
    MacOSConfig? macOSConfig,
  })  : _targetArchitecture = targetArchitecture,
        cCompiler = cCompilerConfig,
        _iOSConfig = iOSConfig,
        _androidConfig = androidConfig,
        _macOSConfig = macOSConfig;

  factory CodeConfig.fromJson(Map<String, Object?> json) {
    final dryRun = json.getOptional<bool>(_dryRunConfigKey) ?? false;

    final linkModePreference =
        LinkModePreference.fromString(json.string(_linkModePreferenceKey));
    final targetArchitecture = dryRun
        ? null
        : Architecture.fromString(json.string(_targetArchitectureKey,
            validValues: Architecture.values.map((a) => a.name)));
    final targetOS = OS.fromString(json.string(_targetOSConfigKey));
    final cCompiler = switch (json.optionalMap(_compilerKey)) {
      final Map<String, Object?> map => CCompilerConfig.fromJson(map),
      null => null
    };

    final iOSConfig =
        dryRun || targetOS != OS.iOS ? null : IOSConfig.fromJson(json);
    final androidConfig =
        dryRun || targetOS != OS.android ? null : AndroidConfig.fromJson(json);
    final macOSConfig =
        dryRun || targetOS != OS.macOS ? null : MacOSConfig.fromJson(json);

    return CodeConfig(
      targetArchitecture: targetArchitecture,
      targetOS: targetOS,
      linkModePreference: linkModePreference,
      cCompilerConfig: cCompiler,
      iOSConfig: iOSConfig,
      androidConfig: androidConfig,
      macOSConfig: macOSConfig,
    );
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
  IOSConfig get iOSConfig => switch (_iOSConfig) {
        null =>
          throw StateError('Cannot access iOSConfig if targetOS is not iOS'
              ' or in dry runs.'),
        final c => c,
      };

  /// Configuration provided when [CodeConfig.targetOS] is [OS.android].
  AndroidConfig get androidConfig => switch (_androidConfig) {
        null => throw StateError(
            'Cannot access androidConfig if targetOS is not android'
            ' or in dry runs.'),
        final c => c,
      };

  /// Configuration provided when [CodeConfig.targetOS] is [OS.macOS].
  MacOSConfig get macOSConfig => switch (_macOSConfig) {
        null =>
          throw StateError('Cannot access macOSConfig if targetOS is not MacOS'
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

  IOSConfig.fromJson(Map<String, Object?> json)
      : _targetVersion = json.optionalInt(_targetIOSVersionKey),
        _targetSdk = switch (json.optionalString(_targetIOSSdkKey)) {
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

  AndroidConfig.fromJson(Map<String, Object?> json)
      : _targetNdkApi = json.optionalInt(_targetAndroidNdkApiKey);
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

  MacOSConfig.fromJson(Map<String, Object?> json)
      : _targetVersion = json.optionalInt(_targetMacOSVersionKey);
}

extension MacOSConfigSyntactic on MacOSConfig {
  int? get targetVersionSyntactic => _targetVersion;
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
    required OS targetOS,
    required LinkModePreference linkModePreference,
    CCompilerConfig? cCompilerConfig,
    AndroidConfig? androidConfig,
    IOSConfig? iOSConfig,
    MacOSConfig? macOSConfig,
  }) {
    if (targetArchitecture != null) {
      json[_targetArchitectureKey] = targetArchitecture.toString();
    }
    json[_targetOSConfigKey] = targetOS.toString();
    json[_linkModePreferenceKey] = linkModePreference.toString();
    if (cCompilerConfig != null) {
      json[_compilerKey] = cCompilerConfig.toJson();
    }

    // Note, using ?. instead of !. makes missing data be a semantic error
    // rather than a syntactic error to be caught in the validation.
    if (targetOS == OS.android) {
      json[_targetAndroidNdkApiKey] = androidConfig?.targetNdkApi;
    } else if (targetOS == OS.iOS) {
      json[_targetIOSSdkKey] = iOSConfig?.targetSdk.toString();
      json[_targetIOSVersionKey] = iOSConfig?.targetVersion;
    } else if (targetOS == OS.macOS) {
      json[_targetMacOSVersionKey] = macOSConfig?.targetVersion;
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

const String _compilerKey = 'c_compiler';
const String _linkModePreferenceKey = 'link_mode_preference';
const String _targetAndroidNdkApiKey = 'target_android_ndk_api';
const String _targetArchitectureKey = 'target_architecture';
const String _targetIOSSdkKey = 'target_ios_sdk';
const String _targetIOSVersionKey = 'target_ios_version';
const String _targetMacOSVersionKey = 'target_macos_version';
const String _targetOSConfigKey = 'target_os';

const _dryRunConfigKey = 'dry_run';
