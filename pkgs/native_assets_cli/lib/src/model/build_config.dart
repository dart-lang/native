// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../api/build_config.dart';

final class BuildConfigImpl extends HookConfigImpl implements BuildConfig {
  @override
  Hook get hook => Hook.build;

  @override
  //TODO: Should be removed once migration to `hook/` is complete.
  Uri get script {
    final hookScript = packageRoot.resolve('hook/').resolve(hook.scriptName);
    if (File.fromUri(hookScript).existsSync()) {
      return hookScript;
    } else {
      return packageRoot.resolve(hook.scriptName);
    }
  }

  @override
  String get outputName =>
      version > Version(1, 1, 0) ? 'build_output.json' : 'build_output.yaml';

  @override
  IOSSdkImpl get targetIOSSdk {
    _ensureNotDryRun();
    if (targetOS != OS.iOS) {
      throw StateError(
        'This field is not available in if targetOS is not OS.iOS.',
      );
    }
    return super.targetIOSSdk!;
  }

  @override
  int? get targetAndroidNdkApi {
    _ensureNotDryRun();
    return super.targetAndroidNdkApi;
  }

  @override
  LinkModePreferenceImpl get linkModePreference => _linkModePreference;
  final LinkModePreferenceImpl _linkModePreference;

  @override
  Object? metadatum(String packageName, String key) {
    _ensureNotDryRun();
    return _dependencyMetadata?[packageName]?.metadata[key];
  }

  final Map<String, Metadata>? _dependencyMetadata;

  @override
  CCompilerConfigImpl get cCompiler {
    _ensureNotDryRun();
    return super.cCompiler;
  }

  @override
  BuildModeImpl get buildMode {
    _ensureNotDryRun();
    return super.buildMode!;
  }

  Config get config => _config;
  late final Config _config;

  factory BuildConfigImpl({
    required Uri outDir,
    required String packageName,
    required Uri packageRoot,
    required BuildModeImpl buildMode,
    required ArchitectureImpl targetArchitecture,
    required OSImpl targetOS,
    IOSSdkImpl? targetIOSSdk,
    int? targetAndroidNdkApi,
    CCompilerConfigImpl? cCompiler,
    required LinkModePreferenceImpl linkModePreference,
    Map<String, Metadata>? dependencyMetadata,
    Iterable<String>? supportedAssetTypes,
    Version? version,
  }) =>
      BuildConfigImpl._(
        version: version ?? latestVersion,
        outputDirectory: outDir,
        packageName: packageName,
        packageRoot: packageRoot,
        buildMode: buildMode,
        targetArchitecture: targetArchitecture,
        targetOS: targetOS,
        targetIOSSdk: targetIOSSdk,
        targetAndroidNdkApi: targetAndroidNdkApi,
        cCompiler: cCompiler ?? CCompilerConfigImpl(),
        linkMode: linkModePreference,
        dependencyMetadata: dependencyMetadata,
        dryRun: false,
        supportedAssetTypes:
            _supportedAssetTypesBackwardsCompatibility(supportedAssetTypes),
      );

