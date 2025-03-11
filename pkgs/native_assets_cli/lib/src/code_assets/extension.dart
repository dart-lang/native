// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../code_assets_builder.dart';
import 'validation.dart';

/// The protocol extension for the `hook/build.dart` and `hook/link.dart`
/// with [CodeAsset]s and [CodeConfig].
final class CodeAssetExtension implements ProtocolExtension {
  final Architecture targetArchitecture;
  final OS targetOS;
  final LinkModePreference linkModePreference;
  final CCompilerConfig? cCompiler;
  final AndroidCodeConfig? android;
  final IOSCodeConfig? iOS;
  final MacOSCodeConfig? macOS;

  CodeAssetExtension({
    required this.targetArchitecture,
    required this.targetOS,
    required this.linkModePreference,
    this.cCompiler,
    this.android,
    this.iOS,
    this.macOS,
  });

  @override
  List<String> get buildAssetTypes => [CodeAsset.type];

  @override
  void setupBuildInput(BuildInputBuilder input) {
    _setupConfig(input);
  }

  @override
  void setupLinkInput(LinkInputBuilder input) {
    _setupConfig(input);
  }

  void _setupConfig(HookInputBuilder input) {
    input.config.setupCode(
      targetArchitecture: targetArchitecture,
      targetOS: targetOS,
      linkModePreference: linkModePreference,
      cCompiler: cCompiler,
      android: android,
      iOS: iOS,
      macOS: macOS,
    );
  }

  @override
  Future<ValidationErrors> validateBuildInput(BuildInput input) =>
      validateCodeAssetBuildInput(input);

  @override
  Future<ValidationErrors> validateLinkInput(LinkInput input) =>
      validateCodeAssetLinkInput(input);

  @override
  Future<ValidationErrors> validateBuildOutput(
    BuildInput input,
    BuildOutput output,
  ) => validateCodeAssetBuildOutput(input, output);

  @override
  Future<ValidationErrors> validateLinkOutput(
    LinkInput input,
    LinkOutput output,
  ) => validateCodeAssetLinkOutput(input, output);

  @override
  Future<ValidationErrors> validateApplicationAssets(
    List<EncodedAsset> assets,
  ) => validateCodeAssetInApplication(assets);
}
