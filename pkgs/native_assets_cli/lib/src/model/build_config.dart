// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:cli_config/cli_config.dart';
import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';
import 'package:pub_semver/pub_semver.dart';

import '../utils/map.dart';
import '../utils/yaml.dart';
import 'build_mode.dart';
import 'ios_sdk.dart';
import 'link_mode_preference.dart';
import 'metadata.dart';
import 'target.dart';

class BuildConfig {
  /// The folder in which all output and intermediate artifacts should be
  /// placed.
  Uri get outDir => _outDir;
  late final Uri _outDir;

  /// The root of the package the native assets are built for.
  ///
  /// Often a package's native assets are built because a package is a
  /// dependency of another. For this it is convenient to know the packageRoot.
  Uri get packageRoot => _packageRoot;
  late final Uri _packageRoot;

  /// The target that is being compiled for.
  Target get target => _target;
  late final Target _target;

  /// When compiling for iOS, whether to target device or simulator.
  ///
  /// Required when [target.os] equals [OS.iOS].
  IOSSdk? get targetIOSSdk => _targetIOSSdk;
  late final IOSSdk? _targetIOSSdk;

  /// When compiling for Android, the API version to target.
  ///
  /// Required when [target.os] equals [OS.android].
  int? get targetAndroidNdkApi => _targetAndroidNdkApi;
  late final int? _targetAndroidNdkApi;

  /// Preferred linkMode method for library.
  LinkModePreference get linkModePreference => _linkModePreference;
  late final LinkModePreference _linkModePreference;

  /// Metadata from direct dependencies.
  ///
  /// The key in the map is the package name of the dependency.
  ///
  /// The key in the nested map is the key for the metadata from the dependency.
  Map<String, Metadata>? get dependencyMetadata => _dependencyMetadata;
  late final Map<String, Metadata>? _dependencyMetadata;

  /// The configuration for invoking the C compiler.
  CCompilerConfig get cCompiler => _cCompiler;
  late final CCompilerConfig _cCompiler;

  /// Don't run the build, only report the native assets produced.
  bool get dryRun => _dryRun ?? false;
  late final bool? _dryRun;

  /// The build mode that the code should be compiled in.
  BuildMode get buildMode => _buildMode;
  late final BuildMode _buildMode;

  /// The underlying config.
  ///
  /// Can be used for easier access to values on [dependencyMetadata].
  Config get config => _config;
  late final Config _config;

  factory BuildConfig({
    required Uri outDir,
    required Uri packageRoot,
    required BuildMode buildMode,
    required Target target,
    IOSSdk? targetIOSSdk,
    int? targetAndroidNdkApi,
    CCompilerConfig? cCompiler,
    required LinkModePreference linkModePreference,
    Map<String, Metadata>? dependencyMetadata,
    bool? dryRun,
  }) {
    final nonValidated = BuildConfig._()
      .._outDir = outDir
      .._packageRoot = packageRoot
      .._buildMode = buildMode
      .._target = target
      .._targetIOSSdk = targetIOSSdk
      .._targetAndroidNdkApi = targetAndroidNdkApi
      .._cCompiler = cCompiler ?? CCompilerConfig()
      .._linkModePreference = linkModePreference
      .._dependencyMetadata = dependencyMetadata
      .._dryRun = dryRun;
    final parsedConfigFile = nonValidated.toYaml();
    final config = Config(fileParsed: parsedConfigFile);
    return BuildConfig.fromConfig(config);
  }

  /// Constructs a checksum for a [BuildConfig] based on the fields
  /// of a buildconfig that influence the build.
  ///
  /// This can be used for an [outDir], but should not be used for dry-runs.
  ///
  /// In particular, it only takes the package name from [packageRoot],
  /// so that the hash is equal across checkouts and ignores [outDir] itself.
  static String checksum({
    required Uri packageRoot,
    required Target target,
    required BuildMode buildMode,
    IOSSdk? targetIOSSdk,
    int? targetAndroidNdkApi,
    CCompilerConfig? cCompiler,
    required LinkModePreference linkModePreference,
    Map<String, Metadata>? dependencyMetadata,
  }) {
    final packageName = packageRoot.pathSegments.lastWhere((e) => e.isNotEmpty);
    final input = [
      packageName,
      target.toString(),
      targetIOSSdk.toString(),
      targetAndroidNdkApi.toString(),
      buildMode.toString(),
      linkModePreference.toString(),
      cCompiler?.ar.toString(),
      cCompiler?.cc.toString(),
      cCompiler?.envScript.toString(),
      cCompiler?.envScriptArgs.toString(),
      cCompiler?.ld.toString(),
      if (dependencyMetadata != null)
        for (final entry in dependencyMetadata.entries) ...[
          entry.key,
          json.encode(entry.value.toYaml()),
        ]
    ].join('###');
    final sha256String = sha256.convert(utf8.encode(input)).toString();
    // 256 bit hashes lead to 64 hex character strings.
    // To avoid overflowing file paths limits, only use 32.
    // Using 16 hex characters would also be unlikely to have collisions.
    const nameLength = 32;
    return sha256String.substring(0, nameLength);
  }

