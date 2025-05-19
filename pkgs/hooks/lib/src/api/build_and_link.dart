// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import '../args_parser.dart';
import '../config.dart';
import '../validation.dart';

/// Builds assets in a `hook/build.dart`.
///
/// If a build hook is defined (`hook/build.dart`) then `build` must be called
/// by that hook, even if the [builder] function has no work to do.
///
/// Can build native assets which are not already available, or expose existing
/// files. Each individual asset is assigned a unique asset ID.
///
/// Example using `package:native_toolchain_c`:
///
/// ```dart
/// import 'package:logging/logging.dart';
/// import 'package:hooks/hooks.dart';
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
/// import 'package:code_assets/code_assets.dart';
/// import 'package:hooks/hooks.dart';
///
/// const assetName = 'asset.txt';
/// final packageAssetPath = Uri.file('data/$assetName');
///
/// void main(List<String> args) async {
///   await build(args, (input, output) async {
///     if (input.config.code.linkModePreference ==
///             LinkModePreference.static) {
///       // Simulate that this hook only supports dynamic libraries.
///       throw UnsupportedError(
///         'LinkModePreference.static is not supported.',
///       );
///     }
///
///     final packageName = input.packageName;
///     final assetPath = input.outputDirectory.resolve(assetName);
///     final assetSourcePath = input.packageRoot.resolveUri(packageAssetPath);
///     // Insert code that downloads or builds the asset to `assetPath`.
///     await File.fromUri(assetSourcePath).copy(assetPath.toFilePath());
///
///     output.addDependencies([
///       assetSourcePath,
///     ]);
///
///     output.assets.code.add(
///       // TODO: Change to DataAsset once the Dart/Flutter SDK can consume it.
///       CodeAsset(
///         package: packageName,
///         name: 'asset.txt',
///         file: assetPath,
///         linkMode: DynamicLoadingBundled(),
///         os: input.config.code.targetOS,
///         architecture: input.config.code.targetArchitecture,
///       ),
///     );
///   });
/// }
/// ```
///
/// If the [builder] fails, it must `throw` a [HookError]. Build hooks are
/// guaranteed to be invoked with a process invocation and should return a
/// non-zero exit code on failure. Throwing will lead to an uncaught exception,
/// causing a non-zero exit code.
Future<void> build(
  List<String> arguments,
  Future<void> Function(BuildInput input, BuildOutputBuilder output) builder,
) async {
  final inputPath = getInputArgument(arguments);
  final bytes = File(inputPath).readAsBytesSync();
  final jsonInput =
      const Utf8Decoder().fuse(const JsonDecoder()).convert(bytes)
          as Map<String, Object?>;
  final input = BuildInput(jsonInput);
  final outputFile = input.outputFile;
  final output = BuildOutputBuilder();
  try {
    await builder(input, output);
    // ignore: avoid_catching_errors
  } on HookError catch (e, st) {
    output.setFailure(e.failureType);
    await _writeOutput(output, outputFile);
    _exitViaHookException(e, st);
  }
  final errors = await ProtocolBase.validateBuildOutput(
    input,
    BuildOutput(output.json),
  );
  if (errors.isNotEmpty) {
    final message = [
      'The output contained unsupported output:',
      for (final error in errors) '- $error',
    ].join('\n');
    stderr.writeln(message);
    output.setFailure(FailureType.build);
    await _writeOutput(output, outputFile);
    exit(BuildError(message: message).exitCode);
  }

  await _writeOutput(output, outputFile);
}

/// Links assets in a `hook/link.dart`.
///
/// If a link hook is defined (`hook/link.dart`) then `link` must be called
/// by that hook, even if the [builder] function has no work to do.
///
/// Can link native assets which are not already available, or expose existing
/// files. Each individual asset is assigned a unique asset ID.
///
/// The linking script may receive assets from build scripts, which are accessed
/// through [LinkInputAssets.encodedAssets]. They will only be bundled with the
/// final application if included in the [LinkOutput].
///
///
/// ```dart
/// import 'package:hooks/hooks.dart';
///
/// void main(List<String> args) async {
///   await link(args, (input, output) async {
///     final dataEncodedAssets = input.assets
///         .whereType<DataAsset>();
///     output.addEncodedAssets(dataEncodedAssets);
///   });
/// }
/// ```
/// If the [linker] fails, it must `throw` a [HookError]. Link hooks are
/// guaranteed to be invoked with a process invocation and should return a
/// non-zero exit code on failure. Throwing will lead to an uncaught exception,
/// causing a non-zero exit code.
Future<void> link(
  List<String> arguments,
  Future<void> Function(LinkInput input, LinkOutputBuilder output) linker,
) async {
  final inputPath = getInputArgument(arguments);
  final bytes = File(inputPath).readAsBytesSync();
  final jsonInput =
      const Utf8Decoder().fuse(const JsonDecoder()).convert(bytes)
          as Map<String, Object?>;
  final input = LinkInput(jsonInput);
  final outputFile = input.outputFile;
  final output = LinkOutputBuilder();
  try {
    await linker(input, output);
    // ignore: avoid_catching_errors
  } on HookError catch (e, st) {
    output.setFailure(e.failureType);
    await _writeOutput(output, outputFile);
    _exitViaHookException(e, st);
  }
  final errors = await ProtocolBase.validateLinkOutput(
    input,
    LinkOutput(output.json),
  );
  if (errors.isNotEmpty) {
    final message = [
      'The output contained unsupported output:',
      for (final error in errors) '- $error',
    ].join('\n');
    stderr.writeln(message);
    output.setFailure(FailureType.build);
    await _writeOutput(output, outputFile);
    exit(BuildError(message: message).exitCode);
  }

  await _writeOutput(output, outputFile);
}

Future<void> _writeOutput(HookOutputBuilder output, Uri outputFile) async {
  final jsonOutput = const JsonEncoder.withIndent(
    '  ',
  ).fuse(const Utf8Encoder()).convert(output.json);
  await File.fromUri(outputFile).writeAsBytes(jsonOutput);
}

Never _exitViaHookException(HookError exception, StackTrace stackTrace) {
  stderr.writeln(exception.message);
  stderr.writeln(stackTrace);
  if (exception.wrappedException != null) {
    stderr.writeln('Wrapped exception:');
    stderr.writeln(exception.wrappedException);
    stderr.writeln(exception.wrappedTrace);
  }
  exit(exception.exitCode);
}
