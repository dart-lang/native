import 'package:native_assets_cli/native_assets_cli_internal.dart';

abstract class BuildResult {
  List<Uri> get dependencies;

  bool get success;

  List<AssetImpl> get assets;

  Map<String, List<AssetImpl>> get assetsForLinking;
}
