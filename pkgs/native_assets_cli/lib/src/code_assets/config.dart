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

/// Extension to the [HookConfig] providing access to configuration specific
/// to code assets (only available if code assets are supported).
extension CodeAssetHookConfig on HookConfig {
  /// Code asset specific configuration.
  CodeConfig get code => CodeConfig.fromJson(json);

  bool get buildCodeAssets => buildAssetTypes.contains(CodeAsset.type);
}

/// Extension to the [LinkInput] providing access to configuration specific to
/// code assets as well as code asset inputs to the linker (only available if
/// code assets are supported).
extension CodeAssetLinkInput on LinkInputAssets {
  // Returns the code assets that were sent to this linker.
  //
  // NOTE: If the linker implementation depends on the contents of the files the
  // code assets refer (e.g. looks at static archives and links them) then the
  // linker script has to add those files as dependencies via
  // [LinkOutput.addDependency] to ensure the linker script will be re-run if
  // the content of the files changes.
  Iterable<CodeAsset> get code => encodedAssets
      .where((e) => e.type == CodeAsset.type)
      .map(CodeAsset.fromEncoded);
}

/// Configuration for hook writers if code assets are supported.
class CodeConfig {
  final Architecture? _targetArchitecture;

  final LinkModePreference linkModePreference;

  /// A compiler toolchain able to target [targetOS] with [targetArchitecture].
  final CCompilerConfig? cCompiler;

  /// The operating system being compiled for.
  final OS targetOS;

  final IOSCodeConfig? _iOSConfig;
  final AndroidCodeConfig? _androidConfig;
  final MacOSCodeConfig? _macOSConfig;

  // Should not be made public, class will be replaced as a view on `json`.
  CodeConfig._({
    required Architecture? targetArchitecture,
    required this.targetOS,
    required this.linkModePreference,
    CCompilerConfig? cCompilerConfig,
    AndroidCodeConfig? androidConfig,
    IOSCodeConfig? iOSConfig,
    MacOSCodeConfig? macOSConfig,
  }) : _targetArchitecture = targetArchitecture,
       cCompiler = cCompilerConfig,
       _iOSConfig = iOSConfig,
       _androidConfig = androidConfig,
       _macOSConfig = macOSConfig;

  factory CodeConfig.fromJson(Map<String, Object?> json) {
    final dryRun = json.getOptional<bool>(_dryRunConfigKey) ?? false;

    final linkModePreference = LinkModePreference.fromString(
      json.code?.optionalString(_linkModePreferenceKey) ??
          json.string(_linkModePreferenceKey),
    );
    final targetArchitecture =
        dryRun
            ? null
            : Architecture.fromString(
              json.code?.optionalString(
                    _targetArchitectureKey,
                    validValues: Architecture.values.map((a) => a.name),
                  ) ??
                  json.string(
                    _targetArchitectureKey,
                    validValues: Architecture.values.map((a) => a.name),
                  ),
            );
    final targetOS = OS.fromString(
      json.code?.optionalString(_targetOSConfigKey) ??
          json.string(_targetOSConfigKey),
    );
    final cCompiler = switch (json.code?.optionalMap(_compilerKey)) {
      final Map<String, Object?> map => CCompilerConfig.fromJson(map),
      null => null,
    };

    final iOSConfig =
        dryRun || targetOS != OS.iOS ? null : IOSCodeConfig.fromJson(json);
    final androidConfig =
        dryRun || targetOS != OS.android
            ? null
            : AndroidCodeConfig.fromJson(json);
    final macOSConfig =
        dryRun || targetOS != OS.macOS ? null : MacOSCodeConfig.fromJson(json);

    return CodeConfig._(
      targetArchitecture: targetArchitecture,
      targetOS: targetOS,
      linkModePreference: linkModePreference,
      cCompilerConfig: cCompiler,
      iOSConfig: iOSConfig,
      androidConfig: androidConfig,
      macOSConfig: macOSConfig,
    );
  }

  /// The architecture the code code asset should be built for.
  ///
  /// The build and link hooks are invoked once per [targetArchitecture]. If the
  /// invoker produces multi-architecture applications, the invoker is
  /// responsible for combining the [CodeAsset]s for individual architectures
  /// into a universal binary. So, the build and link hook implementations are
  /// not responsible for providing universal binaries.
  Architecture get targetArchitecture {
    // TODO: Remove once Dart 3.7 stable is out and we bump the minimum SDK to
    // 3.7.
    if (_targetArchitecture == null) {
      throw StateError('Cannot access target architecture in dry runs.');
    }
    return _targetArchitecture;
  }

