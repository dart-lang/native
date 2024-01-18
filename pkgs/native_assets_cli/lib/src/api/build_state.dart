// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'asset.dart';
import 'build_config.dart';
import 'build_output.dart';

final class BuildState {
  /// Run a native assets build.
  ///
  /// Example using `package:native_toolchain_c`:
  ///
  /// ```dart
  /// void main(List<String> args) async =>
  ///     await BuildState.build(args, (buildState) async {
  ///       final cbuilder = CBuilder.library(
  ///         name: packageName,
  ///         assetId: 'package:$packageName/${packageName}.dart',
  ///         sources: [
  ///           'src/$packageName.c',
  ///         ],
  ///       );
  ///       await cbuilder.run(
  ///         buildState: buildState,
  ///         logger: Logger('')
  ///           ..level = Level.ALL
  ///           ..onRecord.listen((record) => print(record.message)),
  ///       );
  ///     });
  /// ```
  ///
  /// Example outputting assets manually:
  ///
  /// ```dart
  /// void main(List<String> args) async =>
  ///     await BuildState.build(args, (buildState) async {
  ///       final config = buildState.config;
  ///       if (config.linkModePreference == LinkModePreference.static) {
  ///         // Simulat that this script only supports dynamic libraries.
  ///         throw Exception('LinkModePreference.static is not supported.');
  ///       }
  ///
  ///       final Iterable<Target> targets;
  ///       final packageName = config.packageName;
  ///       final assetPath = config.outDir.resolve(
  ///         config.targetOs.dylibFileName(packageName),
  ///       );
  ///       if (config.dryRun) {
  ///         // Dry run invocations report assets for all architectures for that OS.
  ///         targets = Target.values.where(
  ///           (element) => element.os == config.targetOs,
  ///         );
  ///       } else {
  ///         targets = [config.target];
  ///
  ///         // Insert code that downloads or builds the asset to `assetPath`.
  ///       }
  ///
  ///       for (final target in targets) {
  ///         buildState.output.addAssets([
  ///           Asset(
  ///             id: 'library:${packageName}/src/some_file.dart',
  ///             linkMode: LinkMode.dynamic,
  ///             target: target,
  ///             path: AssetAbsolutePath(assetPath),
  ///           )
  ///         ]);
  ///       }
  ///     });
  /// ```
  static Future<void> build(
    List<String> args,
    Future<void> Function(BuildState) callback,
  ) async {
    final config = await BuildConfig.fromArgs(args);
    final output = BuildOutput();
    final state = BuildState._(config: config, output: output);
    await callback(state);
    await output.writeToFile(outDir: config.outDir);
  }

  final BuildConfig config;
  final BuildOutput output;

  BuildState._({
    required this.config,
    required this.output,
  });

  /// Add assets to build output.
  ///
  /// See [BuildOutput.addAssets] for more info.
  void addAssets(Iterable<Asset> assets) => output.addAssets(assets);

  /// Add dependencies to build output.
  ///
  /// See [BuildOutput.addDependencies] for more info.
  void addDependencies(Iterable<Uri> dependencies) =>
      output.addDependencies(dependencies);

  /// Add metadata to build output.
  ///
  /// See [BuildOutput.addMetadata] for more info.
  void addMetadata(String key, Object value) => output.addMetadata(key, value);
}