  factory BuildConfigImpl.dryRun({
    required Uri outDir,
    required String packageName,
    required Uri packageRoot,
    required OSImpl targetOS,
    required LinkModePreferenceImpl linkModePreference,
    Iterable<String>? supportedAssetTypes,
  }) =>
      BuildConfigImpl._(
        version: latestVersion,
        outputDirectory: outDir,
        packageName: packageName,
        packageRoot: packageRoot,
        targetArchitecture: null,
        targetOS: targetOS,
        cCompiler: CCompilerConfigImpl(),
        linkMode: linkModePreference,
        dryRun: true,
        supportedAssetTypes:
            _supportedAssetTypesBackwardsCompatibility(supportedAssetTypes),
      );

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
      ..._supportedAssetTypesBackwardsCompatibility(supportedAssetTypes),
      hook.name,
    ].join('###');
    final sha256String = sha256.convert(utf8.encode(input)).toString();
    // 256 bit hashes lead to 64 hex character strings.
    // To avoid overflowing file paths limits, only use 32.
    // Using 16 hex characters would also be unlikely to have collisions.
    const nameLength = 32;
    return sha256String.substring(0, nameLength);
  }

  static List<String> _supportedAssetTypesBackwardsCompatibility(
    Iterable<String>? supportedAssetTypes,
  ) =>
      [
        ...?supportedAssetTypes,
        if (supportedAssetTypes == null) NativeCodeAsset.type,
      ];

  BuildConfigImpl._({
    required super.outputDirectory,
    required super.packageName,
    required super.packageRoot,
    Version? version,
    super.buildMode,
    required super.cCompiler,
    required Iterable<String> supportedAssetTypes,
    super.targetAndroidNdkApi,
    required super.targetArchitecture,
    super.targetIOSSdk,
    required super.targetOS,
    required LinkModePreferenceImpl linkMode,
    Map<String, Metadata>? dependencyMetadata,
    required super.dryRun,
  })  : _linkModePreference = linkMode,
        _dependencyMetadata = dependencyMetadata,
        super(
          hook: Hook.build,
          version: version ?? latestVersion,
          supportedAssetTypes:
              _supportedAssetTypesBackwardsCompatibility(supportedAssetTypes),
        );

  /// The version of [BuildConfigImpl].
  ///
  /// This class is used in the protocol between the Dart and Flutter SDKs
  /// and packages through build hook invocations.
  ///
  /// If we ever were to make breaking changes, it would be useful to give
  /// proper error messages rather than just fail to parse the JSON
  /// representation in the protocol.
  static Version latestVersion = Version(1, 3, 0);

  factory BuildConfigImpl._fromConfig(Config config) {
    final result = _readFieldsFromConfig(config);
    final configErrorMessages = <Object>[];
    if (configErrorMessages.isNotEmpty) {
      throw FormatException('BuildConfig is not in the right format. '
          'FormatExceptions: $configErrorMessages');
    }

    return result.$1!;
  }

  static BuildConfigImpl fromArguments(
    List<String> args, {
    Map<String, String>? environment,
    Uri? workingDirectory,
  }) {
    // TODO(https://github.com/dart-lang/native/issues/1000): At some point,
    // migrate away from package:cli_config, to get rid of package:yaml
    // dependency.
    final config = Config.fromArgumentsSync(
      arguments: args,
      environment: environment,
      workingDirectory: workingDirectory,
    );
    return BuildConfigImpl._fromConfig(config);
  }

  static const dependencyMetadataConfigKey = 'dependency_metadata';

  static (BuildConfigImpl?, List<String>) _readFieldsFromConfig(Config config) {
    final errors = <String>[];

    var osSet = false;
    var ccSet = false;
    final versionString = config.optionalString('version');
    if (versionString == null) {
      errors.add('Missing version');
      return (null, errors);
    }
    final version = Version.parse(versionString);
    if (version.major > latestVersion.major) {
      errors.add(
        'The config version $version is newer than this '
        'package:native_assets_cli config version $latestVersion, '
        'please update native_assets_cli.',
      );
    }
    if (version.major < latestVersion.major) {
      errors.add(
        'The config version $version is newer than this '
        'package:native_assets_cli config version $latestVersion, '
        'please update the Dart or Flutter SDK.',
      );
    }
    final dryRun = config.optionalBool(HookConfigImpl.dryRunConfigKey) ?? false;
    final outDir = config.path(HookConfigImpl.outDirConfigKey, mustExist: true);
    final packageName = config.string(HookConfigImpl.packageNameConfigKey);

    final packageRoot =
        config.path(HookConfigImpl.packageRootConfigKey, mustExist: true);
    BuildModeImpl? buildMode;
    if (dryRun) {
      _throwIfNotNullInDryRun<String>(config, BuildModeImpl.configKey);
    } else {
      buildMode = BuildModeImpl.fromString(
        config.string(
          BuildModeImpl.configKey,
          validValues: BuildModeImpl.values.map((e) => '$e'),
        ),
      );
    }

    OSImpl? targetOS;
    final osString = config.optionalString(
      OSImpl.configKey,
      validValues: OSImpl.values.map((e) => '$e'),
    );
    if (osString != null) {
      osSet = true;
      targetOS = OSImpl.fromString(osString);
    } else {
      targetOS = null;
    }

    ArchitectureImpl? targetArchitecture;
    if (dryRun) {
      _throwIfNotNullInDryRun<String>(config, ArchitectureImpl.configKey);
      targetArchitecture = null;
    } else {
      final validArchitectures = [
        if (!osSet)
          ...ArchitectureImpl.values
        else
          for (final target in Target.values)
            if (target.os == targetOS) target.architecture
      ];
      targetArchitecture = ArchitectureImpl.fromString(
        config.string(
          ArchitectureImpl.configKey,
          validValues: validArchitectures.map((e) => '$e'),
        ),
      );
    }
    IOSSdkImpl? targetIOSSdk;
    if (dryRun) {
      _throwIfNotNullInDryRun<String>(config, IOSSdkImpl.configKey);
    } else {
      targetIOSSdk = (osSet && targetOS == OSImpl.iOS)
          ? IOSSdkImpl.fromString(
              config.string(
                IOSSdkImpl.configKey,
                validValues: IOSSdkImpl.values.map((e) => '$e'),
              ),
            )
          : null;
    }
    int? targetAndroidNdkApi;
    if (dryRun) {
      _throwIfNotNullInDryRun<int>(
          config, HookConfigImpl.targetAndroidNdkApiConfigKey);
    } else {
      targetAndroidNdkApi = (osSet && targetOS == OSImpl.android)
          ? config.int(HookConfigImpl.targetAndroidNdkApiConfigKey)
          : null;
    }
    final cCompiler = CCompilerConfigImpl();
    if (dryRun) {
      _throwIfNotNullInDryRun<int>(config, CCompilerConfigImpl.arConfigKeyFull);
    } else {
      cCompiler._archiver = config.optionalPath(
        CCompilerConfigImpl.arConfigKeyFull,
        mustExist: true,
      );
    }

    if (dryRun) {
      _throwIfNotNullInDryRun<int>(config, CCompilerConfigImpl.ccConfigKeyFull);
    } else {
      cCompiler._compiler = config.optionalPath(
        CCompilerConfigImpl.ccConfigKeyFull,
        mustExist: true,
      );
      ccSet = true;
    }

    if (dryRun) {
      _throwIfNotNullInDryRun<int>(config, CCompilerConfigImpl.ccConfigKeyFull);
    } else {
      cCompiler._linker = config.optionalPath(
        CCompilerConfigImpl.ldConfigKeyFull,
        mustExist: true,
      );
    }

    if (dryRun) {
      _throwIfNotNullInDryRun<int>(config, CCompilerConfigImpl.ccConfigKeyFull);
    } else {
      cCompiler._envScript = (ccSet &&
              cCompiler.compiler != null &&
              cCompiler.compiler!.toFilePath().endsWith('cl.exe'))
          ? config.path(CCompilerConfigImpl.envScriptConfigKeyFull,
              mustExist: true)
          : null;
    }

    if (dryRun) {
      _throwIfNotNullInDryRun<int>(config, CCompilerConfigImpl.ccConfigKeyFull);
    } else {
      cCompiler._envScriptArgs = config.optionalStringList(
        CCompilerConfigImpl.envScriptArgsConfigKeyFull,
        splitEnvironmentPattern: ' ',
      );
    }

    final linkModePreference = LinkModePreferenceImpl.fromString(
      config.string(
        LinkModePreferenceImpl.configKey,
        validValues: LinkModePreferenceImpl.values.map((e) => '$e'),
      ),
    );

    final dependencyMetadata = _readDependencyMetadataFromConfig(config);
    final supportedAssetTypes =
        config.optionalStringList(HookConfigImpl.supportedAssetTypesKey) ??
            [NativeCodeAsset.type];

    return (
      BuildConfigImpl._(
        outputDirectory: outDir,
        packageName: packageName,
        packageRoot: packageRoot,
        buildMode: buildMode!,
        cCompiler: cCompiler,
        supportedAssetTypes: supportedAssetTypes,
        targetAndroidNdkApi: targetAndroidNdkApi,
        targetArchitecture: targetArchitecture,
        targetIOSSdk: targetIOSSdk,
        targetOS: targetOS,
        linkMode: linkModePreference,
        dependencyMetadata: dependencyMetadata,
        dryRun: dryRun,
      ),
      errors,
    );
  }

  static Map<String, Metadata>? _readDependencyMetadataFromConfig(
      Config config) {
    final fileValue =
        config.valueOf<Map<Object?, Object?>?>(dependencyMetadataConfigKey);
    if (fileValue == null) {
      return null;
    }
    final result = <String, Metadata>{};
    for (final entry in fileValue.entries) {
      final packageName = as<String>(entry.key);
      final defines = entry.value;
      if (defines is! Map) {
        throw FormatException("Unexpected value '$defines' for key "
            "'$dependencyMetadataConfigKey.$packageName' in config file. "
            'Expected a Map.');
      }
      final packageResult = <String, Object>{};
      for (final entry2 in defines.entries) {
        final key = as<String>(entry2.key);
        final value = as<Object>(entry2.value);
        packageResult[key] = value;
      }
      result[packageName] = Metadata(packageResult.sortOnKey());
    }
    return result.sortOnKey();
  }

  static BuildConfigImpl fromJson(Map<String, dynamic> buildConfigJson) =>
      BuildConfigImpl._fromConfig(Config(fileParsed: buildConfigJson));

  @override
  Map<String, Object> toJson() {
    final json = super.toJson();
    return {
      ...json,
      LinkModePreferenceImpl.configKey: _linkModePreference.toString(),
      if (!dryRun) ...{
        if (_dependencyMetadata != null && _dependencyMetadata.isNotEmpty)
          dependencyMetadataConfigKey: {
            for (final entry in _dependencyMetadata.entries)
              entry.key: entry.value.toJson(),
          },
      },
    }.sortOnKey();
  }

  @override
  String toJsonString() => const JsonEncoder.withIndent('  ').convert(toJson());

  @override
  bool operator ==(Object other) {
    if (other is! BuildConfigImpl) {
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
      if (!const DeepCollectionEquality()
          .equals(other._dependencyMetadata, _dependencyMetadata)) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll([
        outputDirectory,
        packageName,
        packageRoot,
        targetOS,
        linkModePreference,
        dryRun,
        const DeepCollectionEquality().hash(supportedAssetTypes),
        if (!dryRun) ...[
          buildMode,
          const DeepCollectionEquality().hash(_dependencyMetadata),
          targetArchitecture,
          if (targetOS == OS.iOS) targetIOSSdk,
          targetAndroidNdkApi,
          cCompiler,
        ],
      ]);

  @override
  String toString() => 'BuildConfig.build(${toJson()})';

  void _ensureNotDryRun() {
    if (dryRun) {
      throw StateError('''This field is not available in dry runs.
In Flutter projects, native builds are generated per OS which target multiple
architectures, build modes, etc. Therefore, the list of native assets produced
can _only_ depend on OS.''');
    }
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
}
