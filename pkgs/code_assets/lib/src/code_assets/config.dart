// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:hooks/hooks.dart';

import 'architecture.dart';
import 'c_compiler_config.dart';
import 'code_asset.dart';
import 'ios_sdk.dart';
import 'link_mode_preference.dart';
import 'os.dart';
import 'syntax.g.dart';

/// Extension to the [HookConfig] providing access to configuration specific
/// to code assets (only available if code assets are supported).
extension HookConfigCodeConfig on HookConfig {
  /// Code asset specific configuration.
  ///
  /// Only available if [buildCodeAssets] is true.
  CodeConfig get code => CodeConfig._fromJson(json, path);

  /// Whether the hook invoker (e.g. the Dart or Flutter SDK) expects this
  /// hook to build code assets.
  bool get buildCodeAssets => buildAssetTypes.contains(CodeAssetType.type);
}

/// Extension to the [LinkInput] providing access to configuration specific to
/// code assets as well as code asset inputs to the linker (only available if
/// code assets are supported).
extension LinkInputCodeAssets on LinkInputAssets {
  /// The [CodeAsset]s in this [LinkInputAssets.encodedAssets].
  ///
  /// Only available if [HookConfigCodeConfig.buildCodeAssets] is true.
  ///
  /// NOTE: If the linker implementation depends on the contents of the files
  /// the code assets refer (e.g. looks at static archives and links them) then
  /// the linker script has to add those files as dependencies via
  /// [HookOutputBuilder.dependencies] to ensure the linker script will be
  /// re-run if the content of the files changes.
  Iterable<CodeAsset> get code =>
      encodedAssets.where((e) => e.isCodeAsset).map(CodeAsset.fromEncoded);
}

/// The configuration for [CodeAsset]s in [HookConfig].
///
/// Available via [HookConfigCodeConfig.code].
final class CodeConfig {
  final CodeConfigSyntax _syntax;

  CodeConfig._fromJson(Map<String, Object?> json, List<Object> path)
    : _syntax = ConfigSyntax.fromJson(json, path: path).extensions!.codeAssets!;

  /// The architecture the code code asset should be built for.
  ///
  /// The build and link hooks are invoked once per [targetArchitecture]. If the
  /// invoker produces multi-architecture applications, the invoker is
  /// responsible for combining the [CodeAsset]s for individual architectures
  /// into a universal binary. So, the build and link hook implementations are
  /// not responsible for providing universal binaries.
  Architecture get targetArchitecture =>
      ArchitectureSyntaxExtension.fromSyntax(_syntax.targetArchitecture);

  /// The preferred link for [CodeAsset]s.
  LinkModePreference get linkModePreference =>
      LinkModePreferenceSyntaxExtension.fromSyntax(_syntax.linkModePreference);

  /// A compiler toolchain able to target [targetOS] with [targetArchitecture].
  CCompilerConfig? get cCompiler => switch (_syntax.cCompiler) {
    null => null,
    final c => CCompilerConfigSyntaxExtension.fromSyntax(c),
  };

  /// The operating system being compiled for.
  OS get targetOS => OSSyntaxExtension.fromSyntax(_syntax.targetOs);

  /// Configuration provided when [CodeConfig.targetOS] is [OS.macOS].
  IOSCodeConfig get iOS => switch (_syntax.iOS) {
    null => throw StateError('Cannot access iOSConfig if targetOS is not iOS.'),
    final c => IOSCodeConfig._(c),
  };

  /// Configuration provided when [CodeConfig.targetOS] is [OS.android].
  AndroidCodeConfig get android => switch (_syntax.android) {
    null => throw StateError(
      'Cannot access androidConfig if targetOS is not android.',
    ),
    final c => AndroidCodeConfig._(c),
  };

