// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'asset.dart';
import 'build_config.dart';
import 'build_output.dart';
import 'link_mode.dart';
import 'target.dart';

final class BuildState {
  /// Run a native assets build.
  ///
  /// Example using `package:native_toolchain_c`:
  ///
  /// ```dart
  /// void main(List<String> args) =>
  ///     BuildState.build(args, (buildState) async {
  ///       final cbuilder = CBuilder.library(
  ///         name: packageName,
  ///         assetId: 'package:$packageName/$packageName.dart',
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
  /// void main(List<String> args) =>
  ///     BuildState.build(args, (buildState) async {
  ///       final config = buildState.config;
  ///       if (config.linkModePreference == LinkModePreference.static) {
  ///         // Simulate that this script only supports dynamic libraries.
  ///         throw UnsupportedError(
  ///           'LinkModePreference.static is not supported.',
  ///         );
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
    List<String> commandlineArguments,
    Future<void> Function(BuildState) builder,
  ) async {
    final config = await BuildConfig.fromArgs(commandlineArguments);
    final output = BuildOutput();
    final state = BuildState._(config: config, output: output);
    await builder(state);
    await output.writeToFile(outDir: config.outDir);
  }

  final BuildConfig _config;
  final BuildOutput _output;

  BuildState._({
    required BuildConfig config,
    required BuildOutput output,
  })  : _output = output,
        _config = config;

  /// Adds dependencies to build output.
  ///
  /// See [BuildOutput.addDependencies] for more info.
  void addDependencies(Iterable<Uri> dependencies) =>
      _output.addDependencies(dependencies);

  /// Adds metadata to build output.
  ///
  /// See [BuildOutput.addMetadata] for more info.
  void addMetadata(String key, Object value) => _output.addMetadata(key, value);

  /// Adds asset to build output.
  ///
  /// See [BuildOutput.addAssets] for more info.
  void addAsset({required String id, required AssetPath path}) {
    if (_config.dryRun) {
      _output.addAssets([
        Asset(
          id: 'package:config.packageName$id',
          linkMode: LinkMode.dynamic,
          target: _config.target,
          path: path,
        )
      ]);
    } else {
      _output.addAssets(Target.values
          .where((target) => target.os == _config.targetOs)
          .map((target) => Asset(
                id: 'package:config.packageName$id',
                linkMode: LinkMode.dynamic,
                target: target,
                path: path,
              ))
          .toList());
    }
  }

  Uri getDylibName(String somefile) => _config.getDylibName(somefile);
}
