// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:code_assets/code_assets.dart';

import 'targets.dart';

/// Resolves the remote release asset filename for a target and link mode.
typedef AssetNameResolver = String Function(
  OS os,
  Architecture arch, {
  IOSSdk? iosSdk,
  required bool static,
});

/// Resolves the local OS-specific library filename for [os] and [static].
typedef LibraryFileNameResolver = String Function(
  OS os, {
  required bool static,
});

/// Resolves the download [Uri] for a given release [version] and
/// [assetRemoteName].
typedef DownloadUriResolver = Uri Function(
  String version,
  String assetRemoteName,
);

/// Configuration for fetching and verifying prebuilt release binaries.
class PrebuiltReleaseConfig {
  /// The release version string (e.g. `'0.4.1'` or `'2.0.0-beta2'`).
  final String version;

  /// Map from remote asset filename (as returned by [resolveAssetName]) to its
  /// lower-case hexadecimal SHA-256 digest.
  final Map<String, String> fileHashes;

  /// Returns the remote download [Uri] for [version] and an asset name.
  final DownloadUriResolver resolveDownloadUri;

  /// Returns the remote asset filename for a given target and `static` mode.
  final AssetNameResolver resolveAssetName;

  /// Returns the canonical OS library filename (e.g. `libfoo.dylib`,
  /// `libfoo.a`, `foo.dll`) for a given [OS] and `static` mode.
  final LibraryFileNameResolver resolveLibraryFileName;

  const PrebuiltReleaseConfig({
    required this.version,
    required this.fileHashes,
    required this.resolveDownloadUri,
    required this.resolveAssetName,
    required this.resolveLibraryFileName,
  });

  /// Creates a [PrebuiltReleaseConfig] backed by GitHub Releases at
  /// `https://github.com/<owner>/<repo>/releases/download/<tagPrefix><version>/<assetName>`.
  ///
  /// By default:
  /// - [resolveLibraryFileName] returns
  ///   `os.staticlibFileName(staticLibraryName ?? libraryName)` when `static`
  ///   is `true`, and `os.dylibFileName(libraryName)` when `false`.
  /// - [resolveAssetName] returns
  ///   `<assetPrefix ?? repo>-<targetTriple>-<libraryFileName>` (see
  ///   [targetTripleFor]). Pass a custom [resolveAssetName] for other release
  ///   naming schemes (for example, Rust target triples).
  factory PrebuiltReleaseConfig.github({
    required String owner,
    required String repo,
    required String version,
    required Map<String, String> fileHashes,
    required String libraryName,
    String? staticLibraryName,
    String? assetPrefix,
    String tagPrefix = 'v',
    AssetNameResolver? resolveAssetName,
    LibraryFileNameResolver? resolveLibraryFileName,
  }) {
    String defaultLibraryFileName(OS os, {required bool static}) => static
        ? os.staticlibFileName(staticLibraryName ?? libraryName)
        : os.dylibFileName(libraryName);

    final libFileName = resolveLibraryFileName ?? defaultLibraryFileName;
    final prefix = assetPrefix ?? repo;

    String defaultAssetName(
      OS os,
      Architecture arch, {
      IOSSdk? iosSdk,
      required bool static,
    }) =>
        '$prefix-${targetTripleFor(os, arch, iosSdk: iosSdk)}-'
        '${libFileName(os, static: static)}';

    return PrebuiltReleaseConfig(
      version: version,
      fileHashes: fileHashes,
      resolveDownloadUri: (ver, assetName) => Uri.parse(
        'https://github.com/$owner/$repo/releases/download/$tagPrefix$ver/$assetName',
      ),
      resolveAssetName: resolveAssetName ?? defaultAssetName,
      resolveLibraryFileName: libFileName,
    );
  }
}
