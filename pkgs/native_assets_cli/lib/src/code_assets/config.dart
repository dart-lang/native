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
  final CCompilerConfig? cCompiler;

  /// The operating system being compiled for.
  final OS targetOS;

  late final IOSConfig? _iOSConfig;
  late final AndroidConfig? _androidConfig;
  late final MacOSConfig? _macOSConfig;

  CodeConfig(HookConfig config)
      : linkModePreference = LinkModePreference.fromString(
            config.json.string(linkModePreferenceKey)),
        // ignore: deprecated_member_use_from_same_package
        _targetArchitecture = (config is BuildConfig && config.dryRun)
            ? null
            : Architecture.fromString(config.json.string(targetArchitectureKey,
                validValues: Architecture.values.map((a) => a.name))),
        targetOS = OS.fromString(config.json.string(targetOSConfigKey)),
        cCompiler = switch (config.json.optionalMap(compilerKey)) {
          final Map<String, Object?> map => CCompilerConfig.fromJson(map),
          null => null,
        } {
    // ignore: deprecated_member_use_from_same_package
    _iOSConfig = (config is BuildConfig && config.dryRun)
        ? null
        : targetOS == OS.iOS
            ? IOSConfig.fromHookConfig(config)
            : null;
    // ignore: deprecated_member_use_from_same_package
    _androidConfig = (config is BuildConfig && config.dryRun)
        ? null
        : targetOS == OS.android
            ? AndroidConfig.fromHookConfig(config)
            : null;
    // ignore: deprecated_member_use_from_same_package
    _macOSConfig = (config is BuildConfig && config.dryRun)
        ? null
        : targetOS == OS.macOS
            ? MacOSConfig.fromHookConfig(config)
            : null;
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
  final IOSSdk targetSdk;

  /// The lowest iOS version that the compiled code will be compatible with.
  final int targetVersion;

  IOSConfig({
    required this.targetSdk,
    required this.targetVersion,
  });

  IOSConfig.fromHookConfig(HookConfig config)
      : targetVersion = config.json.int(targetIOSVersionKey),
        targetSdk = IOSSdk.fromString(config.json.string(targetIOSSdkKey));
}

/// Configuration provided when [CodeConfig.targetOS] is [OS.macOS].
class AndroidConfig {
  /// The minimum Android SDK API version to that the compiled code will be
  /// compatible with.
  final int targetNdkApi;

  AndroidConfig({
    required this.targetNdkApi,
  });

  AndroidConfig.fromHookConfig(HookConfig config)
      : targetNdkApi = config.json.int(targetAndroidNdkApiKey);
}

//// Configuration provided when [CodeConfig.targetOS] is [OS.macOS].
class MacOSConfig {
  /// The lowest MacOS version that the compiled code will be compatible with.
  final int targetVersion;

  MacOSConfig({
    required this.targetVersion,
  });

  MacOSConfig.fromHookConfig(HookConfig config)
      : targetVersion = config.json.int(targetMacOSVersionKey);
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
      json[targetArchitectureKey] = targetArchitecture.toString();
    }
    json[targetOSConfigKey] = targetOS.toString();
    json[linkModePreferenceKey] = linkModePreference.toString();
    if (cCompilerConfig != null) {
      json[compilerKey] = cCompilerConfig.toJson();
    }

    // Note, using ?. instead of !. enables using this in tests to write wrong
    // invalid configs. Is this a good idea? The setup methods only create the
    // JSON now, but don't enable creating all forms of wrong JSON. For example
    // `IOSConfig` either has both fields or none.
    // Maybe the builders should be more construct by construction, and the
    // validator tests should be on the JSON. This requires duplicating JSON
    // serialization logic in the tests though.
    // This PR already duplicates deserialization logic in the validator and
    // `Config`s. The configs classes need to provide non-nullable accessors, so
    // they cannot be used inside the validators to check for invalid null
    // values.
    if (targetOS == OS.android) {
      json[targetAndroidNdkApiKey] = androidConfig?.targetNdkApi;
    } else if (targetOS == OS.iOS) {
      json[targetIOSSdkKey] = iOSConfig?.targetSdk.toString();
      json[targetIOSVersionKey] = iOSConfig?.targetVersion;
    } else if (targetOS == OS.macOS) {
      json[targetMacOSVersionKey] = macOSConfig?.targetVersion;
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

const String compilerKey = 'c_compiler';
const String linkModePreferenceKey = 'link_mode_preference';
const String targetAndroidNdkApiKey = 'target_android_ndk_api';
const String targetArchitectureKey = 'target_architecture';
const String targetIOSSdkKey = 'target_ios_sdk';
const String targetIOSVersionKey = 'target_ios_version';
const String targetMacOSVersionKey = 'target_macos_version';
const String targetOSConfigKey = 'target_os';
