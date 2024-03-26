import 'package:native_assets_cli/native_assets_cli_internal.dart';

import 'build_result.dart';

extension type LinkResult(BuildResultImpl _buildResultImpl) {
  List<Asset> get assets => _buildResultImpl.assets;

  List<Uri> get dependencies => _buildResultImpl.dependencies;

  bool get success => _buildResultImpl.success;
}
