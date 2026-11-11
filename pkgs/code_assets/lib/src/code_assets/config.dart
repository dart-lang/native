// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:hooks/hooks.dart';
import 'package:meta/meta.dart';

import 'apple_version.dart';
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

/// Extension to the [DoctorConfig] providing access to configuration specific
/// to code assets (only available if code assets are supported).
@experimental
extension DoctorConfigCodeConfig on DoctorConfig {
  /// Code asset specific configuration for `hook/doctor.dart`.
  ///
  /// Only available if [buildCodeAssets] is true.
  DoctorCodeConfigs get code {
    if (!buildCodeAssets) {
      throw StateError(
        'DoctorConfig.code should only be accessed when building code assets. '
        'Check DoctorConfig.buildCodeAssets '
        '(e.g. `input.config.buildCodeAssets`) '
        'before accessing DoctorConfig.code.',
      );
    }
    return DoctorCodeConfigs._fromJson(json, path);
  }

  /// Whether the hook invoker (e.g. the Dart or Flutter SDK) expects this
  /// workspace to build code assets.
  bool get buildCodeAssets => buildAssetTypes.contains(CodeAssetType.type);
}

/// The configuration for [CodeAsset]s in [DoctorConfig].
///
/// Available via [DoctorConfigCodeConfig.code].
@experimental
final class DoctorCodeConfigs {
  final DoctorCodeConfigsSyntax _syntax;

  DoctorCodeConfigs._fromJson(Map<String, Object?> json, List<Object> path)
    : _syntax = DoctorConfigSyntax.fromJson(
        json,
        path: path,
      ).extensions!.codeAssets!;

  /// The [DoctorCodeConfig]s for all target OS and architecture combinations
  /// that the invoking SDK (`dart` or `flutter`) can target.
  List<DoctorCodeConfig> get configs => [
    for (final c in _syntax.configs) DoctorCodeConfig._(c),
  ];
}

/// The configuration for a single target in [DoctorCodeConfigs.configs].
///
/// Extended by [CodeConfig] so toolchain-resolution logic can be shared
/// between `hook/build.dart`, `hook/link.dart`, and `hook/doctor.dart`.
@experimental
class DoctorCodeConfig {
  final DoctorCodeConfigSyntax _syntax;

  DoctorCodeConfig._(this._syntax);

  /// Constructs a new [DoctorCodeConfig].
  DoctorCodeConfig({
    required Architecture targetArchitecture,
    required OS targetOS,
    CCompilerConfig? cCompiler,
    DoctorIOSCodeConfig? iOS,
  }) : _syntax = DoctorCodeConfigSyntax(
         targetArchitecture: targetArchitecture.toSyntax(),
         targetOs: targetOS.toSyntax(),
         cCompiler: cCompiler?.toSyntax(),
         iOS: iOS?.toSyntax(),
       );

  /// The architecture the code code asset should be built for.
  ///
  /// The build and link hooks are invoked once per [targetArchitecture]. If the
  /// invoker produces multi-architecture applications, the invoker is
  /// responsible for combining the [CodeAsset]s for individual architectures
  /// into a universal binary. So, the build and link hook implementations are
  /// not responsible for providing universal binaries.
  Architecture get targetArchitecture =>
      ArchitectureSyntaxExtension.fromSyntax(_syntax.targetArchitecture);

  /// A compiler toolchain able to target [targetOS] with [targetArchitecture].
  CCompilerConfig? get cCompiler => switch (_syntax.cCompiler) {
    null => null,
    final c => CCompilerConfigSyntaxExtension.fromSyntax(c),
  };

  /// The operating system being compiled for.
  OS get targetOS => OSSyntaxExtension.fromSyntax(_syntax.targetOs);

  /// Configuration provided when [DoctorCodeConfig.targetOS] is [OS.iOS].
  DoctorIOSCodeConfig get iOS => switch (_syntax.iOS) {
    null => throw StateError('Cannot access iOSConfig if targetOS is not iOS.'),
    final c => DoctorIOSCodeConfig._(c),
  };
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
final class CodeConfig extends DoctorCodeConfig {
  CodeConfigSyntax get _codeSyntax => _syntax as CodeConfigSyntax;

