// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../validation.dart';
import 'build_output.dart';
import 'link_config.dart';

/// Runs a native assets link.
///
/// Can link native assets which are not already available, or expose existing
/// files. Each individual asset is assigned a unique asset ID.
///
/// The linking script may receive assets from build scripts, which are accessed
/// through [LinkConfig.encodedAssets]. They will only be bundled with the final
/// application if included in the [LinkOutput].
///
///
/// ```dart
/// import 'package:native_assets_cli/native_assets_cli.dart';
///
/// void main(List<String> args) async {
///   await link(args, (config, output) async {
///     final dataEncodedAssets = config.assets
///         .whereType<DataAsset>();
///     output.addEncodedAssets(dataEncodedAssets);
///   });
/// }
/// ```
Future<void> link(
  List<String> arguments,
  Future<void> Function(LinkConfig config, LinkOutput output) linker,
) async {
  final config = LinkConfig.fromArguments(arguments) as LinkConfigImpl;

  final output = HookOutputImpl();
  await linker(config, output);
  final errors = await validateLinkOutput(config, output);
  if (errors.isEmpty) {
    await output.writeToFile(config: config);
  } else {
    final message = [
      'The output contained unsupported output:',
      for (final error in errors) '- $error',
    ].join('\n');
    throw UnsupportedError(message);
  }
}
