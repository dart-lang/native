// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../api/hook_config.dart';

abstract class HookConfigImpl implements HookConfig {
  final Hook hook;

  /// The folder in which all output and intermediate artifacts should be
  /// placed.
  @override
  final Uri outputDirectory;

  @override
  final String packageName;

  @override
  final Uri packageRoot;

  final Version version;

  final BuildModeImpl? _buildMode;

  @override
  BuildModeImpl get buildMode {
    ensureNotDryRun(dryRun);
    return _buildMode!;
  }

  final CCompilerConfigImpl _cCompiler;

  @override
  CCompilerConfigImpl get cCompiler {
    ensureNotDryRun(dryRun);
    return _cCompiler;
  }

  @override
  final bool dryRun;

  @override
  final Iterable<String> supportedAssetTypes;

  final int? _targetAndroidNdkApi;

  @override
  final LinkModePreferenceImpl linkModePreference;

  @override
  int? get targetAndroidNdkApi {
    ensureNotDryRun(dryRun);
    return _targetAndroidNdkApi;
  }

  @override
  final ArchitectureImpl? targetArchitecture;

  final IOSSdkImpl? _targetIOSSdk;

  @override
  IOSSdkImpl? get targetIOSSdk {
    ensureNotDryRun(dryRun);
    if (targetOS != OS.iOS) {
      throw StateError(
        'This field is not available in if targetOS is not OS.iOS.',
      );
    }
    return _targetIOSSdk;
  }

  final int? _targetIOSVersion;

  @override
  int? get targetIOSVersion {
    ensureNotDryRun(dryRun);
    if (targetOS != OS.iOS) {
      throw StateError(
        'This field is not available in if targetOS is not OS.iOS.',
      );
    }
    return _targetIOSVersion;
  }

  final int? _targetMacOSVersion;

  @override
  int? get targetMacOSVersion {
    ensureNotDryRun(dryRun);
    if (targetOS != OS.macOS) {
      throw StateError(
        'This field is not available in if targetOS is not OS.macOS.',
      );
    }
    return _targetMacOSVersion;
  }

  @override
  final OSImpl targetOS;

  /// Output file name based on the protocol version.
  ///
  /// Makes newer build hooks work with older Dart SDKs.
  String get outputName;

  /// Legacy output file name.
  ///
  /// Older build hooks output a yaml file, ignoring the newer protocol version
  /// in the config.
  String? get outputNameV1_1_0;

  HookConfigImpl({
    required this.hook,
    required this.outputDirectory,
    required this.packageName,
    required this.packageRoot,
    required this.version,
    required BuildModeImpl? buildMode,
    required CCompilerConfigImpl? cCompiler,
    required this.supportedAssetTypes,
    required int? targetAndroidNdkApi,
    required this.targetArchitecture,
    required IOSSdkImpl? targetIOSSdk,
    required int? targetIOSVersion,
    required int? targetMacOSVersion,
    required this.linkModePreference,
    required this.targetOS,
    bool? dryRun,
  })  : _targetAndroidNdkApi = targetAndroidNdkApi,
        _targetIOSSdk = targetIOSSdk,
        _targetIOSVersion = targetIOSVersion,
        _targetMacOSVersion = targetMacOSVersion,
        _buildMode = buildMode,
        _cCompiler = cCompiler ?? CCompilerConfigImpl(),
        dryRun = dryRun ?? false;

  HookConfigImpl.dryRun({
    required this.hook,
    required this.outputDirectory,
    required this.packageName,
    required this.packageRoot,
    required this.version,
    required this.supportedAssetTypes,
    required this.linkModePreference,
    required this.targetOS,
  })  : _cCompiler = CCompilerConfigImpl(),
        dryRun = true,
        targetArchitecture = null,
        _buildMode = null,
        _targetAndroidNdkApi = null,
        _targetIOSSdk = null,
        _targetIOSVersion = null,
        _targetMacOSVersion = null;

  Uri get outputFile => outputDirectory.resolve(outputName);

  Uri? get outputFileV1_1_0 => outputNameV1_1_0 == null
      ? null
      : outputDirectory.resolve(outputNameV1_1_0!);

  // This is currently overriden by [BuildConfig], do account for older versions
  // still using a top-level build.dart.
  Uri get script => packageRoot.resolve('hook/').resolve(hook.scriptName);

  String toJsonString() => const JsonEncoder.withIndent('  ').convert(toJson());

