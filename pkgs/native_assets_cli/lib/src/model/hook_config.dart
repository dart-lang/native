// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../api/hook_config.dart';

abstract class HookConfigImpl implements HookConfig {
  Hook get hook;

  Uri get configFile => outputDirectory.resolve('../${hook.configName}');

  Uri get outputFile => outputDirectory.resolve(outputName);

  @override
  Uri get outputDirectory;

  // This is currently overriden by [BuildConfig], do account for older versions
  // still using a top-level build.dart.
  Uri get script => packageRoot.resolve('hook/').resolve(hook.scriptName);

  @override
  String get packageName;

  @override
  Uri get packageRoot;

  String get outputName;

  Version get version;

  static const outDirConfigKey = 'out_dir';
  static const packageNameConfigKey = 'package_name';
  static const packageRootConfigKey = 'package_root';
  static const dependencyMetadataConfigKey = 'dependency_metadata';
  static const _versionKey = 'version';
  static const targetAndroidNdkApiConfigKey = 'target_android_ndk_api';
  static const dryRunConfigKey = 'dry_run';
  static const supportedAssetTypesKey = 'supported_asset_types';

  Map<String, Object> toJson() {
    late Map<String, Object> cCompilerJson;
    if (!dryRun) {
      cCompilerJson = (cCompiler as CCompilerConfigImpl).toJson();
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
        if (targetIOSSdk != null) IOSSdkImpl.configKey: targetIOSSdk.toString(),
        if (targetAndroidNdkApi != null)
          targetAndroidNdkApiConfigKey: targetAndroidNdkApi!,
        if (cCompilerJson.isNotEmpty)
          CCompilerConfigImpl.configKey: cCompilerJson,
      },
    };
  }

  String toJsonString() => const JsonEncoder.withIndent('  ').convert(toJson());
}
