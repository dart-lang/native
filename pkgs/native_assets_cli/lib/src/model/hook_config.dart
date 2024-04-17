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

  @override
  final BuildModeImpl? buildMode;

  @override
  final CCompilerConfigImpl cCompiler;

  @override
  final bool dryRun;

  @override
  final Iterable<String> supportedAssetTypes;

  @override
  final int? targetAndroidNdkApi;

  @override
  final ArchitectureImpl? targetArchitecture;

  @override
  final IOSSdkImpl? targetIOSSdk;

  @override
  final OSImpl? targetOS;

  String get outputName;

  HookConfigImpl({
    required this.hook,
    required this.outputDirectory,
    required this.packageName,
    required this.packageRoot,
    required this.version,
    required this.buildMode,
    required CCompilerConfigImpl? cCompiler,
    required this.dryRun,
    required this.supportedAssetTypes,
    required this.targetAndroidNdkApi,
    required this.targetArchitecture,
    required this.targetIOSSdk,
    required this.targetOS,
  }) : cCompiler = cCompiler ?? CCompilerConfigImpl();

  Uri get configFile => outputDirectory.resolve('../${hook.configName}');

  Uri get outputFile => outputDirectory.resolve(outputName);

  // This is currently overriden by [BuildConfig], do account for older versions
  // still using a top-level build.dart.
  Uri get script => packageRoot.resolve('hook/').resolve(hook.scriptName);

  String toJsonString();

  static const outDirConfigKey = 'out_dir';
  static const packageNameConfigKey = 'package_name';
  static const packageRootConfigKey = 'package_root';
  static const _versionKey = 'version';
  static const targetAndroidNdkApiConfigKey = 'target_android_ndk_api';
  static const dryRunConfigKey = 'dry_run';
  static const supportedAssetTypesKey = 'supported_asset_types';

  Map<String, Object> toJson() {
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
        BuildModeImpl.configKey: buildMode!.toString(),
        ArchitectureImpl.configKey: targetArchitecture.toString(),
        if (targetIOSSdk != null) IOSSdkImpl.configKey: targetIOSSdk.toString(),
        if (targetAndroidNdkApi != null)
          targetAndroidNdkApiConfigKey: targetAndroidNdkApi!,
        if (cCompilerJson.isNotEmpty)
          CCompilerConfigImpl.configKey: cCompilerJson,
      },
    }.sortOnKey();
  }
}
