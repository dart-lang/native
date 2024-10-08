// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../validation.dart';
import 'build_config.dart';
import 'build_output.dart';

/// Runs a native assets build.
///
/// Can build native assets which are not already available, or expose existing
/// files. Each individual asset is assigned a unique asset ID.
///
/// Example using `package:native_toolchain_c`:
///
/// ```dart
/// import 'package:logging/logging.dart';
/// import 'package:native_assets_cli/native_assets_cli.dart';
/// import 'package:native_toolchain_c/native_toolchain_c.dart';
///
/// void main(List<String> args) async {
///   await build(args, (config, output) async {
///     final packageName = config.packageName;
///     final cbuilder = CBuilder.library(
///       name: packageName,
///       assetName: '$packageName.dart',
///       sources: [
///         'src/$packageName.c',
///       ],
///     );
///     await cbuilder.run(
///       buildConfig: config,
///       buildOutput: output,
///       logger: Logger('')
///         ..level = Level.ALL
///         ..onRecord.listen((record) => print(record.message)),
///     );
///   });
/// }
/// ```
///
/// Example outputting assets manually:
///
/// ```dart
/// import 'dart:io';
///
/// import 'package:native_assets_cli/native_assets_cli.dart';
///
/// const assetName = 'asset.txt';
/// final packageAssetPath = Uri.file('data/$assetName');
///
/// void main(List<String> args) async {
///   await build(args, (config, output) async {
///     if (config.linkModePreference == LinkModePreference.static) {
///       // Simulate that this hook only supports dynamic libraries.
///       throw UnsupportedError(
///         'LinkModePreference.static is not supported.',
///       );
///     }
///
///     final packageName = config.packageName;
///     final assetPath = config.outputDirectory.resolve(assetName);
///     final assetSourcePath = config.packageRoot.resolveUri(packageAssetPath);
///     if (!config.dryRun) {
///       // Insert code that downloads or builds the asset to `assetPath`.
///       await File.fromUri(assetSourcePath).copy(assetPath.toFilePath());
///
///       output.addDependencies([
///         assetSourcePath,
///       ]);
///     }
///
///     output.codeAssets.add(
///       // TODO: Change to DataAsset once the Dart/Flutter SDK can consume it.
///       CodeAsset(
///         package: packageName,
///         name: 'asset.txt',
///         file: assetPath,
///         linkMode: DynamicLoadingBundled(),
///         os: config.targetOS,
///         architecture: config.targetArchitecture,
///       ),
///     );
///   });
/// }
/// ```
Future<void> build(
  List<String> arguments,
  Future<void> Function(BuildConfig config, BuildOutput output) builder,
) async {
  final config = BuildConfigImpl.fromArguments(arguments);
  final output = HookOutputImpl();
  await builder(config, output);
  final errors = await validateBuildOutput(config, output);
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
