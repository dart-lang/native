// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:crypto/crypto.dart';

import '../release_config.dart';
import '../targets.dart';

/// CLI runner for `tool/regenerate_hashes.dart`.
///
/// Usage: `dart tool/regenerate_hashes.dart [<version> [<local-dir>]]`.
///
/// Computes SHA-256 digests for all [targets] and [staticModes] either from a
/// local directory (`args[1]`, e.g. in CI before/during a release) or by
/// downloading from the release URLs returned by [releaseConfigForVersion].
/// Writes the resulting hashes to [hashesFilePath] (and optionally updates
/// [versionFilePath], which must be in the same directory).
///
/// Assets that don't exist (missing local file or HTTP 404) are skipped, since
/// not every release contains every target. Any other error (network failure,
/// unexpected HTTP status) aborts without writing files when [failOnError] is
/// `true` (the default), so a release never ships an incomplete manifest.
Future<void> runRegenerateHashesCli(
  List<String> args, {
  required String defaultVersion,
  required PrebuiltReleaseConfig Function(String version)
  releaseConfigForVersion,
  String hashesFilePath = 'lib/src/hook_helpers/hashes.dart',
  String? versionFilePath = 'lib/src/hook_helpers/version.dart',
  String versionConstName = 'releaseVersion',
  String licenseHeader = '',
  List<TargetSpec> targets = supportedTargets,
  List<bool> staticModes = const [false, true],
  bool failOnError = true,
}) async {
  final hashesFile = File(hashesFilePath);
  final versionFile = versionFilePath == null ? null : File(versionFilePath);
  if (versionFile != null &&
      versionFile.absolute.parent.path != hashesFile.absolute.parent.path) {
    throw ArgumentError.value(
      versionFilePath,
      'versionFilePath',
      'must be in the same directory as hashesFilePath ($hashesFilePath)',
    );
  }

  final version = args.isNotEmpty ? args[0] : defaultVersion;
  final localDir = args.length > 1 ? Directory(args[1]) : null;
  final releaseConfig = releaseConfigForVersion(version);
  final httpClient = localDir == null
      ? (HttpClient()
          ..findProxy = HttpClient.findProxyFromEnvironment
          ..connectionTimeout = const Duration(seconds: 30))
      : null;

  stdout.writeln('Checking hashes for version $version...');
  final fileHashes = <String, String>{};
  final errors = <String>[];

  try {
    for (final (os, arch, iosSdk) in targets) {
      for (final static in staticModes) {
        final assetName = releaseConfig.resolveAssetName(
          os,
          arch,
          iosSdk: iosSdk,
          static: static,
        );
        if (localDir != null) {
          final file = File.fromUri(localDir.uri.resolve(assetName));
          if (!await file.exists()) {
            stdout.writeln('  Skipping missing local file: ${file.path}');
            continue;
          }
          final fileHash = (await sha256.bind(file.openRead()).first)
              .toString();
          fileHashes[assetName] = fileHash;
          stdout.writeln('  $assetName: $fileHash');
          continue;
        }

        final uri = releaseConfig.resolveDownloadUri(version, assetName);
        stdout.writeln('Fetching from $uri...');
        try {
          final request = await httpClient!.getUrl(uri);
          final response = await request.close();
          if (response.statusCode == HttpStatus.notFound) {
            stdout.writeln('  Skipping: not found');
            await response.drain<void>();
            continue;
          }
          if (response.statusCode != HttpStatus.ok) {
            await response.drain<void>();
            errors.add('$uri: HTTP ${response.statusCode}');
            continue;
          }
          final fileHash = (await sha256.bind(response).first).toString();
          fileHashes[assetName] = fileHash;
          stdout.writeln('  $assetName: $fileHash');
        } on Exception catch (e) {
          errors.add('$uri: $e');
        }
      }
    }
  } finally {
    httpClient?.close(force: true);
  }

  if (errors.isNotEmpty) {
    final message =
        'Failed to hash ${errors.length} asset(s):\n  ${errors.join('\n  ')}';
    if (failOnError) {
      throw StateError('$message\nNo files were written.');
    }
    stderr.writeln('Warning: $message');
  }

  final header = StringBuffer();
  if (licenseHeader.isNotEmpty) {
    header.write(licenseHeader);
    if (!licenseHeader.endsWith('\n')) header.writeln();
    header.writeln();
  }

  final filesToFormat = <String>[hashesFilePath];
  if (versionFile != null) {
    await versionFile.writeAsString(
      '$header'
      'const $versionConstName = ${_dartString(version)};\n',
    );
    filesToFormat.add(versionFile.path);
  }

  final buffer = StringBuffer()
    ..write(header)
    ..writeln('// coverage:ignore-file')
    ..writeln('// THIS FILE IS GENERATED BY `tool/regenerate_hashes.dart`.')
    ..writeln();
  if (versionFile != null) {
    buffer
      ..writeln("import '${versionFile.uri.pathSegments.last}';")
      ..writeln()
      ..writeln('const version = $versionConstName;')
      ..writeln();
  } else {
    buffer
      ..writeln('const version = ${_dartString(version)};')
      ..writeln();
  }
  buffer
    ..writeln('/// Mapping from release asset name to SHA-256 hash.')
    ..writeln('const fileHashes = <String, String>{');
  for (final entry in fileHashes.entries) {
    buffer.writeln('  ${_dartString(entry.key)}:');
    buffer.writeln('      ${_dartString(entry.value)},');
  }
  buffer.writeln('};');

  await hashesFile.writeAsString(buffer.toString());
  final format = await Process.run(Platform.resolvedExecutable, [
    'format',
    ...filesToFormat,
  ]);
  if (format.exitCode != 0) {
    stderr.writeln(
      'Warning: `dart format` failed (exit code ${format.exitCode}):\n'
      '${format.stdout}${format.stderr}',
    );
  }
  stdout.writeln('Updated $hashesFilePath with ${fileHashes.length} hashes.');
}

/// Returns [value] as a single-quoted Dart string literal.
String _dartString(String value) {
  final escaped = value
      .replaceAll(r'\', r'\\')
      .replaceAll("'", r"\'")
      .replaceAll(r'$', r'\$')
      .replaceAll('\n', r'\n');
  return "'$escaped'";
}
