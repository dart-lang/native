// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../config.dart';
import '../hook/syntax.g.dart' as hook_syntax;
import 'architecture.dart';
import 'c_compiler_config.dart';
import 'code_asset.dart';
import 'ios_sdk.dart';
import 'link_mode_preference.dart';
import 'os.dart';
import 'syntax.g.dart' as syntax;

/// Extension to the [HookConfig] providing access to configuration specific
/// to code assets (only available if code assets are supported).
extension CodeAssetHookConfig on HookConfig {
  /// Code asset specific configuration.
  CodeConfig get code => CodeConfig._fromJson(json);

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
  final syntax.CodeConfig _syntax;

  CodeConfig._fromJson(Map<String, Object?> json)
    : _syntax = syntax.Config.fromJson(json).code!;

  /// The architecture the code code asset should be built for.
  ///
  /// The build and link hooks are invoked once per [targetArchitecture]. If the
  /// invoker produces multi-architecture applications, the invoker is
  /// responsible for combining the [CodeAsset]s for individual architectures
  /// into a universal binary. So, the build and link hook implementations are
  /// not responsible for providing universal binaries.
  Architecture get targetArchitecture =>
      ArchitectureSyntax.fromSyntax(_syntax.targetArchitecture);

  LinkModePreference get linkModePreference =>
      LinkModePreferenceSyntax.fromSyntax(_syntax.linkModePreference);

  /// A compiler toolchain able to target [targetOS] with [targetArchitecture].
  CCompilerConfig? get cCompiler => switch (_syntax.cCompiler) {
    null => null,
    final c => CCompilerConfigSyntax.fromSyntax(c),
  };

  /// The operating system being compiled for.
  OS get targetOS => OSSyntax.fromSyntax(_syntax.targetOs);

  /// Configuration provided when [CodeConfig.targetOS] is [OS.macOS].
  IOSCodeConfig get iOS => switch (_syntax.iOS) {
    null => throw StateError('Cannot access iOSConfig if targetOS is not iOS.'),
    final c => IOSCodeConfig._(c),
  };

  /// Configuration provided when [CodeConfig.targetOS] is [OS.android].
  AndroidCodeConfig get android => switch (_syntax.android) {
    null =>
      throw StateError(
        'Cannot access androidConfig if targetOS is not android.',
      ),
    final c => AndroidCodeConfig._(c),
  };

  /// Configuration provided when [CodeConfig.targetOS] is [OS.macOS].
  MacOSCodeConfig get macOS => switch (_syntax.macOS) {
    null =>
      throw StateError('Cannot access macOSConfig if targetOS is not MacOS.'),
    final c => MacOSCodeConfig._(c),
  };
}

/// Configuration provided when [CodeConfig.targetOS] is [OS.iOS].
class IOSCodeConfig {
  final syntax.IOSCodeConfig _syntax;

  IOSCodeConfig._(this._syntax);

  /// Whether to target device or simulator.
  IOSSdk get targetSdk => IOSSdk.fromString(_syntax.targetSdk!);

  /// The lowest iOS version that the compiled code will be compatible with.
  int get targetVersion => _syntax.targetVersion!;

  IOSCodeConfig({required IOSSdk targetSdk, required int targetVersion})
    : _syntax = syntax.IOSCodeConfig(
        targetSdk: targetSdk.type,
        targetVersion: targetVersion,
      );
}

extension IOSConfigSyntactic on IOSCodeConfig {
  IOSSdk? get targetSdkSyntactic => switch (_syntax.targetSdk) {
    null => null,
    final s => IOSSdk.fromString(s),
  };
  int? get targetVersionSyntactic => _syntax.targetVersion;
}

/// Configuration provided when [CodeConfig.targetOS] is [OS.macOS].
class AndroidCodeConfig {
  final syntax.AndroidCodeConfig _syntax;

  AndroidCodeConfig._(this._syntax);

  /// The minimum Android SDK API version to that the compiled code will be
  /// compatible with.
  int get targetNdkApi => _syntax.targetNdkApi!;

  AndroidCodeConfig({required int targetNdkApi})
    : _syntax = syntax.AndroidCodeConfig(targetNdkApi: targetNdkApi);
}

extension AndroidConfigSyntactic on AndroidCodeConfig {
  int? get targetNdkApiSyntactic => _syntax.targetNdkApi;
}

//// Configuration provided when [CodeConfig.targetOS] is [OS.macOS].
class MacOSCodeConfig {
  final syntax.MacOSCodeConfig _syntax;

  MacOSCodeConfig._(this._syntax);

  /// The lowest MacOS version that the compiled code will be compatible with.
  int get targetVersion => _syntax.targetVersion!;

  MacOSCodeConfig({required int targetVersion})
    : _syntax = syntax.MacOSCodeConfig(targetVersion: targetVersion);
}

extension MacOSConfigSyntactic on MacOSCodeConfig {
  int? get targetVersionSyntactic => _syntax.targetVersion;
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
    required Architecture targetArchitecture,
    required OS targetOS,
    required LinkModePreference linkModePreference,
    CCompilerConfig? cCompiler,
    AndroidCodeConfig? android,
    IOSCodeConfig? iOS,
    MacOSCodeConfig? macOS,
  }) {
    syntax.Config.fromJson(
      hook_syntax.HookInput.fromJson(builder.json).config.json,
    ).code = syntax.CodeConfig(
      linkModePreference: linkModePreference.toSyntax(),
      targetArchitecture: targetArchitecture.toSyntax(),
      targetOs: targetOS.toSyntax(),
      cCompiler: cCompiler?.toSyntax(),
      android: android?.toSyntax(),
      iOS: iOS?.toSyntax(),
      macOS: macOS?.toSyntax(),
    );
  }
}

/// Provides access to [CodeAsset]s from a build hook output.
extension CodeAssetBuildOutput on BuildOutputAssets {
  /// The code assets emitted by the build hook.
  List<CodeAsset> get code =>
      encodedAssets
          .where((asset) => asset.type == CodeAsset.type)
          .map(CodeAsset.fromEncoded)
          .toList();
}

/// Provides access to [CodeAsset]s from a link hook output.
extension CodeAssetLinkOutput on LinkOutputAssets {
  /// The code assets emitted by the link hook.
  List<CodeAsset> get code =>
      encodedAssets
          .where((asset) => asset.type == CodeAsset.type)
          .map(CodeAsset.fromEncoded)
          .toList();
}

extension MacOSCodeConfigSyntax on MacOSCodeConfig {
  syntax.MacOSCodeConfig toSyntax() =>
      syntax.MacOSCodeConfig(targetVersion: targetVersion);
}

extension IOSCodeConfigSyntax on IOSCodeConfig {
  syntax.IOSCodeConfig toSyntax() => syntax.IOSCodeConfig(
    targetSdk: targetSdk.type,
    targetVersion: targetVersion,
  );
}

extension AndroidCodeConfigSyntax on AndroidCodeConfig {
  syntax.AndroidCodeConfig toSyntax() =>
      syntax.AndroidCodeConfig(targetNdkApi: targetNdkApi);
}
