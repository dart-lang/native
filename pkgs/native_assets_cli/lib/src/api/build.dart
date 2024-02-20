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
///     final Iterable<Target> targets;
///     final packageName = config.packageName;
///     final assetPath = config.outDir.resolve(assetName);
///     final assetSourcePath = config.packageRoot.resolveUri(packageAssetPath);
///     if (config.dryRun) {
///       // Dry run invocations report assets for all architectures for that OS.
///       targets = Target.values.where(
///         (element) => element.os == config.targetOs,
///       );
///     } else {
///       targets = [config.target];
///
///       // Insert code that downloads or builds the asset to `assetPath`.
///       await File.fromUri(assetSourcePath).copy(assetPath.toFilePath());
///
///       output.addDependencies([
///         assetSourcePath,
///         config.packageRoot.resolve('build.dart'),
///       ]);
///     }
///
///     output.addAssets([
///       for (final target in targets)
///         Asset(
///           id: 'library:$packageName/asset.txt',
///           linkMode: LinkMode.dynamic,
///           target: target,
///           path: AssetAbsolutePath(assetPath),
///         )
///     ]);
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
