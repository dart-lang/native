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
import 'sanitizer.dart';
import 'syntax.g.dart';

/// Extension to the [HookConfig] providing access to configuration specific
/// to code assets (only available if code assets are supported).
extension HookConfigCodeConfig on HookConfig {
  /// Code asset specific configuration.
  ///
  /// Only available if [buildCodeAssets] is true.
  CodeConfig get code {
    if (!buildCodeAssets) {
      throw StateError(
        'HookConfig.code should only be accessed when building code assets. '
        'Check HookConfig.buildCodeAssets '
        '(e.g. `input.config.buildCodeAssets`) '
        'before accessing HookConfig.code.',
      );
    }
    return CodeConfig._fromJson(json, path);
  }

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

  /// The compiler sanitizer to use, if any.
  ///
  /// Sanitizers (like AddressSanitizer, MemorySanitizer, or ThreadSanitizer)
  /// instrument binaries for runtime diagnostics.
  ///
  /// The Dart SDK JIT or AOT runtime itself can be compiled with a sanitizer.
  /// To run native code alongside a sanitized Dart SDK, the code assets
  /// must be compiled with the exact same sanitizer, ensuring they share
  /// compatible runtime libraries and memory allocators across the FFI
  /// boundary.
  Sanitizer? get sanitizer => switch (_syntax.sanitizer) {
    null => null,
    final s => SanitizerSyntaxExtension.fromSyntax(s),
  };

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

  /// The major component of the lowest compatible iOS version.
  @Deprecated('Use targetVersionString instead.')
  int get targetVersion => _syntax.targetVersion;

  /// The complete lowest compatible iOS deployment version.
  ///
  /// Numeric major, major/minor, and major/minor/patch versions are supported,
  /// for example `16`, `16.4`, and `17.2.1`. The spelling is preserved for
  /// compiler and linker arguments. Prerelease and build suffixes are not
  /// supported by Apple deployment-target flags.
  /// Each component must fit in an unsigned 32-bit integer.
  ///
  /// Older SDKs supplying only the integer version are supported.
  /// Throws [FormatException] if the supplied deployment version is malformed
  /// or its major component disagrees with the legacy integer version.
  String get targetVersionString => _readAppleDeploymentVersion(
    _syntax.targetVersion,
    _syntax.targetVersionString,
  );

  /// Constructs a new [IOSCodeConfig].
  ///
  /// Supply exactly one of [targetVersionString] or the deprecated
  /// [targetVersion]. Throws [ArgumentError] for both, neither, or an invalid
  /// deployment version. Both protocol fields are populated so older hooks
  /// can still read the major version.
  factory IOSCodeConfig({
    required IOSSdk targetSdk,
    @Deprecated('Use targetVersionString instead.') int? targetVersion,
    String? targetVersionString,
  }) {
    final (major, version) = _appleDeploymentVersion(
      targetVersion,
      targetVersionString,
    );
    return IOSCodeConfig._(
      IOSCodeConfigSyntax(
        targetSdk: targetSdk.type,
        targetVersion: major,
        targetVersionString: version,
      ),
    );
  }
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

  /// The major component of the lowest compatible macOS version.
  @Deprecated('Use targetVersionString instead.')
  int get targetVersion => _syntax.targetVersion;

  /// The complete lowest compatible macOS deployment version.
  ///
  /// Numeric major, major/minor, and major/minor/patch versions are supported,
  /// for example `13`, `14.4`, and `14.4.1`. The spelling is preserved for
  /// compiler and linker arguments. Prerelease and build suffixes are not
  /// supported by Apple deployment-target flags.
  /// Each component must fit in an unsigned 32-bit integer.
  ///
  /// Older SDKs supplying only the integer version are supported.
  /// Throws [FormatException] if the supplied deployment version is malformed
  /// or its major component disagrees with the legacy integer version.
  String get targetVersionString => _readAppleDeploymentVersion(
    _syntax.targetVersion,
    _syntax.targetVersionString,
  );

  /// Constructs a new [MacOSCodeConfig].
  ///
  /// Supply exactly one of [targetVersionString] or the deprecated
  /// [targetVersion]. Throws [ArgumentError] for both, neither, or an invalid
  /// deployment version. Both protocol fields are populated so older hooks
  /// can still read the major version.
  factory MacOSCodeConfig({
    @Deprecated('Use targetVersionString instead.') int? targetVersion,
    String? targetVersionString,
  }) {
    final (major, version) = _appleDeploymentVersion(
      targetVersion,
      targetVersionString,
    );
    return MacOSCodeConfig._(
      MacOSCodeConfigSyntax(targetVersion: major, targetVersionString: version),
    );
  }
}