  BuildConfig._();

  /// The version of [BuildConfig].
  ///
  /// This class is used in the protocol between the Dart and Flutter SDKs
  /// and packages through `build.dart` invocations.
  ///
  /// If we ever were to make breaking changes, it would be useful to give
  /// proper error messages rather than just fail to parse the YAML
  /// representation in the protocol.
  static Version version = Version(1, 0, 0);

  factory BuildConfig.fromConfig(Config config) {
    final result = BuildConfig._().._cCompiler = CCompilerConfig._();
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
      throw FormatException('Configuration is not in the right format. '
          'FormatExceptions: $configExceptions');
    }

    return result;
  }

  /// Constructs a config by parsing CLI arguments and loading the config file.
  ///
  /// The [args] must be commandline arguments.
  ///
  /// If provided, [environment] must be a map containing environment variables.
  /// If not provided, [environment] defaults to [Platform.environment].
  ///
  /// If provided, [workingDirectory] is used to resolves paths inside
  /// [environment].
  /// If not provided, [workingDirectory] defaults to [Directory.current].
  ///
  /// This async constructor is intended to be used directly in CLI files.
  static Future<BuildConfig> fromArgs(
    List<String> args, {
    Map<String, String>? environment,
    Uri? workingDirectory,
  }) async {
    final config = await Config.fromArgs(
      args: args,
      environment: environment,
      workingDirectory: workingDirectory,
    );
    return BuildConfig.fromConfig(config);
  }

  static const outDirConfigKey = 'out_dir';
  static const packageRootConfigKey = 'package_root';
  static const dependencyMetadataConfigKey = 'dependency_metadata';
  static const _versionKey = 'version';
  static const targetAndroidNdkApiConfigKey = 'target_android_ndk_api';
  static const dryRunConfigKey = 'dry_run';

  List<void Function(Config)> _readFieldsFromConfig() {
    var targetSet = false;
    var ccSet = false;
    return [
      (config) {
        final configVersion = Version.parse(config.string('version'));
        if (configVersion.major > version.major) {
          throw FormatException(
            'The config version $configVersion is newer than this '
            'package:native_assets_cli config version $version, '
            'please update native_assets_cli.',
          );
        }
        if (configVersion.major < version.major) {
          throw FormatException(
            'The config version $configVersion is newer than this '
            'package:native_assets_cli config version $version, '
            'please update the Dart or Flutter SDK.',
          );
        }
      },
      (config) => _config = config,
      (config) => _outDir = config.path(outDirConfigKey, mustExist: true),
      (config) =>
          _packageRoot = config.path(packageRootConfigKey, mustExist: true),
      (config) => _buildMode = BuildMode.fromString(
            config.string(
              BuildMode.configKey,
              validValues: BuildMode.values.map((e) => '$e'),
            ),
          ),
      (config) {
        _target = Target.fromString(
          config.string(
            Target.configKey,
            validValues: Target.values.map((e) => '$e'),
          ),
        );
        targetSet = true;
      },
      (config) => _targetIOSSdk = (targetSet && _target.os == OS.iOS)
          ? IOSSdk.fromString(
              config.string(
                IOSSdk.configKey,
                validValues: IOSSdk.values.map((e) => '$e'),
              ),
            )
          : null,
      (config) => _targetAndroidNdkApi = (targetSet && _target.os == OS.android)
          ? config.int(targetAndroidNdkApiConfigKey)
          : null,
      (config) => cCompiler._ar =
          config.optionalPath(CCompilerConfig.arConfigKeyFull, mustExist: true),
      (config) {
        cCompiler._cc = config.optionalPath(CCompilerConfig.ccConfigKeyFull,
            mustExist: true);
        ccSet = true;
      },
      (config) => cCompiler._ld =
          config.optionalPath(CCompilerConfig.ldConfigKeyFull, mustExist: true),
      (config) => cCompiler._envScript = (ccSet &&
              cCompiler.cc != null &&
              cCompiler.cc!.toFilePath().endsWith('cl.exe'))
          ? config.path(CCompilerConfig.envScriptConfigKeyFull, mustExist: true)
          : null,
      (config) => cCompiler._envScriptArgs = config.optionalStringList(
            CCompilerConfig.envScriptArgsConfigKeyFull,
            splitEnvironmentPattern: ' ',
          ),
      (config) => _linkModePreference = LinkModePreference.fromString(
            config.string(
              LinkModePreference.configKey,
              validValues: LinkModePreference.values.map((e) => '$e'),
            ),
          ),
      (config) =>
          _dependencyMetadata = _readDependencyMetadataFromConfig(config),
      (config) => _dryRun = config.optionalBool(dryRunConfigKey),
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
      final packageName = entry.key;
      final defines = entry.value;
      if (defines is! Map) {
        throw FormatException("Unexpected value '$defines' for key "
            "'$dependencyMetadataConfigKey.$packageName' in config file. "
            'Expected a Map.');
      }
      final packageResult = <String, Object>{};
      for (final entry2 in defines.entries) {
        final key = entry2.key;
        assert(key is String);
        final value = entry2.value;
        assert(value != null);
        packageResult[key as String] = value as Object;
      }
      result[packageName as String] = Metadata(packageResult.sortOnKey());
    }
    return result.sortOnKey();
  }

  Map<String, Object> toYaml() {
    final cCompilerYaml = _cCompiler.toYaml();

    return {
      outDirConfigKey: _outDir.toFilePath(),
      packageRootConfigKey: _packageRoot.toFilePath(),
      BuildMode.configKey: _buildMode.toString(),
      Target.configKey: _target.toString(),
      if (_targetIOSSdk != null) IOSSdk.configKey: _targetIOSSdk.toString(),
      if (_targetAndroidNdkApi != null)
        targetAndroidNdkApiConfigKey: _targetAndroidNdkApi!,
      if (cCompilerYaml.isNotEmpty) CCompilerConfig.configKey: cCompilerYaml,
      LinkModePreference.configKey: _linkModePreference.toString(),
      if (_dependencyMetadata != null)
        dependencyMetadataConfigKey: {
          for (final entry in _dependencyMetadata!.entries)
            entry.key: entry.value.toYaml(),
        },
      if (dryRun) dryRunConfigKey: dryRun,
      _versionKey: version.toString(),
    }.sortOnKey();
  }

  String toYamlString() => yamlEncode(toYaml());

  @override
  bool operator ==(Object other) {
    if (other is! BuildConfig) {
      return false;
    }
    if (other._outDir != _outDir) return false;
    if (other._packageRoot != _packageRoot) return false;
    if (other._buildMode != _buildMode) return false;
    if (other._target != _target) return false;
    if (other._targetIOSSdk != _targetIOSSdk) return false;
    if (other._targetAndroidNdkApi != _targetAndroidNdkApi) return false;
    if (other._cCompiler != _cCompiler) return false;
    if (other._linkModePreference != _linkModePreference) return false;
    if (!DeepCollectionEquality()
        .equals(other._dependencyMetadata, _dependencyMetadata)) return false;
    if (other.dryRun != dryRun) return false;
    return true;
  }

  @override
  int get hashCode => Object.hash(
        _outDir,
        _packageRoot,
        _buildMode,
        _target,
        _targetIOSSdk,
        _targetAndroidNdkApi,
        _cCompiler,
        _linkModePreference,
        DeepCollectionEquality().hash(_dependencyMetadata),
        dryRun,
      );

  @override
  String toString() => 'BuildConfig(${toYaml()})';
}

