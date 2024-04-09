import 'package:collection/collection.dart';
import 'package:native_assets_cli/native_assets_cli_internal.dart';

import '../../native_assets_builder.dart';

/// The result from a [NativeAssetsBuildRunner.build] or
/// [NativeAssetsBuildRunner.link].
final class ForgeResult implements BuildResult, DryRunResult, LinkResult {
  /// All the files used for building the native assets of all packages.
  ///
  /// This aggregated list can be used to determine whether the
  /// [NativeAssetsBuildRunner] needs to be invoked again. The
  /// [NativeAssetsBuildRunner] determines per package with native assets
  /// if it needs to run the build again.
  @override
  final List<AssetImpl> assets;

  @override
  final Map<String, List<AssetImpl>> assetsForLinking;

  @override
  final List<Uri> dependencies;

  @override
  final bool success;

  ForgeResult._({
    required this.assets,
    required this.assetsForLinking,
    required this.dependencies,
    required this.success,
  });

  ForgeResult.failure()
      : this._(
          assets: [],
          assetsForLinking: {},
          dependencies: [],
          success: false,
        );

  void add(BuildOutputImpl buildOutput) {
    assets.addAll(buildOutput.assets);
    final mergedMaps = mergeMaps(
      assetsForLinking,
      buildOutput.assetsForLinking,
      value: (assets1, assets2) {
        if (assets1.any((asset) => assets2.contains(asset)) ||
            assets2.any((asset) => assets1.contains(asset))) {
          throw ArgumentError(
              'Found assets with same ID in $assets1 and $assets2');
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

  ForgeResult withSuccess(bool success) => ForgeResult._(
        assets: assets,
        assetsForLinking: assetsForLinking,
        dependencies: dependencies,
        success: success,
      );
}

int _uriCompare(Uri u1, Uri u2) => u1.toString().compareTo(u2.toString());
