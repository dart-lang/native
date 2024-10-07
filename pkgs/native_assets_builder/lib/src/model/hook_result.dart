// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:native_assets_cli/native_assets_cli_internal.dart';

import '../../native_assets_builder.dart';

/// The result from a [NativeAssetsBuildRunner.build] or
/// [NativeAssetsBuildRunner.link].
final class HookResult implements BuildResult, BuildDryRunResult, LinkResult {
  /// The native encodedAssets produced by the hooks, which should be bundled.
  @override
  final List<EncodedAsset> encodedAssets;

  /// The encodedAssets produced by the hooks, which should be linked.
  @override
  final Map<String, List<EncodedAsset>> encodedAssetsForLinking;

  /// The files used by the hooks.
  @override
  final List<Uri> dependencies;

  /// Whether all hooks completed without errors.
  ///
  /// All error messages are streamed to [NativeAssetsBuildRunner.logger].
  @override
  final bool success;

  HookResult._({
    required this.encodedAssets,
    required this.encodedAssetsForLinking,
    required this.dependencies,
    required this.success,
  });

  factory HookResult({
    List<EncodedAsset>? encodedAssets,
    Map<String, List<EncodedAsset>>? encodedAssetsForLinking,
    List<Uri>? dependencies,
    bool success = true,
  }) =>
      HookResult._(
        encodedAssets: encodedAssets ?? [],
        encodedAssetsForLinking: encodedAssetsForLinking ?? {},
        dependencies: dependencies ?? [],
        success: success,
      );

  factory HookResult.failure() => HookResult(success: false);

  HookResult copyAdd(HookOutputImpl hookOutput, bool hookSuccess) {
    final mergedMaps =
        mergeMaps(encodedAssetsForLinking, hookOutput.encodedAssetsForLinking,
            value: (encodedAssets1, encodedAssets2) => [
                  ...encodedAssets1,
                  ...encodedAssets2,
                ]);
    return HookResult(
      encodedAssets: [
        ...encodedAssets,
        ...hookOutput.encodedAssets,
      ],
      encodedAssetsForLinking: mergedMaps,
      dependencies: [
        ...dependencies,
        ...hookOutput.dependencies,
      ]..sort(_uriCompare),
      success: success && hookSuccess,
    );
  }

  HookResult withSuccess(bool success) => HookResult(
        encodedAssets: encodedAssets,
        encodedAssetsForLinking: encodedAssetsForLinking,
        dependencies: dependencies,
        success: success,
      );
}

int _uriCompare(Uri u1, Uri u2) => u1.toString().compareTo(u2.toString());
