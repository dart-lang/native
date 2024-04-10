// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../api/build_config.dart';

final class BuildConfigImpl extends HookConfigImpl implements BuildConfig {
  @override
  Uri get script {
    final hookScript =
        packageRoot.resolve('hook/').resolve(Hook.build.scriptName);
    if (File.fromUri(hookScript).existsSync()) {
      return hookScript;
    } else {
      return packageRoot.resolve(Hook.build.scriptName);
    }
  }

  @override
  String get outputName =>
      version > Version(1, 1, 0) ? 'build_output.json' : 'build_output.yaml';

  @override
  Uri get configFile => outputDirectory.resolve('../config.json');

  /// The folder in which all output and intermediate artifacts should be
  /// placed.
  @override
  Uri get outputDirectory => _outDir;
  late final Uri _outDir;

  @override
  String get packageName => _packageName;
  late final String _packageName;

  @override
  Uri get packageRoot => _packageRoot;
  late final Uri _packageRoot;

  @override
  ArchitectureImpl? get targetArchitecture => _targetArchitecture;
  late final ArchitectureImpl? _targetArchitecture;

  @override
  OSImpl get targetOS => _targetOS;
  late final OSImpl _targetOS;

  @override
  IOSSdkImpl get targetIOSSdk {
    _ensureNotDryRun();
    if (_targetOS != OS.iOS) {
      throw StateError(
        'This field is not available in if targetOS is not OS.iOS.',
      );
    }
    return _targetIOSSdk!;
  }

  late final IOSSdkImpl? _targetIOSSdk;

  @override
  int? get targetAndroidNdkApi {
    _ensureNotDryRun();
    return _targetAndroidNdkApi;
  }

  late final int? _targetAndroidNdkApi;

  @override
  LinkModePreferenceImpl get linkModePreference => _linkModePreference;
  late final LinkModePreferenceImpl _linkModePreference;

  @override
  Object? metadatum(String packageName, String key) {
    _ensureNotDryRun();
    return _dependencyMetadata?[packageName]?.metadata[key];
  }

  late final Map<String, Metadata>? _dependencyMetadata;

  @override
  CCompilerConfigImpl get cCompiler {
    _ensureNotDryRun();
    return _cCompiler;
  }

  late final CCompilerConfigImpl _cCompiler;

  @override
  bool get dryRun => _dryRun ?? false;
  late final bool? _dryRun;

  @override
  BuildModeImpl get buildMode {
    _ensureNotDryRun();
    return _buildMode;
  }

  late final BuildModeImpl _buildMode;

  @override
  Iterable<String> get supportedAssetTypes => _supportedAssetTypes;

  late final List<String> _supportedAssetTypes;

  @override
  Version get version => _version;

