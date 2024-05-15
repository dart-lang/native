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
      version > Version(1, 1, 0) ? 'build_output.json' : outputNameV1_1_0;

  @override
  String get outputNameV1_1_0 => 'build_output.yaml';

  @override
  Object? metadatum(String packageName, String key) {
    HookConfigImpl.ensureNotDryRun(dryRun);
    return _dependencyMetadata?[packageName]?.metadata[key];
  }

  final Map<String, Metadata>? _dependencyMetadata;

  static List<String> _supportedAssetTypesBackwardsCompatibility(
    Iterable<String>? supportedAssetTypes,
  ) =>
      supportedAssetTypes?.toList() ?? [NativeCodeAsset.type];

  BuildConfigImpl({
    required super.outputDirectory,
    required super.packageName,
    required super.packageRoot,
    Version? version,
    super.buildMode,
    super.cCompiler,
    Iterable<String>? supportedAssetTypes,
    super.targetAndroidNdkApi,
    required super.targetArchitecture,
    super.targetIOSSdk,
    required super.targetOS,
    required super.linkModePreference,
    Map<String, Metadata>? dependencyMetadata,
    super.dryRun,
  })  : _dependencyMetadata = dependencyMetadata,
        super(
          hook: Hook.build,
          version: version ?? HookConfigImpl.latestVersion,
          supportedAssetTypes:
              _supportedAssetTypesBackwardsCompatibility(supportedAssetTypes),
        );

  BuildConfigImpl.dryRun({
    required super.outputDirectory,
    required super.packageName,
    required super.packageRoot,
    required super.targetOS,
    required super.linkModePreference,
    Iterable<String>? supportedAssetTypes,
  })  : _dependencyMetadata = null,
        super.dryRun(
          hook: Hook.build,
          version: HookConfigImpl.latestVersion,
          supportedAssetTypes:
              _supportedAssetTypesBackwardsCompatibility(supportedAssetTypes),
        );

  factory BuildConfigImpl._fromConfig(Config config) =>
      _readFieldsFromConfig(config);

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

  static BuildConfigImpl _readFieldsFromConfig(Config config) {
    final dryRun = HookConfigImpl.parseDryRun(config) ?? false;
    final targetOS = HookConfigImpl.parseTargetOS(config);
    return BuildConfigImpl(
      outputDirectory: HookConfigImpl.parseOutDir(config),
      packageName: HookConfigImpl.parsePackageName(config),
      packageRoot: HookConfigImpl.parsePackageRoot(config),
      buildMode: HookConfigImpl.parseBuildMode(config, dryRun),
      targetOS: targetOS,
      targetArchitecture:
          HookConfigImpl.parseTargetArchitecture(config, dryRun, targetOS),
      linkModePreference: HookConfigImpl.parseLinkModePreference(config),
      dependencyMetadata: parseDependencyMetadata(config),
      version: HookConfigImpl.parseVersion(config),
      cCompiler: HookConfigImpl.parseCCompiler(config, dryRun),
      supportedAssetTypes: HookConfigImpl.parseSupportedAssetTypes(config),
      targetAndroidNdkApi:
          HookConfigImpl.parseTargetAndroidNdkApi(config, dryRun, targetOS),
      targetIOSSdk: HookConfigImpl.parseTargetIOSSdk(config, dryRun, targetOS),
      dryRun: dryRun,
    );
  }

  static Map<String, Metadata>? parseDependencyMetadata(Config config) =>
      _readDependencyMetadataFromConfig(config);

  static Map<String, Metadata>? _readDependencyMetadataFromConfig(
      Config config) {
    final fileValue =
        config.valueOf<Map<Object?, Object?>?>(dependencyMetadataConfigKey);
    if (fileValue == null) {
      return null;
    }
    return fileValue
        .map((key, defines) => MapEntry(as<String>(key), defines))
        .map(
      (packageName, defines) {
        if (defines is! Map) {
          throw FormatException("Unexpected value '$defines' for key "
              "'$dependencyMetadataConfigKey.$packageName' in config file. "
              'Expected a Map.');
        }
        return MapEntry(
          packageName,
          Metadata(defines
              .map((key, value) => MapEntry(as<String>(key), as<Object>(value)))
              .sortOnKey()),
        );
      },
    ).sortOnKey();
  }

  static BuildConfigImpl fromJson(Map<String, dynamic> buildConfigJson) =>
      BuildConfigImpl._fromConfig(Config(fileParsed: buildConfigJson));

  @override
  Map<String, Object> toJson() => {
        ...hookToJson(),
        if (!dryRun) ...{
          if (_dependencyMetadata != null && _dependencyMetadata.isNotEmpty)
            dependencyMetadataConfigKey: _dependencyMetadata.map(
              (packageName, metadata) =>
                  MapEntry(packageName, metadata.toJson()),
            ),
        },
      }.sortOnKey();

  @override
  bool operator ==(Object other) {
    if (super != other) {
      return false;
    }
    if (other is! BuildConfigImpl) {
      return false;
    }
    if (!dryRun &&
        !const DeepCollectionEquality()
            .equals(other._dependencyMetadata, _dependencyMetadata)) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll([
        super.hashCode,
        linkModePreference,
        if (!dryRun) ...[
          const DeepCollectionEquality().hash(_dependencyMetadata),
        ],
      ]);

  @override
  String toString() => 'BuildConfig(${toJson()})';
}