  CodeConfig._fromJson(Map<String, Object?> json, List<Object> path)
    : super._(ConfigSyntax.fromJson(json, path: path).extensions!.codeAssets!);

  /// The preferred link for [CodeAsset]s.
  LinkModePreference get linkModePreference =>
      LinkModePreferenceSyntaxExtension.fromSyntax(
        _codeSyntax.linkModePreference,
      );

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
  Sanitizer? get sanitizer => switch (_codeSyntax.sanitizer) {
    null => null,
    final s => SanitizerSyntaxExtension.fromSyntax(s),
  };

  /// Configuration provided when [CodeConfig.targetOS] is [OS.macOS].
  @override
  IOSCodeConfig get iOS => switch (_codeSyntax.iOS) {
    null => throw StateError('Cannot access iOSConfig if targetOS is not iOS.'),
    final c => IOSCodeConfig._(c),
  };

  /// Configuration provided when [CodeConfig.targetOS] is [OS.android].
  AndroidCodeConfig get android => switch (_codeSyntax.android) {
    null => throw StateError(
      'Cannot access androidConfig if targetOS is not android.',
    ),
    final c => AndroidCodeConfig._(c),
  };

  /// Configuration provided when [CodeConfig.targetOS] is [OS.macOS].
  MacOSCodeConfig get macOS => switch (_codeSyntax.macOS) {
    null => throw StateError(
      'Cannot access macOSConfig if targetOS is not MacOS.',
    ),
    final c => MacOSCodeConfig._(c),
  };
}

/// The configuration for [CodeAsset]s for target OS [OS.iOS] in
/// [DoctorCodeConfig.iOS].
///
/// Extended by [IOSCodeConfig].
@experimental
class DoctorIOSCodeConfig {
  final DoctorIOSCodeConfigSyntax _syntax;

  DoctorIOSCodeConfig._(this._syntax);

  /// Whether to target device or simulator.
  IOSSdk get targetSdk => IOSSdk.fromString(_syntax.targetSdk);

  /// Constructs a new [DoctorIOSCodeConfig].
  DoctorIOSCodeConfig({required IOSSdk targetSdk})
    : _syntax = DoctorIOSCodeConfigSyntax(targetSdk: targetSdk.type);
}

/// The configuration for [CodeAsset]s for target OS [OS.iOS] in
/// [CodeConfig.iOS].
final class IOSCodeConfig extends DoctorIOSCodeConfig {
  IOSCodeConfigSyntax get _iosSyntax => _syntax as IOSCodeConfigSyntax;

  IOSCodeConfig._(IOSCodeConfigSyntax super._syntax) : super._();

  /// The major component of the lowest compatible iOS version.
  @Deprecated('Use deploymentVersion.major instead.')
  int get targetVersion => deploymentVersion.major;

  /// The complete lowest compatible iOS deployment version.
  ///
  /// Older SDKs supplying only the integer version are supported, with minor
  /// and patch components defaulting to zero.
  /// When the nested protocol version is present, all three components are
  /// required.
  /// The nested version takes precedence over the legacy integer.
  /// Malformed components throw [FormatException] when accessed.
  AppleVersion get deploymentVersion => switch (_iosSyntax.deploymentVersion) {
    final version? => AppleVersionSyntaxExtension.fromSyntax(version),
    null => AppleVersion(_iosSyntax.targetVersion),
  };

