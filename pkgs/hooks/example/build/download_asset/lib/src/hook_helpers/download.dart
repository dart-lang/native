// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:crypto/crypto.dart';

import 'c_build.dart';
import 'version.dart';

/// Constructs the download URI for a given [target] file name.
Uri downloadUri(String target) => Uri.parse(
  'https://github.com/dart-lang/native/releases/download/$version/$target',
);

/// Downloads an asset for the specified [targetOS], [targetArchitecture], and
/// [iOSSdk].
Future<File> downloadAsset(
  OS targetOS,
  Architecture targetArchitecture,
  IOSSdk? iOSSdk,
  Directory outputDirectory,
) async {
  final targetName = targetOS.dylibFileName(
    createTargetName(targetOS.name, targetArchitecture.name, iOSSdk?.type),
  );
  final uri = downloadUri(targetName);
  final request = await HttpClient().getUrl(uri);
  final response = await request.close();
  if (response.statusCode != 200) {
    throw ArgumentError('The request to $uri failed.');
  }
  final library = File.fromUri(outputDirectory.uri.resolve(targetName));
  await library.create();
  await response.pipe(library.openWrite());
  return library;
}

/// Computes the MD5 hash of the given [assetFile].
Future<String> hashAsset(File assetFile) async {
  // TODO(dcharkes): Should this be a strong hash to not only check for download
  // integrity but also safeguard against tampering? This would protected
  // against the case where the binary hoster is compromised but pub is not
  // compromised.
  final fileHash = md5.convert(await assetFile.readAsBytes()).toString();
  return fileHash;
}
