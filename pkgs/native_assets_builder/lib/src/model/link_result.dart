import 'package:native_assets_cli/native_assets_cli_internal.dart';

import 'build_result.dart';

/// Similar to a [BuildResult], but for `link.dart` hooks instead of
/// `build.dart` hooks.
abstract interface class LinkResult {
  List<AssetImpl> get assets;

  List<Uri> get dependencies;

  bool get success;
}
