// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../api/link_config.dart';

/// The input to the linking script.
///
/// It consists of the fields inherited from the [HookConfig] and the
/// [encodedAssets] from the build step.
class LinkConfigImpl extends HookConfigImpl implements LinkConfig {
  static const resourceIdentifierKey = 'resource_identifiers';

  static const assetsKey = 'assets';

  @override
  final Iterable<EncodedAsset> encodedAssets;

  // TODO: Placeholder for the resources.json file URL. We don't want to change
  // native_assets_builder when implementing the parsing.
  @override
  final Uri? recordedUsagesFile;

  LinkConfigImpl({
    required this.encodedAssets,
    this.recordedUsagesFile,
    required super.outputDirectory,
    required super.outputDirectoryShared,
    required super.packageName,
    required super.packageRoot,
    Version? version,
    required super.buildMode,
    super.cCompiler,
    required super.supportedAssetTypes,
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
        );

  LinkConfigImpl.dryRun({
    required this.encodedAssets,
    this.recordedUsagesFile,
    required super.outputDirectory,
    required super.outputDirectoryShared,
    required super.packageName,
    required super.packageRoot,
    Version? version,
    required super.supportedAssetTypes,
    required super.linkModePreference,
    required super.targetOS,
  }) : super.dryRun(
          hook: Hook.link,
          version: version ?? HookConfigImpl.latestVersion,
        );

  @override
  Hook get hook => Hook.link;

  @override
  String get outputName => 'link_output.json';

  @override
  Map<String, Object> toJson() => {
        ...hookToJson(),
        if (recordedUsagesFile != null)
          resourceIdentifierKey: recordedUsagesFile!.toFilePath(),
        if (encodedAssets.isNotEmpty)
          assetsKey: [
            for (final asset in encodedAssets) asset.toJson(),
          ],
      }.sortOnKey();

  static LinkConfig fromArguments(List<String> arguments) {
    final configPath = getConfigArgument(arguments);
    final bytes = File(configPath).readAsBytesSync();
    final linkConfigJson = const Utf8Decoder()
        .fuse(const JsonDecoder())
        .convert(bytes) as Map<String, Object?>;
    return fromJson(linkConfigJson);
  }

  static LinkConfigImpl fromJson(Map<String, Object?> config) {
    final dryRun = HookConfigImpl.parseDryRun(config) ?? false;
    final targetOS = HookConfigImpl.parseTargetOS(config);
    return LinkConfigImpl(
      outputDirectory: HookConfigImpl.parseOutDir(config),
      outputDirectoryShared: HookConfigImpl.parseOutDirShared(config),
      packageName: HookConfigImpl.parsePackageName(config),
      packageRoot: HookConfigImpl.parsePackageRoot(config),
      buildMode: HookConfigImpl.parseBuildMode(config, dryRun),
      targetOS: targetOS,
      targetArchitecture:
          HookConfigImpl.parseTargetArchitecture(config, dryRun, targetOS),
      linkModePreference: HookConfigImpl.parseLinkModePreference(config),
      version: HookConfigImpl.parseVersion(config),
      cCompiler: HookConfigImpl.parseCCompiler(config, dryRun),
      supportedAssetTypes:
          HookConfigImpl.parseSupportedEncodedAssetTypes(config),
      targetAndroidNdkApi:
          HookConfigImpl.parseTargetAndroidNdkApi(config, dryRun, targetOS),
      targetIOSSdk: HookConfigImpl.parseTargetIOSSdk(config, dryRun, targetOS),
      targetIOSVersion:
          HookConfigImpl.parseTargetIosVersion(config, dryRun, targetOS),
      targetMacOSVersion:
          HookConfigImpl.parseTargetMacOSVersion(config, dryRun, targetOS),
      encodedAssets: [
        for (final json in config.optionalList(assetsKey) ?? [])
          EncodedAsset.fromJson(json as Map<String, Object?>),
      ],
      recordedUsagesFile: parseRecordedUsagesUri(config),
      dryRun: dryRun,
    );
  }

  static Uri? parseRecordedUsagesUri(Map<String, Object?> config) =>
      config.optionalPath(resourceIdentifierKey);

  @override
  bool operator ==(Object other) {
    if (super != other) {
      return false;
    }
    if (other is! LinkConfigImpl) {
      return false;
    }
    if (other.recordedUsagesFile != recordedUsagesFile) {
      return false;
    }
    if (!const DeepCollectionEquality()
        .equals(other.encodedAssets, encodedAssets)) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll([
        super.hashCode,
        recordedUsagesFile,
        const DeepCollectionEquality().hash(encodedAssets),
      ]);

  @override
  String toString() => 'LinkConfig(${toJson()})';
}
