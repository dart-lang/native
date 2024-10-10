// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../architecture.dart';
import '../c_compiler_config.dart';
import '../config.dart';
import '../ios_sdk.dart';
import '../link_mode_preference.dart';
import 'code_asset.dart';

// XXX TODO: Migrate to json decoding api.
extension CodeAssetBuildConfigBuilder on HookConfigBuilder {
  void setupCodeConfig({
    required Architecture? targetArchitecture,
    required LinkModePreference linkModePreference,
    CCompilerConfig? cCompilerConfig,
    int? targetIOSVersion,
    int? targetMacOSVersion,
    int? targetAndroidNdkApi,
    IOSSdk? targetIOSSdk,
  }) {
    if (targetArchitecture != null) {
      json['target_architecture'] = targetArchitecture.toString();
    }
    json['link_mode_preference'] = linkModePreference.toString();
    if (cCompilerConfig != null) {
      final ar = cCompilerConfig.archiver?.toFilePath();
      if (ar != null) {
        json['c_compiler.ar'] = ar;
      }
      final cc = cCompilerConfig.compiler?.toFilePath();
      if (ar != null) {
        json['c_compiler.cc'] = cc;
      }
      final ld = cCompilerConfig.linker?.toFilePath();
      if (ar != null) {
        json['c_compiler.ld'] = ld;
      }
      final envScript = cCompilerConfig.envScript?.toFilePath();
      if (envScript != null) {
        json['c_compiler.env_script'] = envScript;
      }
      final envScriptArgs = cCompilerConfig.envScriptArgs;
      if (envScriptArgs != null && envScriptArgs.isNotEmpty) {
        json['env_script_arguments'] = envScriptArgs;
      }
    }

    if (targetIOSVersion != null) {
      json['target_ios_version'] = targetIOSVersion;
    }
    if (targetMacOSVersion != null) {
      json['target_macos_version'] = targetMacOSVersion;
    }
    if (targetAndroidNdkApi != null) {
      json['target_android_ndk_api'] = targetAndroidNdkApi;
    }
    if (targetIOSSdk != null) {
      json['target_ios_sdk'] = targetIOSSdk.toString();
    }
  }
}

extension CodeAssetBuildOutput on BuildOutput {
  List<CodeAsset> get codeAssets => encodedAssets
      .where((asset) => asset.type == CodeAsset.type)
      .map<CodeAsset>(CodeAsset.fromEncoded)
      .toList();
}

extension CodeAssetLinkOutput on LinkOutput {
  List<CodeAsset> get codeAssets => encodedAssets
      .where((asset) => asset.type == CodeAsset.type)
      .map<CodeAsset>(CodeAsset.fromEncoded)
      .toList();
}