  static const outDirConfigKey = 'out_dir';
  static const packageNameConfigKey = 'package_name';
  static const packageRootConfigKey = 'package_root';
  static const _versionKey = 'version';
  static const targetAndroidNdkApiConfigKey = 'target_android_ndk_api';
  static const targetIOSVersionConfigKey = 'target_ios_version';
  static const targetMacOSVersionConfigKey = 'target_macos_version';
  static const dryRunConfigKey = 'dry_run';
  static const supportedAssetTypesKey = 'supported_asset_types';

  Map<String, Object> toJson();

  Map<String, Object> hookToJson() {
    late Map<String, Object> cCompilerJson;
    if (!dryRun) {
      cCompilerJson = cCompiler.toJson();
    }

    return {
      outDirConfigKey: outputDirectory.toFilePath(),
      packageNameConfigKey: packageName,
      packageRootConfigKey: packageRoot.toFilePath(),
      OSImpl.configKey: targetOS.toString(),
      if (supportedAssetTypes.isNotEmpty)
        supportedAssetTypesKey: supportedAssetTypes,
      _versionKey: version.toString(),
      if (dryRun) dryRunConfigKey: dryRun,
      if (!dryRun) ...{
        BuildModeImpl.configKey: buildMode.toString(),
        ArchitectureImpl.configKey: targetArchitecture.toString(),
        if (targetOS == OS.iOS && targetIOSSdk != null)
          IOSSdkImpl.configKey: targetIOSSdk.toString(),
        if (targetOS == OS.iOS && targetIOSVersion != null)
          targetIOSVersionConfigKey: targetIOSVersion!,
        if (targetOS == OS.macOS && targetMacOSVersion != null)
          targetMacOSVersionConfigKey: targetMacOSVersion!,
        if (targetAndroidNdkApi != null)
          targetAndroidNdkApiConfigKey: targetAndroidNdkApi!,
        if (cCompilerJson.isNotEmpty)
          CCompilerConfigImpl.configKey: cCompilerJson,
      },
      LinkModePreferenceImpl.configKey: linkModePreference.toString(),
    }.sortOnKey();
  }

  static Version parseVersion(Config config) {
    final version = Version.parse(config.string('version'));
    if (version.major > latestVersion.major) {
      throw FormatException(
        'The config version $version is newer than this '
        'package:native_assets_cli config version $latestVersion, '
        'please update native_assets_cli.',
      );
    }
    if (version.major < latestVersion.major) {
      throw FormatException(
        'The config version $version is newer than this '
        'package:native_assets_cli config version $latestVersion, '
        'please update the Dart or Flutter SDK.',
      );
    }
    return version;
  }

  static bool? parseDryRun(Config config) =>
      config.optionalBool(dryRunConfigKey);

  static Uri parseOutDir(Config config) =>
      config.path(outDirConfigKey, mustExist: true);

  static String parsePackageName(Config config) =>
      config.string(packageNameConfigKey);

  static Uri parsePackageRoot(Config config) =>
      config.path(packageRootConfigKey, mustExist: true);

  static BuildModeImpl? parseBuildMode(Config config, bool dryRun) {
    if (dryRun) {
      _throwIfNotNullInDryRun<String>(config, BuildModeImpl.configKey);
      return null;
    } else {
      return BuildModeImpl.fromString(
        config.string(
          BuildModeImpl.configKey,
          validValues: BuildModeImpl.values.map((e) => '$e'),
        ),
      );
    }
  }

  static LinkModePreferenceImpl parseLinkModePreference(Config config) =>
      LinkModePreferenceImpl.fromString(
        config.string(
          LinkModePreferenceImpl.configKey,
          validValues: LinkModePreferenceImpl.values.map((e) => e.toString()),
        ),
      );

  static OSImpl parseTargetOS(Config config) => OSImpl.fromString(
        config.string(
          OSImpl.configKey,
          validValues: OSImpl.values.map((e) => '$e'),
        ),
      );

  static ArchitectureImpl? parseTargetArchitecture(
    Config config,
    bool dryRun,
    OSImpl? targetOS,
  ) {
    if (dryRun) {
      _throwIfNotNullInDryRun<String>(config, ArchitectureImpl.configKey);
      return null;
    } else {
      final validArchitectures = [
        if (targetOS == null)
          ...ArchitectureImpl.values
        else
          for (final target in Target.values)
            if (target.os == targetOS) target.architecture
      ];
      return ArchitectureImpl.fromString(
        config.string(
          ArchitectureImpl.configKey,
          validValues: validArchitectures.map((e) => '$e'),
        ),
      );
    }
  }

  static IOSSdkImpl? parseTargetIOSSdk(
      Config config, bool dryRun, OSImpl? targetOS) {
    if (dryRun) {
      _throwIfNotNullInDryRun<String>(config, IOSSdkImpl.configKey);
      return null;
    } else {
      return targetOS == OSImpl.iOS
          ? IOSSdkImpl.fromString(
              config.string(
                IOSSdkImpl.configKey,
                validValues: IOSSdkImpl.values.map((e) => '$e'),
              ),
            )
          : null;
    }
  }

