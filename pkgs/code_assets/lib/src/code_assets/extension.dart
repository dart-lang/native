// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:hooks/hooks.dart';
import 'package:logging/logging.dart';

import 'architecture.dart';
import 'c_compiler_config.dart';
import 'code_asset.dart';
import 'config.dart';
import 'link_mode.dart';
import 'link_mode_preference.dart';
import 'native_library_validation.dart';
import 'os.dart';
import 'sanitizer.dart';
import 'validation.dart';

/// The protocol extension for the `hook/build.dart` and `hook/link.dart`
/// with [CodeAsset]s and [CodeConfig].
final class CodeAssetExtension extends ProtocolExtension {
  /// The architecture to build for.
  final Architecture targetArchitecture;

  /// The operating system to build for.
  final OS targetOS;

  /// The preferred link mode.
  final LinkModePreference linkModePreference;

  /// Optional C compiler configuration.
  final CCompilerConfig? cCompiler;

  /// Optional Android specific configuration.
  ///
  /// Required if [targetOS] is [OS.android].
  final AndroidCodeConfig? android;

  /// Optional iOS specific configuration.
  ///
  /// Required if [targetOS] is [OS.iOS].
  final IOSCodeConfig? iOS;

  /// Optional macOS specific configuration.
  ///
  /// Required if [targetOS] is [OS.macOS].
  final MacOSCodeConfig? macOS;

  /// Optional compiler sanitizer to use when compiling code assets.
  ///
  /// Sanitizers (like AddressSanitizer, MemorySanitizer, or ThreadSanitizer)
  /// instrument binaries for runtime diagnostics.
  ///
  /// The Dart SDK JIT or AOT runtime itself can be compiled with a sanitizer.
  /// To run native code alongside a sanitized Dart SDK, the code assets must be
  /// compiled with the exact same sanitizer, ensuring they share compatible
  /// runtime libraries and memory allocators across the FFI boundary.
  final Sanitizer? sanitizer;

  /// Receives warnings from validations which are skipped rather than failed,
  /// such as an unrecognized native library header.
  final Logger? logger;

  /// Additional validators for bundled dynamic libraries.
  ///
  /// These validators are supplied by the hook invoker, not by packages that
  /// produce hook output. The iterable is copied during construction.
  final List<NativeLibraryValidator> additionalLibraryValidators;

  /// Constructs a [CodeAssetExtension].
  CodeAssetExtension({
    required this.targetArchitecture,
    required this.targetOS,
    required this.linkModePreference,
    this.cCompiler,
    this.android,
    this.iOS,
    this.macOS,
    this.sanitizer,
    this.logger,
    Iterable<NativeLibraryValidator> additionalLibraryValidators = const [],
  }) : additionalLibraryValidators = List.unmodifiable(
         additionalLibraryValidators,
       );

  @override
  void setupBuildInput(BuildInputBuilder input) {
    _setupConfig(input);
  }

  @override
  void setupLinkInput(LinkInputBuilder input) {
    _setupConfig(input);
  }

  void _setupConfig(HookInputBuilder input) {
    input.config.addBuildAssetTypes([CodeAssetType.type]);
    input.config.setupCode(
      targetArchitecture: targetArchitecture,
      targetOS: targetOS,
      linkModePreference: linkModePreference,
      cCompiler: cCompiler,
      android: android,
      iOS: iOS,
      macOS: macOS,
      sanitizer: sanitizer,
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
  ) => validateCodeAssetBuildOutput(
    input,
    output,
    logger: logger,
    additionalLibraryValidators: additionalLibraryValidators,
  );

  @override
  Future<ValidationErrors> validateLinkOutput(
    LinkInput input,
    LinkOutput output,
  ) => validateCodeAssetLinkOutput(
    input,
    output,
    logger: logger,
    additionalLibraryValidators: additionalLibraryValidators,
  );

  @override
  Future<ValidationErrors> validateApplicationAssets(
    List<EncodedAsset> assets,
  ) => validateCodeAssetInApplication(assets);

  @override
  Iterable<Uri> outputFiles(List<EncodedAsset> assets) sync* {
    for (final encodedAsset in assets) {
      if (encodedAsset.isCodeAsset) {
        final asset = encodedAsset.asCodeAsset;
        if (asset.linkMode is DynamicLoadingBundled ||
            asset.linkMode is StaticLinking) {
          final file = asset.file;
          if (file != null) {
            yield file;
          }
        }
      }
    }
  }
}
