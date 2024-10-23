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

  HookResult._({
    required this.encodedAssets,
    required this.encodedAssetsForLinking,
    required this.dependencies,
  });

  factory HookResult({
    List<EncodedAsset>? encodedAssets,
    Map<String, List<EncodedAsset>>? encodedAssetsForLinking,
    List<Uri>? dependencies,
  }) =>
      HookResult._(
        encodedAssets: encodedAssets ?? [],
        encodedAssetsForLinking: encodedAssetsForLinking ?? {},
        dependencies: dependencies ?? [],
      );

  HookResult copyAdd(HookOutput hookOutput) {
    final mergedMaps = mergeMaps(
        encodedAssetsForLinking,
        hookOutput is BuildOutput
            ? hookOutput.encodedAssetsForLinking
            : <String, List<EncodedAsset>>{},
        value: (encodedAssets1, encodedAssets2) => [
              ...encodedAssets1,
              ...encodedAssets2,
            ]);
    final hookOutputAssets = (hookOutput is BuildOutput)
        ? hookOutput.encodedAssets
        : (hookOutput as LinkOutput).encodedAssets;
    return HookResult(
      encodedAssets: [
        ...encodedAssets,
        ...hookOutputAssets,
      ],
      encodedAssetsForLinking: mergedMaps,
      dependencies: [
        ...dependencies,
        ...hookOutput.dependencies,
      ]..sort(_uriCompare),
    );
  }
}

int _uriCompare(Uri u1, Uri u2) => u1.toString().compareTo(u2.toString());