  static int? parseTargetAndroidNdkApi(
    Config config,
    bool dryRun,
    OSImpl? targetOS,
  ) {
    if (dryRun) {
      _throwIfNotNullInDryRun<int>(config, targetAndroidNdkApiConfigKey);
      return null;
    } else {
      return (targetOS == OSImpl.android)
          ? config.int(targetAndroidNdkApiConfigKey)
          : null;
    }
  }

  static int? parseTargetIosVersion(
    Config config,
    bool dryRun,
    OSImpl? targetOS,
  ) {
    if (dryRun) {
      _throwIfNotNullInDryRun<int>(config, targetIOSVersionConfigKey);
      return null;
    } else {
      return (targetOS == OSImpl.iOS)
          ? config.optionalInt(targetIOSVersionConfigKey)
          : null;
    }
  }

  static int? parseTargetMacOSVersion(
    Config config,
    bool dryRun,
    OSImpl? targetOS,
  ) {
    if (dryRun) {
      _throwIfNotNullInDryRun<int>(config, targetMacOSVersionConfigKey);
      return null;
    } else {
      return (targetOS == OSImpl.macOS)
          ? config.optionalInt(targetMacOSVersionConfigKey)
          : null;
    }
  }

  static Uri? _parseArchiver(Config config, bool dryRun) {
    if (dryRun) {
      _throwIfNotNullInDryRun<int>(config, CCompilerConfigImpl.arConfigKeyFull);
      return null;
    } else {
      return config.optionalPath(
        CCompilerConfigImpl.arConfigKeyFull,
        mustExist: true,
      );
    }
  }

  static Uri? _parseCompiler(Config config, bool dryRun) {
    if (dryRun) {
      _throwIfNotNullInDryRun<int>(config, CCompilerConfigImpl.ccConfigKeyFull);
      return null;
    } else {
      return config.optionalPath(
        CCompilerConfigImpl.ccConfigKeyFull,
        mustExist: true,
      );
    }
  }

  static Uri? _parseLinker(Config config, bool dryRun) {
    if (dryRun) {
      _throwIfNotNullInDryRun<int>(config, CCompilerConfigImpl.ccConfigKeyFull);
      return null;
    } else {
      return config.optionalPath(
        CCompilerConfigImpl.ldConfigKeyFull,
        mustExist: true,
      );
    }
  }

  static Uri? _parseEnvScript(Config config, bool dryRun, Uri? compiler) {
    if (dryRun) {
      _throwIfNotNullInDryRun<int>(config, CCompilerConfigImpl.ccConfigKeyFull);
      return null;
    } else {
      return (compiler != null && compiler.toFilePath().endsWith('cl.exe'))
          ? config.path(CCompilerConfigImpl.envScriptConfigKeyFull,
              mustExist: true)
          : null;
    }
  }

  static List<String>? _parseEnvScriptArgs(Config config, bool dryRun) {
    if (dryRun) {
      _throwIfNotNullInDryRun<int>(config, CCompilerConfigImpl.ccConfigKeyFull);
      return null;
    } else {
      return config.optionalStringList(
        CCompilerConfigImpl.envScriptArgsConfigKeyFull,
        splitEnvironmentPattern: ' ',
      );
    }
  }

  static List<String> parseSupportedAssetTypes(Config config) =>
      config.optionalStringList(supportedAssetTypesKey) ??
      [NativeCodeAsset.type];

  static CCompilerConfigImpl parseCCompiler(Config config, bool dryRun) {
    final parseCompiler = _parseCompiler(config, dryRun);
    final cCompiler = CCompilerConfigImpl(
      archiver: _parseArchiver(config, dryRun),
      compiler: parseCompiler,
      envScript: _parseEnvScript(config, dryRun, parseCompiler),
      envScriptArgs: _parseEnvScriptArgs(config, dryRun),
      linker: _parseLinker(config, dryRun),
    );
    return cCompiler;
  }

  static void _throwIfNotNullInDryRun<T>(Config config, String key) {
    final object = config.valueOf<T?>(key);
    if (object != null) {
      throw const FormatException('''This field is not available in dry runs.
In Flutter projects, native builds are generated per OS which target multiple
architectures, build modes, etc. Therefore, the list of native assets produced
can _only_ depend on OS.''');
    }
  }

  static void ensureNotDryRun(bool dryRun) {
    if (dryRun) {
      throw StateError('''This field is not available in dry runs.
In Flutter projects, native builds are generated per OS which target multiple
architectures, build modes, etc. Therefore, the list of native assets produced
can _only_ depend on OS.''');
    }
  }