  late final Version _version;

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
  }) {
    final nonValidated = BuildConfigImpl._()
      .._version = version ?? latestVersion
      .._outDir = outDir
      .._packageName = packageName
      .._packageRoot = packageRoot
      .._buildMode = buildMode
      .._targetArchitecture = targetArchitecture
      .._targetOS = targetOS
      .._targetIOSSdk = targetIOSSdk
      .._targetAndroidNdkApi = targetAndroidNdkApi
      .._cCompiler = cCompiler ?? CCompilerConfigImpl()
      .._linkModePreference = linkModePreference
      .._dependencyMetadata = dependencyMetadata
      .._dryRun = false
      .._supportedAssetTypes =
          _supportedAssetTypesBackwardsCompatibility(supportedAssetTypes);
    final parsedConfigFile = nonValidated.toJson();
    final config = Config(fileParsed: parsedConfigFile);
    return BuildConfigImpl.fromConfig(config);
  }

  factory BuildConfigImpl.dryRun({
    required Uri outDir,
    required String packageName,
    required Uri packageRoot,
    required OSImpl targetOS,
    required LinkModePreferenceImpl linkModePreference,
    Iterable<String>? supportedAssetTypes,
  }) {
    final nonValidated = BuildConfigImpl._()
      .._version = latestVersion
      .._outDir = outDir
      .._packageName = packageName
      .._packageRoot = packageRoot
      .._targetOS = targetOS
      .._targetArchitecture = null
      .._linkModePreference = linkModePreference
      .._cCompiler = CCompilerConfigImpl()
      .._dryRun = true
      .._supportedAssetTypes =
          _supportedAssetTypesBackwardsCompatibility(supportedAssetTypes);
    final parsedConfigFile = nonValidated.toJson();
    final config = Config(fileParsed: parsedConfigFile);
    return BuildConfigImpl.fromConfig(config);
  }

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

  BuildConfigImpl._();

  /// The version of [BuildConfigImpl].
  ///
  /// This class is used in the protocol between the Dart and Flutter SDKs
  /// and packages through build hook invocations.
  ///
  /// If we ever were to make breaking changes, it would be useful to give
  /// proper error messages rather than just fail to parse the JSON
  /// representation in the protocol.
  static Version latestVersion = Version(1, 3, 0);

  factory BuildConfigImpl.fromConfig(Config config) {
    final result = BuildConfigImpl._().._cCompiler = CCompilerConfigImpl._();
    final configExceptions = <Object>[];
    for (final f in result._readFieldsFromConfig()) {
      try {
        f(config);
      } on FormatException catch (e, st) {
        configExceptions.add(e);
        configExceptions.add(st);
      }
    }

    if (configExceptions.isNotEmpty) {
      throw FormatException('BuildConfig is not in the right format. '
          'FormatExceptions: $configExceptions');
    }

    return result;
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
    return BuildConfigImpl.fromConfig(config);
  }

  static const outDirConfigKey = 'out_dir';
  static const packageNameConfigKey = 'package_name';
  static const packageRootConfigKey = 'package_root';
  static const dependencyMetadataConfigKey = 'dependency_metadata';
  static const _versionKey = 'version';
  static const targetAndroidNdkApiConfigKey = 'target_android_ndk_api';
  static const dryRunConfigKey = 'dry_run';
  static const supportedAssetTypesKey = 'supported_asset_types';

  List<void Function(Config)> _readFieldsFromConfig() {
    var osSet = false;
    var ccSet = false;
    return [
      (config) {
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
        _version = version;
      },
      (config) => _config = config,
      (config) => _dryRun = config.optionalBool(dryRunConfigKey),
      (config) => _outDir = config.path(outDirConfigKey, mustExist: true),
      (config) => _packageName = config.string(packageNameConfigKey),
      (config) =>
          _packageRoot = config.path(packageRootConfigKey, mustExist: true),
      (config) {
        if (dryRun) {
          _throwIfNotNullInDryRun<String>(BuildModeImpl.configKey);
        } else {
          _buildMode = BuildModeImpl.fromString(
            config.string(
              BuildModeImpl.configKey,
              validValues: BuildModeImpl.values.map((e) => '$e'),
            ),
          );
        }
      },
      (config) {
        _targetOS = OSImpl.fromString(
          config.string(
            OSImpl.configKey,
            validValues: OSImpl.values.map((e) => '$e'),
          ),
        );
        osSet = true;
      },
      (config) {
        if (dryRun) {
          _throwIfNotNullInDryRun<String>(ArchitectureImpl.configKey);
          _targetArchitecture = null;
        } else {
          final validArchitectures = [
            if (!osSet)
              ...ArchitectureImpl.values
            else
              for (final target in Target.values)
                if (target.os == _targetOS) target.architecture
          ];
          _targetArchitecture = ArchitectureImpl.fromString(
            config.string(
              ArchitectureImpl.configKey,
              validValues: validArchitectures.map((e) => '$e'),
            ),
          );
        }
      },
      (config) {
        if (dryRun) {
          _throwIfNotNullInDryRun<String>(IOSSdkImpl.configKey);
        } else {
          _targetIOSSdk = (osSet && _targetOS == OSImpl.iOS)
              ? IOSSdkImpl.fromString(
                  config.string(
                    IOSSdkImpl.configKey,
                    validValues: IOSSdkImpl.values.map((e) => '$e'),
                  ),
                )
              : null;
        }
      },
      (config) {
        if (dryRun) {
          _throwIfNotNullInDryRun<int>(targetAndroidNdkApiConfigKey);
        } else {
          _targetAndroidNdkApi = (osSet && _targetOS == OSImpl.android)
              ? config.int(targetAndroidNdkApiConfigKey)
              : null;
        }
      },
      (config) {
        if (dryRun) {
          _throwIfNotNullInDryRun<int>(CCompilerConfigImpl.arConfigKeyFull);
        } else {
          cCompiler._archiver = config.optionalPath(
            CCompilerConfigImpl.arConfigKeyFull,
            mustExist: true,
          );
        }
      },
      (config) {
        if (dryRun) {
          _throwIfNotNullInDryRun<int>(CCompilerConfigImpl.ccConfigKeyFull);
        } else {
          cCompiler._compiler = config.optionalPath(
            CCompilerConfigImpl.ccConfigKeyFull,
            mustExist: true,
          );
          ccSet = true;
        }
      },
      (config) {
        if (dryRun) {
          _throwIfNotNullInDryRun<int>(CCompilerConfigImpl.ccConfigKeyFull);
        } else {
          cCompiler._linker = config.optionalPath(
            CCompilerConfigImpl.ldConfigKeyFull,
            mustExist: true,
          );
        }
      },
      (config) {
        if (dryRun) {
          _throwIfNotNullInDryRun<int>(CCompilerConfigImpl.ccConfigKeyFull);
        } else {
          cCompiler._envScript = (ccSet &&
                  cCompiler.compiler != null &&
                  cCompiler.compiler!.toFilePath().endsWith('cl.exe'))
              ? config.path(CCompilerConfigImpl.envScriptConfigKeyFull,
                  mustExist: true)
              : null;
        }
      },
      (config) {
        if (dryRun) {
          _throwIfNotNullInDryRun<int>(CCompilerConfigImpl.ccConfigKeyFull);
        } else {
          cCompiler._envScriptArgs = config.optionalStringList(
            CCompilerConfigImpl.envScriptArgsConfigKeyFull,
            splitEnvironmentPattern: ' ',
          );
        }
      },
      (config) {
        _linkModePreference = LinkModePreferenceImpl.fromString(
          config.string(
            LinkModePreferenceImpl.configKey,
            validValues: LinkModePreferenceImpl.values.map((e) => '$e'),
          ),
        );
      },
      (config) {
        _dependencyMetadata = _readDependencyMetadataFromConfig(config);
      },
      (config) => _supportedAssetTypes =
          config.optionalStringList(supportedAssetTypesKey) ??
              [NativeCodeAsset.type],
    ];
  }

  Map<String, Metadata>? _readDependencyMetadataFromConfig(Config config) {
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
      BuildConfigImpl.fromConfig(Config(fileParsed: buildConfigJson));

  Map<String, Object> toJson() {
    late Map<String, Object> cCompilerJson;
    if (!dryRun) {
      cCompilerJson = _cCompiler.toJson();
    }

    return {
      outDirConfigKey: _outDir.toFilePath(),
      packageNameConfigKey: _packageName,
      packageRootConfigKey: _packageRoot.toFilePath(),
      OSImpl.configKey: _targetOS.toString(),
      LinkModePreferenceImpl.configKey: _linkModePreference.toString(),
      if (_supportedAssetTypes.isNotEmpty)
        supportedAssetTypesKey: _supportedAssetTypes,
      _versionKey: version.toString(),
      if (dryRun) dryRunConfigKey: dryRun,
      if (!dryRun) ...{
        BuildModeImpl.configKey: _buildMode.toString(),
        ArchitectureImpl.configKey: _targetArchitecture.toString(),
        if (_targetIOSSdk != null)
          IOSSdkImpl.configKey: _targetIOSSdk.toString(),
        if (_targetAndroidNdkApi != null)
          targetAndroidNdkApiConfigKey: _targetAndroidNdkApi,
        if (cCompilerJson.isNotEmpty)
          CCompilerConfigImpl.configKey: cCompilerJson,
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
        .equals(other._supportedAssetTypes, _supportedAssetTypes)) return false;
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
        const DeepCollectionEquality().hash(_supportedAssetTypes),
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

  void _throwIfNotNullInDryRun<T>(String key) {
    final object = config.valueOf<T?>(key);
    if (object != null) {
      throw const FormatException('''This field is not available in dry runs.
In Flutter projects, native builds are generated per OS which target multiple
architectures, build modes, etc. Therefore, the list of native assets produced
can _only_ depend on OS.''');
    }
  }
}
