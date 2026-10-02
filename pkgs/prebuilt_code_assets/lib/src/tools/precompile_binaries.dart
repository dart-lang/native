// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart' show UsageException;
import 'package:code_assets/code_assets.dart';

import '../prebuilt_library.dart';
import '../targets.dart';

/// CLI runner for `tool/precompile_binaries.dart` (or `tool/build.dart`).
///
/// Parses `--target-os`, `--target-arch`, `--ios-sdk` (required for iOS),
/// `--compile-type`, and `--out-dir`. For each requested compile type
/// (`dynamic` and/or `static`), invokes [PrebuiltLibrary.buildStandalone] (or
/// [customBuilder] if provided) and copies the built binary to
/// `<outDir>/<releaseAssetName>`.
///
/// Throws a [UsageException] for invalid arguments; `--help` prints the usage
/// and returns.
Future<void> runPrecompileBinariesCli(
  List<String> args, {
  required PrebuiltLibrary library,
  Uri? packageRoot,
  Uri? checkoutPath,
  Future<Uri> Function({
    required OS targetOS,
    required Architecture targetArch,
    required IOSSdk? iosSdk,
    required bool static,
    required Uri packageRoot,
  })?
  customBuilder,
}) async {
  final parser = ArgParser()
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Print this usage.')
    ..addOption(
      'target-os',
      abbr: 'o',
      allowed: [...OS.values.map((o) => o.name), 'current'],
      defaultsTo: 'current',
      help: 'Target OS to build for.',
    )
    ..addOption(
      'target-arch',
      abbr: 'a',
      allowed: [...Architecture.values.map((a) => a.name), 'current'],
      defaultsTo: 'current',
      help: 'Target architecture to build for.',
    )
    ..addOption(
      'ios-sdk',
      abbr: 'i',
      allowed: IOSSdk.values.map((s) => s.type),
      help: 'Target iOS SDK. Required when --target-os is ios.',
    )
    ..addOption(
      'compile-type',
      abbr: 't',
      allowed: const ['dynamic', 'static', 'both'],
      defaultsTo: 'both',
      help: 'Type of library to compile (dynamic, static, or both).',
    )
    ..addOption(
      'out-dir',
      abbr: 'd',
      defaultsTo: 'bin',
      help: 'Output directory for built release binaries.',
    );

  final ArgResults results;
  try {
    results = parser.parse(args);
  } on FormatException catch (e) {
    throw UsageException(e.message, parser.usage);
  }
  if (results.flag('help')) {
    stdout.writeln(parser.usage);
    return;
  }

  final targetOS = results.option('target-os') == 'current'
      ? OS.current
      : OS.fromString(results.option('target-os')!);
  final targetArch = results.option('target-arch') == 'current'
      ? Architecture.current
      : Architecture.fromString(results.option('target-arch')!);
  final iosSdkStr = results.option('ios-sdk');
  final iosSdk = iosSdkStr != null ? IOSSdk.fromString(iosSdkStr) : null;
  // Release assets for iOS are named with the SDK (see [targetTripleFor]), so
  // an unspecified SDK would produce names `fetch` never requests.
  if (targetOS == OS.iOS && iosSdk == null) {
    throw UsageException(
      '--ios-sdk is required when --target-os is ios.',
      parser.usage,
    );
  }
  if (targetOS != OS.iOS && iosSdk != null) {
    throw UsageException(
      '--ios-sdk is only valid when --target-os is ios.',
      parser.usage,
    );
  }

  final staticModes = switch (results.option('compile-type')) {
    'dynamic' => const [false],
    'static' => const [true],
    _ => const [false, true],
  };

  final root = packageRoot ?? Directory.current.uri;
  final outDir = Directory.fromUri(
    root.resolve('${results.option('out-dir')}/'),
  );
  await outDir.create(recursive: true);

  final targetTriple = targetTripleFor(targetOS, targetArch, iosSdk: iosSdk);
  stdout.writeln('==> Precompiling ${library.name} for $targetTriple...');

  final releaseConfig = library.releaseConfig;

  for (final static in staticModes) {
    final builtUri = customBuilder != null
        ? await customBuilder(
            targetOS: targetOS,
            targetArch: targetArch,
            iosSdk: iosSdk,
            static: static,
            packageRoot: root,
          )
        : await library.buildStandalone(
            targetOS: targetOS,
            targetArchitecture: targetArch,
            static: static,
            iOSSdk: iosSdk,
            packageRoot: root,
            checkoutPath: checkoutPath,
          );

    final assetName =
        releaseConfig?.resolveAssetName(
          targetOS,
          targetArch,
          iosSdk: iosSdk,
          static: static,
        ) ??
        (static
            ? targetOS.staticlibFileName(library.name)
            : targetOS.dylibFileName(library.name));

    final releaseAsset = File.fromUri(outDir.uri.resolve(assetName));
    await File.fromUri(builtUri).copy(releaseAsset.path);
    stdout.writeln('==> Created release binary: ${releaseAsset.path}');
  }
}