  @override
  bool operator ==(Object other) {
    if (other is! HookConfigImpl) {
      return false;
    }
    if (other.outputDirectory != outputDirectory) return false;
    if (other.packageName != packageName) return false;
    if (other.packageRoot != packageRoot) return false;
    if (other.dryRun != dryRun) return false;
    if (other.targetOS != targetOS) return false;
    if (other.linkModePreference != linkModePreference) return false;
    if (!const DeepCollectionEquality()
        .equals(other.supportedAssetTypes, supportedAssetTypes)) return false;
    if (!dryRun) {
      if (other.buildMode != buildMode) return false;
      if (other.targetArchitecture != targetArchitecture) return false;
      if (targetOS == OS.iOS && other.targetIOSSdk != targetIOSSdk) {
        return false;
      }
      if (other.targetAndroidNdkApi != targetAndroidNdkApi) return false;
      if (other.cCompiler != cCompiler) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll([
        outputDirectory,
        packageName,
        packageRoot,
        targetOS,
        dryRun,
        if (!dryRun) ...[
          buildMode,
          targetArchitecture,
          if (targetOS == OS.iOS) targetIOSSdk,
          targetAndroidNdkApi,
          cCompiler,
        ],
      ]);

  /// Constructs a checksum for a [BuildConfigImpl] based on the fields of a
  /// buildconfig that influence the build.
  ///
  /// This can be used for an [outputDirectory], but should not be used for
  /// dry-runs.
  ///
  /// In particular, it only takes the package name from [packageRoot], so that
  /// the hash is equal across checkouts and ignores [outputDirectory] itself.
  static String checksum({
    required String packageName,
    required Uri packageRoot,
    required ArchitectureImpl targetArchitecture,
    required OSImpl targetOS,
    required BuildModeImpl buildMode,
    IOSSdkImpl? targetIOSSdk,
    int? targetAndroidNdkApi,
    CCompilerConfigImpl? cCompiler,
    required LinkModePreferenceImpl linkModePreference,
    Map<String, Metadata>? dependencyMetadata,
    Iterable<String>? supportedAssetTypes,
    Version? version,
    required Hook hook,
    required bool? linkingEnabled,
  }) {
    final input = [
      version ?? latestVersion,
      packageName,
      targetArchitecture.toString(),
      targetOS.toString(),
      targetIOSSdk.toString(),
      targetAndroidNdkApi.toString(),
      buildMode.toString(),
      linkModePreference.toString(),
      cCompiler?.archiver.toString(),
      cCompiler?.compiler.toString(),
      cCompiler?.envScript.toString(),
      cCompiler?.envScriptArgs.toString(),
      cCompiler?.linker.toString(),
      if (dependencyMetadata != null)
        for (final entry in dependencyMetadata.entries) ...[
          entry.key,
          json.encode(entry.value.toJson()),
        ],
      ...supportedAssetTypes ?? [NativeCodeAsset.type],
      hook.name,
      linkingEnabled,
    ].join('###');
    final sha256String = sha256.convert(utf8.encode(input)).toString();
    // 256 bit hashes lead to 64 hex character strings.
    // To avoid overflowing file paths limits, only use 32.
    // Using 16 hex characters would also be unlikely to have collisions.
    const nameLength = 32;
    return sha256String.substring(0, nameLength);
  }

  static String checksumDryRun({
    required String packageName,
    required Uri packageRoot,
    required OSImpl targetOS,
    required LinkModePreferenceImpl linkModePreference,
    Version? version,
    Iterable<String>? supportedAssetTypes,
    required Hook hook,
    required bool? linkingEnabled,
  }) {
    final input = [
      version ?? latestVersion,
      packageName,
      targetOS.toString(),
      linkModePreference.toString(),
      ...supportedAssetTypes ?? [NativeCodeAsset.type],
      hook.name,
      linkingEnabled,
    ].join('###');
    final sha256String = sha256.convert(utf8.encode(input)).toString();
    // 256 bit hashes lead to 64 hex character strings.
    // To avoid overflowing file paths limits, only use 32.
    // Using 16 hex characters would also be unlikely to have collisions.
    const nameLength = 32;
    return sha256String.substring(0, nameLength);
  }

  /// The version of [HookConfigImpl].
  ///
  /// This class is used in the protocol between the Dart and Flutter SDKs
  /// and packages through build hook invocations.
  ///
  /// If we ever were to make breaking changes, it would be useful to give
  /// proper error messages rather than just fail to parse the JSON
  /// representation in the protocol.
  static Version latestVersion = Version(1, 5, 0);
}
