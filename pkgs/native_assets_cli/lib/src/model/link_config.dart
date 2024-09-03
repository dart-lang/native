// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../api/link_config.dart';

/// The input to the linking script.
///
/// It consists of the fields inherited from the [HookConfig] and the [assets]
/// from the build step.
class LinkConfigImpl extends HookConfigImpl implements LinkConfig {
  static const resourceIdentifierKey = 'resource_identifiers';

  static const assetsKey = 'assets';

  @override
  final Iterable<AssetImpl> assets;

  // TODO: Placeholder for the resources.json file URL. We don't want to change
  // native_assets_builder when implementing the parsing.
  @override
  final Uri? recordedUsages;

  LinkConfigImpl({
    required this.assets,
    this.recordedUsages,
    required super.outputDirectory,
    required super.packageName,
    required super.packageRoot,
    Version? version,
    required super.buildMode,
    super.cCompiler,
    Iterable<String>? supportedAssetTypes,
    super.targetAndroidNdkApi,
    super.targetArchitecture,
    super.targetIOSSdk,
    super.targetIOSVersion,
    super.targetMacOSVersion,
    required super.targetOS,
    required super.linkModePreference,
    super.dryRun,
  }) : super(
          hook: Hook.link,
          version: version ?? HookConfigImpl.latestVersion,
          supportedAssetTypes: supportedAssetTypes ?? [NativeCodeAsset.type],
        );

  LinkConfigImpl.dryRun({
    required this.assets,
    this.recordedUsages,
    required super.outputDirectory,
    required super.packageName,
    required super.packageRoot,
    Version? version,
    Iterable<String>? supportedAssetTypes,
    required super.linkModePreference,
    required super.targetOS,
  }) : super.dryRun(
          hook: Hook.link,
          version: version ?? HookConfigImpl.latestVersion,
          supportedAssetTypes: supportedAssetTypes ?? [NativeCodeAsset.type],
        );

  @override
  Hook get hook => Hook.link;

  @override
  String get outputName => 'link_output.json';

  @override
  String? get outputNameV1_1_0 => null;

  @override
  Map<String, Object> toJson() => {
        ...hookToJson(),
        if (recordedUsages != null)
          resourceIdentifierKey: recordedUsages!.toFilePath(),
        assetsKey: AssetImpl.listToJson(assets, version),
      }.sortOnKey();

  static LinkConfig fromArguments(List<String> arguments) {
    final argParser = ArgParser()..addOption('config');

    final results = argParser.parse(arguments);
    final linkConfigContents =
        File(results['config'] as String).readAsStringSync();
    final linkConfigJson =
        jsonDecode(linkConfigContents) as Map<String, dynamic>;

    return fromJson(linkConfigJson);
  }

  static LinkConfigImpl fromJson(Map<String, dynamic> linkConfigJson) {
    final config =
        Config.fromConfigFileContents(fileContents: jsonEncode(linkConfigJson));
    final dryRun = HookConfigImpl.parseDryRun(config) ?? false;
    final targetOS = HookConfigImpl.parseTargetOS(config);
    return LinkConfigImpl(
      outputDirectory: HookConfigImpl.parseOutDir(config),
      packageName: HookConfigImpl.parsePackageName(config),
      packageRoot: HookConfigImpl.parsePackageRoot(config),
      buildMode: HookConfigImpl.parseBuildMode(config, dryRun),
      targetOS: targetOS,
      targetArchitecture:
          HookConfigImpl.parseTargetArchitecture(config, dryRun, targetOS),
      linkModePreference: HookConfigImpl.parseLinkModePreference(config),
      version: HookConfigImpl.parseVersion(config),
      cCompiler: HookConfigImpl.parseCCompiler(config, dryRun),
      supportedAssetTypes: HookConfigImpl.parseSupportedAssetTypes(config),
      targetAndroidNdkApi:
          HookConfigImpl.parseTargetAndroidNdkApi(config, dryRun, targetOS),
      targetIOSSdk: HookConfigImpl.parseTargetIOSSdk(config, dryRun, targetOS),
      targetIOSVersion:
          HookConfigImpl.parseTargetIosVersion(config, dryRun, targetOS),
      targetMacOSVersion:
          HookConfigImpl.parseTargetMacOSVersion(config, dryRun, targetOS),
      assets: parseAssets(config),
      recordedUsages: parseRecordedUsagesUri(config),
      dryRun: dryRun,
    );
  }

  static Uri? parseRecordedUsagesUri(Config config) =>
      config.optionalPath(resourceIdentifierKey);

  static List<AssetImpl> parseAssets(Config config) =>
      AssetImpl.listFromJson(config.valueOf(assetsKey));

  @override
  bool operator ==(Object other) {
    if (super != other) {
      return false;
    }
    if (other is! LinkConfigImpl) {
      return false;
    }
    if (other.recordedUsages != recordedUsages) {
      return false;
    }
    if (!const DeepCollectionEquality().equals(other.assets, assets)) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll([
        super.hashCode,
        recordedUsages,
        const DeepCollectionEquality().hash(assets),
      ]);

  @override
  String toString() => 'LinkConfig(${toJson()})';
}
