import 'package:native_assets_cli/native_assets_cli_internal.dart';

import '../../native_assets_builder.dart';

/// Similar to a [BuildResult], but for the case of a dry run, where not assets
/// are actually produced.
abstract interface class DryRunResult {
  /// The native assets for all [Target]s for the dry run.
  List<AssetImpl> get assets;

  /// Whether all builds completed without errors.
  ///
  /// All error messages are streamed to [NativeAssetsBuildRunner.logger].
  bool get success;
}