class CCompilerConfig {
  /// Path to a C compiler.
  Uri? get cc => _cc;
  late final Uri? _cc;

  /// Path to a native linker.
  Uri? get ld => _ld;
  late final Uri? _ld;

  /// Path to a native archiver.
  Uri? get ar => _ar;
  late final Uri? _ar;

  /// Path to script that sets environment variables for [cc], [ld], and [ar].
  Uri? get envScript => _envScript;
  late final Uri? _envScript;

  /// Arguments for [envScript].
  List<String>? get envScriptArgs => _envScriptArgs;
  late final List<String>? _envScriptArgs;

  factory CCompilerConfig({
    Uri? ar,
    Uri? cc,
    Uri? ld,
    Uri? envScript,
    List<String>? envScriptArgs,
  }) =>
      CCompilerConfig._()
        .._ar = ar
        .._cc = cc
        .._ld = ld
        .._envScript = envScript
        .._envScriptArgs = envScriptArgs;

  CCompilerConfig._();

  static const configKey = 'c_compiler';
  static const arConfigKey = 'ar';
  static const arConfigKeyFull = '$configKey.$arConfigKey';
  static const ccConfigKey = 'cc';
  static const ccConfigKeyFull = '$configKey.$ccConfigKey';
  static const ldConfigKey = 'ld';
  static const ldConfigKeyFull = '$configKey.$ldConfigKey';
  static const envScriptConfigKey = 'env_script';
  static const envScriptConfigKeyFull = '$configKey.$envScriptConfigKey';
  static const envScriptArgsConfigKey = 'env_script_arguments';
  static const envScriptArgsConfigKeyFull =
      '$configKey.$envScriptArgsConfigKey';

  Map<String, Object> toYaml() => {
        if (_ar != null) arConfigKey: _ar!.toFilePath(),
        if (_cc != null) ccConfigKey: _cc!.toFilePath(),
        if (_ld != null) ldConfigKey: _ld!.toFilePath(),
        if (_envScript != null) envScriptConfigKey: _envScript!.toFilePath(),
        if (_envScriptArgs != null) envScriptArgsConfigKey: _envScriptArgs!,
      }.sortOnKey();

  @override
  bool operator ==(Object other) {
    if (other is! CCompilerConfig) {
      return false;
    }
    if (other._ar != _ar) return false;
    if (other._cc != _cc) return false;
    if (other._ld != _ld) return false;
    if (other.envScript != envScript) return false;
    if (!ListEquality<String>().equals(other.envScriptArgs, envScriptArgs)) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        _ar,
        _cc,
        _ld,
        _envScript,
        ListEquality<String>().hash(envScriptArgs),
      );
}
