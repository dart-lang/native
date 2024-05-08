// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:native_assets_cli/native_assets_cli_internal.dart';

import '../../native_assets_builder.dart';

/// The result from a [NativeAssetsBuildRunner.build] or
/// [NativeAssetsBuildRunner.link].
final class HookResult implements BuildResult, DryRunResult, LinkResult {
  @override
  final List<AssetImpl> assets;

  @override
  final Map<String, List<AssetImpl>> assetsForLinking;

  @override
  final List<Uri> dependencies;

  @override
  final bool success;

  HookResult._({
    required this.assets,
    required this.assetsForLinking,
    required this.dependencies,
    required this.success,
  });

  HookResult.failure()
      : this._(
          assets: [],
          assetsForLinking: {},
          dependencies: [],
          success: false,
        );

  void add(HookOutputImpl buildOutput) {
    assets.addAll(buildOutput.assets);
    final mergedMaps = mergeMaps(
      assetsForLinking,
      buildOutput.assetsForLinking,
      value: (assets1, assets2) {
        final twoInOne = assets1.where((asset) => assets2.contains(asset));
        final oneInTwo = assets2.where((asset) => assets1.contains(asset));
        if (twoInOne.isNotEmpty || oneInTwo.isNotEmpty) {
          throw ArgumentError(
              'Found assets with same IDs, ${[...oneInTwo, ...twoInOne]}');
        }
        return [
          ...assets1,
          ...assets2,
        ];
      },
    );
    assetsForLinking.addAll(mergedMaps);
    dependencies.addAll(buildOutput.dependencies);
    dependencies.sort(_uriCompare);
  }

  HookResult withSuccess(bool success) => HookResult._(
        assets: assets,
        assetsForLinking: assetsForLinking,
        dependencies: dependencies,
        success: success,
      );
}

int _uriCompare(Uri u1, Uri u2) => u1.toString().compareTo(u2.toString());
