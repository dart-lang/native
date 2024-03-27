import 'package:native_assets_cli/native_assets_cli_internal.dart';

abstract interface class LinkResult {
  List<AssetImpl> get assets;

  List<Uri> get dependencies;

  bool get success;
}
