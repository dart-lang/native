import 'package:native_assets_cli/native_assets_cli_internal.dart';

import '../../native_assets_builder.dart';
import 'build_result.dart';

extension type DryRunResult(BuildResultImpl _buildResultImpl) {
  /// The native assets for all [Target]s for the dry run.
  List<AssetImpl> get assets => _buildResultImpl.assets;

  /// Whether all builds completed without errors.
  ///
  /// All error messages are streamed to [NativeAssetsBuildRunner.logger].
  bool get success => _buildResultImpl.success;
}