final _appleDeploymentVersionPattern = RegExp(r'[0-9]+(?:\.[0-9]+){0,2}');
const _maxAppleDeploymentVersionComponent = 0xffffffff;

int? _tryAppleDeploymentVersionMajor(String version) {
  final match = _appleDeploymentVersionPattern.matchAsPrefix(version);
  if (match == null || match.end != version.length) return null;
  int? major;
  for (final component in version.split('.')) {
    final value = int.tryParse(component);
    if (value == null || value > _maxAppleDeploymentVersionComponent) {
      return null;
    }
    major ??= value;
  }
  return major;
}

(int, String) _appleDeploymentVersion(int? major, String? version) {
  if ((major == null) == (version == null)) {
    throw ArgumentError(
      'Supply exactly one of targetVersion or targetVersionString.',
    );
  }
  version ??= '$major';
  final parsedMajor = _tryAppleDeploymentVersionMajor(version);
  if (parsedMajor == null) {
    throw ArgumentError.value(
      major ?? version,
      major != null ? 'targetVersion' : 'targetVersionString',
      'Expected one to three numeric components fitting unsigned '
      '32-bit integers, such as 16, 16.4, or 17.2.1.',
    );
  }
  return (parsedMajor, version);
}

String _readAppleDeploymentVersion(int major, String? version) {
  version ??= '$major';
  final parsedMajor = _tryAppleDeploymentVersionMajor(version);
  if (parsedMajor == null) {
    throw FormatException(
      'Invalid Apple deployment version: "$version". '
      'Expected one to three numeric components fitting unsigned '
      '32-bit integers, such as 16, 16.4, or 17.2.1.',
    );
  }
  if (parsedMajor != major) {
    throw const FormatException(
      'targetVersion and targetVersionString must '
      'agree on the major version.',
    );
  }
  return version;
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
  ///
  /// The [CodeAsset.file], if provided, must be an absolute path. Prefer
  /// constructing the path via [HookInput.outputDirectoryShared] or
  /// [HookInput.outputDirectory].
  ///
  /// The [CodeAsset.id] must be starting with `package:<package>/` where
  /// `<package>` is the package name of the build hook where this method is
  /// called.
  void add(CodeAsset asset, {AssetRouting routing = const ToAppBundle()}) =>
      _output.addEncodedAsset(asset.encode(), routing: routing);

  /// Adds the given [assets] to the hook output with [routing].
  ///
  /// The [CodeAsset.file]s, if provided, must be absolute paths. Prefer
  /// constructing the paths via [HookInput.outputDirectoryShared] or
  /// [HookInput.outputDirectory].
  ///
  /// The [CodeAsset.id]s must be starting with `package:<package>/` where
  /// `<package>` is the package name of the build hook where this method is
  /// called.
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
    Sanitizer? sanitizer,
  }) {
    final codeConfig = CodeConfigSyntax(
      linkModePreference: linkModePreference.toSyntax(),
      targetArchitecture: targetArchitecture.toSyntax(),
      targetOs: targetOS.toSyntax(),
      cCompiler: cCompiler?.toSyntax(),
      android: android?.toSyntax(),
      iOS: iOS?.toSyntax(),
      macOS: macOS?.toSyntax(),
      sanitizer: sanitizer?.toSyntax(),
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
  MacOSCodeConfigSyntax toSyntax() => MacOSCodeConfigSyntax(
    targetVersion: _syntax.targetVersion,
    targetVersionString: _syntax.targetVersionString,
  );
}

/// Extension methods for [IOSCodeConfig] to convert to and from the syntax
/// model.
extension IOSCodeConfigSyntaxExtension on IOSCodeConfig {
  /// Converts this [IOSCodeConfig] to its corresponding [IOSCodeConfigSyntax].
  IOSCodeConfigSyntax toSyntax() => IOSCodeConfigSyntax(
    targetSdk: targetSdk.type,
    targetVersion: _syntax.targetVersion,
    targetVersionString: _syntax.targetVersionString,
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
