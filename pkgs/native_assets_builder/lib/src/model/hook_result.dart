// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:native_assets_cli/native_assets_cli_internal.dart';

import '../../native_assets_builder.dart';

/// The result from a [NativeAssetsBuildRunner.build] or
/// [NativeAssetsBuildRunner.link].
final class HookResult implements BuildResult, BuildDryRunResult, LinkResult {
  /// The native assets produced by the hooks, which should be bundled.
  @override
  final List<AssetImpl> assets;

  /// The assets produced by the hooks, which should be linked.
  @override
  final Map<String, List<AssetImpl>> assetsForLinking;

  /// The files used by the hooks.
  @override
  final List<Uri> dependencies;

  /// Whether all hooks completed without errors.
  ///
  /// All error messages are streamed to [NativeAssetsBuildRunner.logger].
  @override
  final bool success;

  HookResult._({
    required this.assets,
    required this.assetsForLinking,
    required this.dependencies,
    required this.success,
  });

  factory HookResult({
    List<AssetImpl>? assets,
    Map<String, List<AssetImpl>>? assetsForLinking,
    List<Uri>? dependencies,
    bool success = true,
  }) =>
      HookResult._(
        assets: assets ?? [],
        assetsForLinking: assetsForLinking ?? {},
        dependencies: dependencies ?? [],
        success: success,
      );

  factory HookResult.failure() => HookResult(success: false);

  HookResult copyAdd(HookOutputImpl hookOutput, bool hookSuccess) {
    final mergedMaps = mergeMaps(
      assetsForLinking,
      hookOutput.assetsForLinking,
      value: (assets1, assets2) {
        final twoInOne = assets1.where((asset) => assets2.contains(asset));
        final oneInTwo = assets2.where((asset) => assets1.contains(asset));
        if (twoInOne.isNotEmpty || oneInTwo.isNotEmpty) {
          throw ArgumentError(
              'Found duplicate IDs, ${oneInTwo.map((e) => e.id).toList()}');
        }
        return [
          ...assets1,
          ...assets2,
        ];
      },
    );
    return HookResult(
      assets: [
        ...assets,
        ...hookOutput.assets,
      ],
      assetsForLinking: mergedMaps,
      dependencies: [
        ...dependencies,
        ...hookOutput.dependencies,
      ]..sort(_uriCompare),
      success: success && hookSuccess,
    );
  }

  HookResult withSuccess(bool success) => HookResult(
        assets: assets,
        assetsForLinking: assetsForLinking,
        dependencies: dependencies,
        success: success,
      );
}

int _uriCompare(Uri u1, Uri u2) => u1.toString().compareTo(u2.toString());