  /// Configuration provided when [CodeConfig.targetOS] is [OS.macOS].
  IOSCodeConfig get iOS => switch (_iOSConfig) {
    null =>
      throw StateError(
        'Cannot access iOSConfig if targetOS is not iOS'
        ' or in dry runs.',
      ),
    final c => c,
  };

  /// Configuration provided when [CodeConfig.targetOS] is [OS.android].
  AndroidCodeConfig get android => switch (_androidConfig) {
    null =>
      throw StateError(
        'Cannot access androidConfig if targetOS is not android'
        ' or in dry runs.',
      ),
    final c => c,
  };

  /// Configuration provided when [CodeConfig.targetOS] is [OS.macOS].
  MacOSCodeConfig get macOS => switch (_macOSConfig) {
    null =>
      throw StateError(
        'Cannot access macOSConfig if targetOS is not MacOS'
        ' or in dry runs.',
      ),
    final c => c,
  };
}

/// Configuration provided when [CodeConfig.targetOS] is [OS.iOS].
class IOSCodeConfig {
  /// Whether to target device or simulator.
  IOSSdk get targetSdk => _targetSdk!;

  final IOSSdk? _targetSdk;

  /// The lowest iOS version that the compiled code will be compatible with.
  int get targetVersion => _targetVersion!;

  final int? _targetVersion;

  IOSCodeConfig({required IOSSdk targetSdk, required int targetVersion})
    : _targetSdk = targetSdk,
      _targetVersion = targetVersion;

  IOSCodeConfig.fromJson(Map<String, Object?> json)
    : _targetVersion =
          json.code?.optionalMap(_iosKey)?.optionalInt(_targetVersionKey) ??
          json.optionalInt(_targetIOSVersionKeyDeprecated),
      _targetSdk = switch (json.code
              ?.optionalMap(_iosKey)
              ?.optionalString(_targetSdkKey) ??
          json.optionalString(_targetIOSSdkKeyDeprecated)) {
        null => null,
        String e => IOSSdk.fromString(e),
      };
}

extension IOSConfigSyntactic on IOSCodeConfig {
  IOSSdk? get targetSdkSyntactic => _targetSdk;
  int? get targetVersionSyntactic => _targetVersion;
}

/// Configuration provided when [CodeConfig.targetOS] is [OS.macOS].
class AndroidCodeConfig {
  /// The minimum Android SDK API version to that the compiled code will be
  /// compatible with.
  int get targetNdkApi => _targetNdkApi!;

  final int? _targetNdkApi;

  AndroidCodeConfig({required int targetNdkApi}) : _targetNdkApi = targetNdkApi;

  AndroidCodeConfig.fromJson(Map<String, Object?> json)
    : _targetNdkApi =
          json.code?.optionalMap(_androidKey)?.optionalInt(_targetNdkApiKey) ??
          json.optionalInt(_targetAndroidNdkApiKeyDeprecated);
}

extension AndroidConfigSyntactic on AndroidCodeConfig {
  int? get targetNdkApiSyntactic => _targetNdkApi;
}

//// Configuration provided when [CodeConfig.targetOS] is [OS.macOS].
class MacOSCodeConfig {
  /// The lowest MacOS version that the compiled code will be compatible with.
  int get targetVersion => _targetVersion!;

  final int? _targetVersion;

  MacOSCodeConfig({required int targetVersion})
    : _targetVersion = targetVersion;

  MacOSCodeConfig.fromJson(Map<String, Object?> json)
    : _targetVersion =
          json.code?.optionalMap(_macosKey)?.optionalInt(_targetVersionKey) ??
          json.optionalInt(_targetMacOSVersionKeyDeprecated);
}

extension MacOSConfigSyntactic on MacOSCodeConfig {
  int? get targetVersionSyntactic => _targetVersion;
}

/// Extension to the [BuildOutputBuilder] providing access to emitting code
/// assets (only available if code assets are supported).
extension CodeAssetBuildOutputBuilder on EncodedAssetBuildOutputBuilder {
  /// Provides access to emitting code assets.
  CodeAssetBuildOutputBuilderAdd get code =>
      CodeAssetBuildOutputBuilderAdd._(this);
}

