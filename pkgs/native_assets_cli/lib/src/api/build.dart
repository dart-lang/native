// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'build_config.dart';
import 'build_output.dart';

/// Run a native assets build.
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
///       assetId: 'package:$packageName/$packageName.dart',
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
///       // Simulate that this script only supports dynamic libraries.
///       throw UnsupportedError(
///         'LinkModePreference.static is not supported.',
///       );
///     }
///
///     final packageName = config.packageName;
///     final assetPath = config.outDir.resolve(assetName);
///     final assetSourcePath = config.packageRoot.resolveUri(packageAssetPath);
///     if (!config.dryRun) {
///       // Insert code that downloads or builds the asset to `assetPath`.
///       await File.fromUri(assetSourcePath).copy(assetPath.toFilePath());
///
///       output.addDependencies([
///         assetSourcePath,
///         config.packageRoot.resolve('build.dart'),
///       ]);
///     }
///
///     output.addAsset(
///       CCodeAsset(
///         id: 'library:$packageName/asset.txt',
///         file: assetPath,
///         linkMode: LinkMode.dynamic,
///         os: config.targetOS,
///         architecture: config.targetArchitecture,
///         dynamicLoading: BundledDylib(),
///       ),
///     );
///   });
/// }
/// ```
Future<void> build(
  List<String> commandlineArguments,
  Future<void> Function(BuildConfig, BuildOutput) builder,
) async {
  final config = await BuildConfig.fromArgs(commandlineArguments);
  final output = BuildOutput();
  await builder(config, output);
  await output.writeToFile(config: config);
}
