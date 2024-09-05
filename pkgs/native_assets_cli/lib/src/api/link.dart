// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../model/dependencies.dart';
import '../validator/validator.dart';
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
  final output = HookOutputImpl(
    dependencies: Dependencies(builtAssetsFiles),
  );
  await linker(config, output);
  final validateResult = await validateLink(config, output);
  if (validateResult.success) {
    await output.writeToFile(config: config);
  } else {
    final message = [
      'The output contained unsupported output:',
      for (final error in validateResult.errors) '- $error',
    ].join('\n');
    throw UnsupportedError(message);
  }
}
