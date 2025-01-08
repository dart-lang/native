// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import '../args_parser.dart';
import '../config.dart';
import '../validation.dart';

/// Runs a native assets link.
///
/// Meant to be used in link hooks (`hook/link.dart`).
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
/// import 'package:native_assets_cli/native_assets_cli.dart';
///
/// void main(List<String> args) async {
///   await link(args, (input, output) async {
///     final dataEncodedAssets = input.assets
///         .whereType<DataAsset>();
///     output.addEncodedAssets(dataEncodedAssets);
///   });
/// }
/// ```
/// If the [linker] fails, it must `throw`. Link hooks are guaranteed to be
/// invoked with a process invocation and should return a non-zero exit code on
/// failure. Throwing will lead to an uncaught exception, causing a non-zero
/// exit code.
Future<void> link(
  List<String> arguments,
  Future<void> Function(LinkInput input, LinkOutputBuilder output) linker,
) async {
  final inputPath = getInputArgument(arguments);
  final bytes = File(inputPath).readAsBytesSync();
  final jsonInput = const Utf8Decoder().fuse(const JsonDecoder()).convert(bytes)
      as Map<String, Object?>;
  final input = LinkInput(jsonInput);
  final output = LinkOutputBuilder();
  await linker(input, output);
  final errors = await validateLinkOutput(input, LinkOutput(output.json));
  if (errors.isEmpty) {
    final jsonOutput =
        const JsonEncoder().fuse(const Utf8Encoder()).convert(output.json);
    await File.fromUri(input.outputDirectory.resolve('link_output.json'))
        .writeAsBytes(jsonOutput);
  } else {
    final message = [
      'The output contained unsupported output:',
      for (final error in errors) '- $error',
    ].join('\n');
    throw UnsupportedError(message);
  }
}