/// Supports emitting code assets for build hooks.
extension type CodeAssetBuildOutputBuilderAdd._(
  EncodedAssetBuildOutputBuilder _output
) {
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
extension CodeAssetLinkOutputBuilder on EncodedAssetLinkOutputBuilder {
  /// Provides access to emitting code assets.
  CodeAssetLinkOutputBuilderAdd get code =>
      CodeAssetLinkOutputBuilderAdd._(this);
}

/// Extension on [LinkOutputBuilder] to emit code assets.
extension type CodeAssetLinkOutputBuilderAdd._(
  EncodedAssetLinkOutputBuilder _output
) {
  /// Adds the given [asset] to the link hook output.
  void add(CodeAsset asset) => _output.addEncodedAsset(asset.encode());

  /// Adds the given [assets] to the link hook output.
  void addAll(Iterable<CodeAsset> assets) => assets.forEach(add);
}

/// Extension to initialize code specific configuration on link/build inputs.
extension CodeAssetBuildInputBuilder on HookConfigBuilder {
  void setupCode({
    required Architecture? targetArchitecture,
    required OS targetOS,
    required LinkModePreference linkModePreference,
    CCompilerConfig? cCompiler,
    AndroidCodeConfig? android,
    IOSCodeConfig? iOS,
    MacOSCodeConfig? macOS,
  }) {
    if (targetArchitecture != null) {
      json[_targetArchitectureKey] = targetArchitecture.toString();
      json.setNested([
        _configKey,
        _codeKey,
        _targetArchitectureKey,
      ], targetArchitecture.toString());
    }
    json[_targetOSConfigKey] = targetOS.toString();
    json.setNested([
      _configKey,
      _codeKey,
      _targetOSConfigKey,
    ], targetOS.toString());
    json[_linkModePreferenceKey] = linkModePreference.toString();
    json.setNested([
      _configKey,
      _codeKey,
      _linkModePreferenceKey,
    ], linkModePreference.toString());
    if (cCompiler != null) {
      json.setNested([_configKey, _codeKey, _compilerKey], cCompiler.toJson());
    }

    // Note, using ?. instead of !. makes missing data be a semantic error
    // rather than a syntactic error to be caught in the validation.
    if (targetOS == OS.android) {
      json[_targetAndroidNdkApiKeyDeprecated] = android?.targetNdkApi;
      json.setNested([
        _configKey,
        _codeKey,
        _androidKey,
        _targetNdkApiKey,
      ], android?.targetNdkApi);
    } else if (targetOS == OS.iOS) {
      json[_targetIOSSdkKeyDeprecated] = iOS?.targetSdk.toString();
      json[_targetIOSVersionKeyDeprecated] = iOS?.targetVersion;
      json.setNested([
        _configKey,
        _codeKey,
        _iosKey,
        _targetSdkKey,
      ], iOS?.targetSdk.toString());
      json.setNested([
        _configKey,
        _codeKey,
        _iosKey,
        _targetVersionKey,
      ], iOS?.targetVersion);
    } else if (targetOS == OS.macOS) {
      json[_targetMacOSVersionKeyDeprecated] = macOS?.targetVersion;
      json.setNested([
        _configKey,
        _codeKey,
        _macosKey,
        _targetVersionKey,
      ], macOS?.targetVersion);
    }
  }
}

/// Provides access to [CodeAsset]s from a build hook output.
extension CodeAssetBuildOutput on BuildOutputAssets {
  /// The code assets emitted by the build hook.
  List<CodeAsset> get code =>
      encodedAssets
          .where((asset) => asset.type == CodeAsset.type)
          .map<CodeAsset>(CodeAsset.fromEncoded)
          .toList();
}

/// Provides access to [CodeAsset]s from a link hook output.
extension CodeAssetLinkOutput on LinkOutputAssets {
  /// The code assets emitted by the link hook.
  List<CodeAsset> get code =>
      encodedAssets
          .where((asset) => asset.type == CodeAsset.type)
          .map<CodeAsset>(CodeAsset.fromEncoded)
          .toList();
}

const String _compilerKey = 'c_compiler';
const String _linkModePreferenceKey = 'link_mode_preference';
const String _targetNdkApiKey = 'target_ndk_api';
const String _targetAndroidNdkApiKeyDeprecated = 'target_android_ndk_api';
const String _targetArchitectureKey = 'target_architecture';
const String _targetSdkKey = 'target_sdk';
const String _targetIOSSdkKeyDeprecated = 'target_ios_sdk';
const String _targetVersionKey = 'target_version';
const String _targetIOSVersionKeyDeprecated = 'target_ios_version';
const String _targetMacOSVersionKeyDeprecated = 'target_macos_version';
const String _targetOSConfigKey = 'target_os';

const _dryRunConfigKey = 'dry_run';

const _configKey = 'config';
const _codeKey = 'code';
const _androidKey = 'android';
const _iosKey = 'ios';
const _macosKey = 'macos';

extension on Map<String, Object?> {
  Map<String, Object?>? get code =>
      optionalMap(_configKey)?.optionalMap(_codeKey);
}
