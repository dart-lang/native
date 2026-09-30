// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:crypto/crypto.dart';
import 'package:hooks/hooks.dart';
import 'package:logging/logging.dart';

import 'logging.dart';
import 'release_config.dart';
import 'targets.dart';

/// Resolves or downloads the pre-built library for the target of [input] using
/// [releaseConfig], caching it in [HookInput.outputDirectoryShared] under an
/// ABI-specific subdirectory so the leaf filename matches the canonical OS
/// library name (required for iOS/macOS XCFrameworks).
///
/// If [prebuiltDirectory] is provided and a matching binary exists inside the
/// package at `<packageRoot>/<prebuiltDirectory>/`, it is used without making
/// any network requests. Bundled binaries are verified against
/// [PrebuiltReleaseConfig.fileHashes] when a hash is registered for them, and
/// trusted as part of the package otherwise.
///
/// Downloads are streamed to a temporary file while hashing, then atomically
/// moved into the cache. Transient failures (network errors, timeouts, HTTP
/// 5xx) are retried up to [maxAttempts] times.
///
/// Returns `null` if no hash is registered in
/// [PrebuiltReleaseConfig.fileHashes], if the server responds with a
/// non-retryable HTTP status, or if all download attempts fail. Throws a
/// [BuildError] if a binary's SHA-256 checksum does not match.
///
/// [canBuildFromSource] only affects the hint in the checksum-mismatch error.
Future<Uri?> fetchPrebuiltLibrary(
  HookInput input,
  PrebuiltReleaseConfig releaseConfig, {
  required bool static,
  String? prebuiltDirectory,
  bool canBuildFromSource = false,
  Logger? logger,
  Duration connectionTimeout = const Duration(seconds: 30),
  Duration idleTimeout = const Duration(seconds: 60),
  int maxAttempts = 3,
}) async {
  final log = logger ?? defaultLogger;
  final targetOS = input.config.code.targetOS;
  final targetArch = input.config.code.targetArchitecture;
  final iosSdk = targetOS == OS.iOS ? input.config.code.iOS.targetSdk : null;
  final pkg = input.packageName;

  final assetRemoteName = releaseConfig.resolveAssetName(
    targetOS,
    targetArch,
    iosSdk: iosSdk,
    static: static,
  );
  final fileName = releaseConfig.resolveLibraryFileName(
    targetOS,
    static: static,
  );
  final cachedFile = File.fromUri(
    input.outputDirectoryShared
        .resolve('$pkg-${releaseConfig.version}/$assetRemoteName/')
        .resolve(fileName),
  );
  final expectedHash = releaseConfig.fileHashes[assetRemoteName];
  final hasHash = expectedHash != null && expectedHash.isNotEmpty;

  Never mismatch(String actualHash, String source) => throw BuildError(
    message:
        'SHA-256 hash mismatch for prebuilt binary $assetRemoteName '
        '($source).\n'
        'Expected: $expectedHash\n'
        'Actual:   $actualHash\n'
        '${canBuildFromSource ? 'To build $pkg from source instead, set '
                  '`buildMode: build` under `hooks.user_defines.$pkg` in '
                  'your pubspec.yaml.' : ''}',
  );

  // 1. A pub-bundled prebuilt binary in `prebuiltDirectory`.
  if (prebuiltDirectory != null) {
    final triple = targetTripleFor(targetOS, targetArch, iosSdk: iosSdk);
    final candidates = [
      File.fromUri(
        input.packageRoot.resolve('$prebuiltDirectory/$assetRemoteName'),
      ),
      File.fromUri(
        input.packageRoot.resolve('$prebuiltDirectory/$triple/$fileName'),
      ),
    ];
    for (final bundledFile in candidates) {
      if (!await bundledFile.exists()) continue;
      if (hasHash) {
        final actual = await _hashFile(bundledFile);
        if (actual != expectedHash) mismatch(actual, bundledFile.path);
      }
      log.info('$pkg: using bundled prebuilt binary (${bundledFile.path}).');
      await _atomicCopy(bundledFile, cachedFile);
      return cachedFile.uri;
    }
  }

  // 2. A registered SHA-256 hash is required for anything downloaded.
  if (!hasHash) {
    log.info('$pkg: no prebuilt binary hash registered for $assetRemoteName.');
    return null;
  }

  // 3. The shared cache.
  if (await cachedFile.exists() &&
      await _hashFile(cachedFile) == expectedHash) {
    log.info('$pkg: using cached prebuilt binary ($assetRemoteName).');
    return cachedFile.uri;
  }

  // 4. Download from the release.
  final binaryUrl = releaseConfig.resolveDownloadUri(
    releaseConfig.version,
    assetRemoteName,
  );
  await cachedFile.parent.create(recursive: true);
  final client = HttpClient()
    ..findProxy = HttpClient.findProxyFromEnvironment
    ..connectionTimeout = connectionTimeout;
  try {
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      log.info(
        '$pkg: fetching prebuilt binary from $binaryUrl'
        '${attempt > 1 ? ' (attempt $attempt of $maxAttempts)' : ''}...',
      );
      final tempFile = File('${cachedFile.path}.download-$pid');
      try {
        final request = await client.getUrl(binaryUrl);
        final response = await request.close();
        if (response.statusCode != HttpStatus.ok) {
          await response.drain<void>();
          final retryable = response.statusCode >= 500;
          log.info(
            '$pkg: failed to download from $binaryUrl '
            '(status: ${response.statusCode}).',
          );
          if (retryable && attempt < maxAttempts) {
            await _backoff(attempt);
            continue;
          }
          return null;
        }
        final digest = _DigestSink();
        final hashInput = sha256.startChunkedConversion(digest);
        final fileSink = tempFile.openWrite();
        try {
          await for (final chunk in response.timeout(idleTimeout)) {
            hashInput.add(chunk);
            fileSink.add(chunk);
          }
        } finally {
          await fileSink.close();
        }
        hashInput.close();
        final actualHash = digest.value.toString();
        if (actualHash != expectedHash) {
          await tempFile.delete();
          mismatch(actualHash, binaryUrl.toString());
        }
        log.info('$pkg: verified SHA-256 checksum ($actualHash).');
        await tempFile.rename(cachedFile.path);
        return cachedFile.uri;
      } on Exception catch (e) {
        // IOException (network), TimeoutException, HttpException, ...
        if (await tempFile.exists()) await tempFile.delete();
        log.info('$pkg: error downloading prebuilt binary ($e).');
        if (attempt < maxAttempts) await _backoff(attempt);
      }
    }
    return null;
  } finally {
    client.close(force: true);
  }
}

Future<void> _backoff(int attempt) =>
    Future<void>.delayed(Duration(milliseconds: 500 * attempt));

Future<String> _hashFile(File file) async =>
    (await sha256.bind(file.openRead()).first).toString();

/// Copies [source] to [destination] via a temporary file so concurrent hook
/// invocations never observe a partially written [destination].
Future<void> _atomicCopy(File source, File destination) async {
  await destination.parent.create(recursive: true);
  final temp = await source.copy('${destination.path}.copy-$pid');
  await temp.rename(destination.path);
}

class _DigestSink implements Sink<Digest> {
  late Digest value;

  @override
  void add(Digest data) => value = data;

  @override
  void close() {}
}
