// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../native_assets_cli_internal.dart';
import 'asset.dart';
import 'build_output.dart';
import 'link_config.dart';

/// Runs a native assets link.
///
/// Can link native assets which are not already available, or expose existing
/// files. Each individual asset is assigned a unique asset ID.
///
/// The linking script may receive assets from build scripts, which are accessed
/// through [LinkConfig.assets]. They will only be bundled with the final
/// application if included in the [LinkOutput].
///
///
/// ```dart
/// import 'package:native_assets_cli/native_assets_cli.dart';
///
/// void main(List<String> args) async {
///   await link(args, (config, output) async {
///     final dataAssets = config.assets
///         .whereType<DataAsset>();
///     output.addAssets(dataAssets);
///   });
/// }
/// ```
Future<void> link(
  List<String> arguments,
  Future<void> Function(LinkConfig config, LinkOutput output) linker,
) async {
  final config = LinkConfig.fromArguments(arguments) as LinkConfigImpl;

  // The built assets are dependencies of linking, as the linking should be
  // rerun if they change.
  final builtAssetsFiles =
      config.assets.map((asset) => asset.file).whereType<Uri>().toList();
  final linkOutput = HookOutputImpl(
    dependencies: Dependencies(
      assetDependencies: {},
      assetTypeDependencies: {
        DataAsset.type: builtAssetsFiles,
        NativeCodeAsset.type: builtAssetsFiles,
      },
    ),
  );
  await linker(config, linkOutput);
  await linkOutput.writeToFile(config: config);
}
