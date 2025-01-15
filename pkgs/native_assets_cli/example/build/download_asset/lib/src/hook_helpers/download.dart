// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:native_assets_cli/code_assets_builder.dart';

import 'c_build.dart';
import 'version.dart';

Uri downloadUri(String target) => Uri.parse(
    'https://github.com/dart-lang/native/releases/download/$version/$target');

Future<File> downloadAsset(
  OS targetOS,
  Architecture targetArchitecture,
  IOSSdk? iOSSdk,
  Directory outputDirectory,
) async {
  final targetName = targetOS.dylibFileName(createTargetName(
    targetOS.name,
    targetArchitecture.name,
    iOSSdk?.type,
  ));
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

Future<String> hashAsset(File assetFile) async {
  // TODO(dcharkes): Should this be a strong hash to not only check for download
  // integrity but also safeguard against tampering? This would protected
  // against the case where the binary hoster is compromised but pub is not
  // compromised.
  final fileHash = md5.convert(await assetFile.readAsBytes()).toString();
  return fileHash;
}