  /// Constructs a new [IOSCodeConfig].
  ///
  /// Supply exactly one of [deploymentVersion] or the deprecated
  /// [targetVersion].
  /// Throws [ArgumentError] for both, neither, or an invalid legacy version.
  /// Both protocol fields are populated so older hooks can read the major
  /// version.
  factory IOSCodeConfig({
    required IOSSdk targetSdk,
    @Deprecated('Use deploymentVersion instead.') int? targetVersion,
    AppleVersion? deploymentVersion,
  }) {
    final version = _appleDeploymentVersion(targetVersion, deploymentVersion);
    return IOSCodeConfig._(
      IOSCodeConfigSyntax(
        targetSdk: targetSdk.type,
        targetVersion: version.major,
        deploymentVersion: version.toSyntax(),
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
  @Deprecated('Use deploymentVersion.major instead.')
  int get targetVersion => deploymentVersion.major;

  /// The complete lowest compatible macOS deployment version.
  ///
  /// Older SDKs supplying only the integer version are supported, with minor
  /// and patch components defaulting to zero.
  /// When the nested protocol version is present, all three components are
  /// required.
  /// The nested version takes precedence over the legacy integer.
  /// Malformed components throw [FormatException] when accessed.
  AppleVersion get deploymentVersion => switch (_syntax.deploymentVersion) {
    final version? => AppleVersionSyntaxExtension.fromSyntax(version),
    null => AppleVersion(_syntax.targetVersion),
  };

  /// Constructs a new [MacOSCodeConfig].
  ///
  /// Supply exactly one of [deploymentVersion] or the deprecated
  /// [targetVersion].
  /// Throws [ArgumentError] for both, neither, or an invalid legacy version.
  /// Both protocol fields are populated so older hooks can read the major
  /// version.
  factory MacOSCodeConfig({
    @Deprecated('Use deploymentVersion instead.') int? targetVersion,
    AppleVersion? deploymentVersion,
  }) {
    final version = _appleDeploymentVersion(targetVersion, deploymentVersion);
    return MacOSCodeConfig._(
      MacOSCodeConfigSyntax(
        targetVersion: version.major,
        deploymentVersion: version.toSyntax(),
      ),
    );
  }
}

AppleVersion _appleDeploymentVersion(int? major, AppleVersion? version) {
  if ((major == null) == (version == null)) {
    throw ArgumentError(
      'Supply exactly one of targetVersion or deploymentVersion.',
    );
  }
  if (version != null) return version;
  return AppleVersion(major!);
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

/// Extension to initialize code specific configuration on doctor inputs.
@experimental
extension CodeAssetDoctorInputBuilder on DoctorConfigBuilder {
  /// Sets up the code asset specific configuration for a doctor hook input.
  void setupCode(List<DoctorCodeConfig> configs) {
    final doctorCodeConfigs = DoctorCodeConfigsSyntax(
      configs: [for (final c in configs) c.toSyntax()],
    );
    final baseDoctorConfig = DoctorConfigSyntax.fromJson(json);
    baseDoctorConfig.extensions ??= DoctorConfigExtensionsSyntax.fromJson({});
    final doctorConfig = DoctorConfigSyntax.fromJson(baseDoctorConfig.json);
    doctorConfig.extensions!.codeAssets = doctorCodeConfigs;
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
  MacOSCodeConfigSyntax toSyntax() => _syntax;
}

/// Extension methods for [DoctorCodeConfig] to convert to and from the syntax
/// model.
@experimental
extension DoctorCodeConfigSyntaxExtension on DoctorCodeConfig {
  /// Converts this [DoctorCodeConfig] to its corresponding
  /// [DoctorCodeConfigSyntax].
  DoctorCodeConfigSyntax toSyntax() => _syntax;
}

/// Extension methods for [DoctorIOSCodeConfig] to convert to and from the
/// syntax model.
@experimental
extension DoctorIOSCodeConfigSyntaxExtension on DoctorIOSCodeConfig {
  /// Converts this [DoctorIOSCodeConfig] to its corresponding
  /// [DoctorIOSCodeConfigSyntax].
  DoctorIOSCodeConfigSyntax toSyntax() => _syntax;
}

/// Extension methods for [IOSCodeConfig] to convert to and from the syntax
/// model.
extension IOSCodeConfigSyntaxExtension on IOSCodeConfig {
  /// Converts this [IOSCodeConfig] to its corresponding [IOSCodeConfigSyntax].
  IOSCodeConfigSyntax toSyntax() => _iosSyntax;
}

/// Extension methods for [AndroidCodeConfig] to convert to and from the syntax
/// model.
extension AndroidCodeConfigSyntaxExtension on AndroidCodeConfig {
  /// Converts this [AndroidCodeConfig] to its corresponding
  /// [AndroidCodeConfigSyntax].
  AndroidCodeConfigSyntax toSyntax() =>
      AndroidCodeConfigSyntax(targetNdkApi: targetNdkApi);
}