  /// Configuration provided when [CodeConfig.targetOS] is [OS.macOS].
  MacOSCodeConfig get macOS => switch (_syntax.macOS) {
    null => throw StateError(
      'Cannot access macOSConfig if targetOS is not MacOS.',
    ),
    final c => MacOSCodeConfig._(c),
  };
}

/// The configuration for [CodeAsset]s for target OS [OS.iOS] in
/// [CodeConfig.iOS].
final class IOSCodeConfig {
  final IOSCodeConfigSyntax _syntax;

  IOSCodeConfig._(this._syntax);

  /// Whether to target device or simulator.
  IOSSdk get targetSdk => IOSSdk.fromString(_syntax.targetSdk);

  /// The lowest iOS version that the compiled code will be compatible with.
  int get targetVersion => _syntax.targetVersion;

  /// Constructs a new [IOSCodeConfig].
  IOSCodeConfig({required IOSSdk targetSdk, required int targetVersion})
    : _syntax = IOSCodeConfigSyntax(
        targetSdk: targetSdk.type,
        targetVersion: targetVersion,
      );
}

/// The configuration for [CodeAsset]s for target OS [OS.android] in
/// [CodeConfig.android].
final class AndroidCodeConfig {
  final AndroidCodeConfigSyntax _syntax;

  AndroidCodeConfig._(this._syntax);

  /// The minimum Android SDK API version to that the compiled code will be
  /// compatible with.
  int get targetNdkApi => _syntax.targetNdkApi;

  /// Constructs a new [AndroidCodeConfig].
  AndroidCodeConfig({required int targetNdkApi})
    : _syntax = AndroidCodeConfigSyntax(targetNdkApi: targetNdkApi);
}

/// The configuration for [CodeAsset]s for target OS [OS.macOS] in
/// [CodeConfig.macOS].
final class MacOSCodeConfig {
  final MacOSCodeConfigSyntax _syntax;

  MacOSCodeConfig._(this._syntax);

  /// The lowest MacOS version that the compiled code will be compatible with.
  int get targetVersion => _syntax.targetVersion;

  /// Constructs a new [MacOSCodeConfig].
  MacOSCodeConfig({required int targetVersion})
    : _syntax = MacOSCodeConfigSyntax(targetVersion: targetVersion);
}

/// Extension on [BuildOutputBuilder] to add [CodeAsset]s.
extension BuildOutputAssetsBuilderCode on BuildOutputAssetsBuilder {
  /// Provides access to emitting code assets.
  ///
  /// Should only be used if [HookConfigCodeConfig.buildCodeAssets] is true.
  BuildOutputCodeAssetBuilder get code => BuildOutputCodeAssetBuilder._(this);
}

/// Extension on [BuildOutputBuilder] to add [CodeAsset]s.
final class BuildOutputCodeAssetBuilder {
  /// Provides access to emitting code assets.
  final BuildOutputAssetsBuilder _output;

  BuildOutputCodeAssetBuilder._(this._output);

  /// Adds the given [asset] to the hook output with [routing].
  void add(CodeAsset asset, {AssetRouting routing = const ToAppBundle()}) =>
      _output.addEncodedAsset(asset.encode(), routing: routing);

  /// Adds the given [assets] to the hook output with [routing].
  void addAll(
    Iterable<CodeAsset> assets, {
    AssetRouting routing = const ToAppBundle(),
  }) {
    for (final asset in assets) {
      add(asset, routing: routing);
    }
  }
}

/// Extension on [LinkOutputBuilder] to add [CodeAsset]s.
extension LinkOutputAssetsBuilderCode on LinkOutputAssetsBuilder {
  /// Provides access to emitting code assets.
  LinkOutputCodeAssetBuilder get code => LinkOutputCodeAssetBuilder._(this);
}

/// Extension on [LinkOutputBuilder] to add [CodeAsset]s.
final class LinkOutputCodeAssetBuilder {
  final LinkOutputAssetsBuilder _output;

  LinkOutputCodeAssetBuilder._(this._output);

