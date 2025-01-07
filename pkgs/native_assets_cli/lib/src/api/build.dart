// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import '../args_parser.dart';
import '../config.dart';
import '../validation.dart';

/// Runs a native assets build.
///
/// Meant to be used in build hooks (`hook/build.dart`).
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
///   await build(args, (input, output) async {
///     final packageName = input.packageName;
///     final cbuilder = CBuilder.library(
///       name: packageName,
///       assetName: '$packageName.dart',
///       sources: [
///         'src/$packageName.c',
///       ],
///     );
///     await cbuilder.run(
///       input: input,
///       output: output,
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
/// import 'package:native_assets_cli/code_assets.dart';
///
/// const assetName = 'asset.txt';
/// final packageAssetPath = Uri.file('data/$assetName');
///
/// void main(List<String> args) async {
///   await build(args, (input, output) async {
///     if (input.codeConfig.linkModePreference == LinkModePreference.static) {
///       // Simulate that this hook only supports dynamic libraries.
///       throw UnsupportedError(
///         'LinkModePreference.static is not supported.',
///       );
///     }
///
///     final packageName = input.packageName;
///     final assetPath = input.outputDirectory.resolve(assetName);
///     final assetSourcePath = input.packageRoot.resolveUri(packageAssetPath);
///     if (!input.dryRun) {
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
///         os: input.codeConfig.targetOS,
///         architecture: input.codeConfig.targetArchitecture,
///       ),
///     );
///   });
/// }
/// ```
///
/// If the [builder] fails, it must `throw`. Build hooks are guaranteed to be
/// invoked with a process invocation and should return a non-zero exit code on
/// failure. Throwing will lead to an uncaught exception, causing a non-zero
/// exit code.
Future<void> build(
  List<String> arguments,
  Future<void> Function(BuildInput input, BuildOutputBuilder output) builder,
) async {
  final inputPath = getInputArgument(arguments);
  final bytes = File(inputPath).readAsBytesSync();
  final jsonInput = const Utf8Decoder()
      .fuse(const JsonDecoder())
      .convert(bytes) as Map<String, Object?>;
  final input = BuildInput(jsonInput);
  final output = BuildOutputBuilder();
  await builder(input, output);
  final errors = await validateBuildOutput(input, BuildOutput(output.json));
  if (errors.isEmpty) {
    final jsonOutput =
        const JsonEncoder().fuse(const Utf8Encoder()).convert(output.json);
    await File.fromUri(input.outputDirectory.resolve('build_output.json'))
        .writeAsBytes(jsonOutput);
  } else {
    final message = [
      'The output contained unsupported output:',
      for (final error in errors) '- $error',
    ].join('\n');
    throw UnsupportedError(message);
  }
}