  /// Adds the given [asset] to the hook output with [routing].
  void add(CodeAsset asset, {LinkAssetRouting routing = const ToAppBundle()}) =>
      _output.addEncodedAsset(asset.encode(), routing: routing);

  /// Adds the given [assets] to the hook output with [routing].
  void addAll(
    Iterable<CodeAsset> assets, {
    LinkAssetRouting routing = const ToAppBundle(),
  }) {
    for (final asset in assets) {
      add(asset, routing: routing);
    }
  }
}

/// Extension to initialize code specific configuration on link/build inputs.
extension CodeAssetBuildInputBuilder on HookConfigBuilder {
  /// Sets up the code asset specific configuration for a build or link hook
  /// input.
  void setupCode({
    required Architecture targetArchitecture,
    required OS targetOS,
    required LinkModePreference linkModePreference,
    CCompilerConfig? cCompiler,
    AndroidCodeConfig? android,
    IOSCodeConfig? iOS,
    MacOSCodeConfig? macOS,
  }) {
    final codeConfig = CodeConfigSyntax(
      linkModePreference: linkModePreference.toSyntax(),
      targetArchitecture: targetArchitecture.toSyntax(),
      targetOs: targetOS.toSyntax(),
      cCompiler: cCompiler?.toSyntax(),
      android: android?.toSyntax(),
      iOS: iOS?.toSyntax(),
      macOS: macOS?.toSyntax(),
    );
    final baseHookConfig = ConfigSyntax.fromJson(json);
    baseHookConfig.extensions ??= ConfigExtensionsSyntax.fromJson({});
    final hookConfig = ConfigSyntax.fromJson(baseHookConfig.json);
    hookConfig.extensions!.codeAssets = codeConfig;
  }
}

/// The [CodeAsset]s in [BuildOutputAssets.encodedAssets].
// TODO: Add access to assetsForBuild or assetsForLinking.
extension BuildOutputCodeAssets on BuildOutputAssets {
  /// The [CodeAsset]s in this [BuildOutputAssets.encodedAssets].
  List<CodeAsset> get code => encodedAssets
      .where((asset) => asset.isCodeAsset)
      .map(CodeAsset.fromEncoded)
      .toList();
}

/// The [CodeAsset]s in [LinkOutputAssets.encodedAssets].
extension LinkOutputCodeAssets on LinkOutputAssets {
  /// The [CodeAsset]s in this [LinkOutputAssets.encodedAssets].
  List<CodeAsset> get code => encodedAssets
      .where((asset) => asset.isCodeAsset)
      .map(CodeAsset.fromEncoded)
      .toList();
}

/// Extension methods for [MacOSCodeConfig] to convert to and from the syntax
/// model.
extension MacOSCodeConfigSyntaxExtension on MacOSCodeConfig {
  /// Converts this [MacOSCodeConfig] to its corresponding
  /// [MacOSCodeConfigSyntax].
  MacOSCodeConfigSyntax toSyntax() =>
      MacOSCodeConfigSyntax(targetVersion: targetVersion);
}

/// Extension methods for [IOSCodeConfig] to convert to and from the syntax
/// model.
extension IOSCodeConfigSyntaxExtension on IOSCodeConfig {
  /// Converts this [IOSCodeConfig] to its corresponding [IOSCodeConfigSyntax].
  IOSCodeConfigSyntax toSyntax() => IOSCodeConfigSyntax(
    targetSdk: targetSdk.type,
    targetVersion: targetVersion,
  );
}

/// Extension methods for [AndroidCodeConfig] to convert to and from the syntax
/// model.
extension AndroidCodeConfigSyntaxExtension on AndroidCodeConfig {
  /// Converts this [AndroidCodeConfig] to its corresponding
  /// [AndroidCodeConfigSyntax].
  AndroidCodeConfigSyntax toSyntax() =>
      AndroidCodeConfigSyntax(targetNdkApi: targetNdkApi);
}
