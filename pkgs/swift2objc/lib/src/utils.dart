// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

Future<String> _runStdout(String executable, List<String> arguments) async {
  final process = await Process.start(executable, arguments);
  final s = StringBuffer();
  process.stdout.transform(utf8.decoder).listen(s.write);
  process.stderr.listen(stderr.add);
  if ((await process.exitCode) != 0) {
    throw ProcessException(executable, arguments);
  }
  return s.toString();
}

Future<String> hostTargetTriple = () async {
  final info =
      json.decode(await _runStdout('swiftc', ['-print-target-info'])) as Map;
  final target = info['target'] as Map;
  return target['triple'] as String;
}();

const iOSArmTargetTripleUnversioned = 'arm-apple-ios';
const iOSArm64TargetTripleUnversioned = 'arm64-apple-ios';
const iOSX64TargetTripleUnversioned = 'x86_64-apple-ios';
const macOSArm64TargetTripleUnversioned = 'arm64-apple-macosx';
const macOSX64TargetTripleUnversioned = 'x86_64-apple-macosx';

// Eg: Extracts "15.2" from ".../MacOSX15.2.sdk/"
final _versionRegExp = RegExp(r'/[^0-9]*([0-9.]+)\.sdk/$');
String _parseVersion(Uri sdk) => _versionRegExp.firstMatch(sdk.path)!.group(1)!;

Future<String> _versionedTargetTriple(
  String unversionedTriple,
  Future<Uri> sdk,
) async => '$unversionedTriple${_parseVersion(await sdk)}';

Future<String> iOSArmTargetTripleLatest = _versionedTargetTriple(
  iOSArmTargetTripleUnversioned,
  iOSSdk,
);
Future<String> iOSArm64TargetTripleLatest = _versionedTargetTriple(
  iOSArm64TargetTripleUnversioned,
  iOSSdk,
);
Future<String> iOSX64TargetTripleLatest = _versionedTargetTriple(
  iOSX64TargetTripleUnversioned,
  iOSSdk,
);
Future<String> macOSArm64TargetTripleLatest = _versionedTargetTriple(
  macOSArm64TargetTripleUnversioned,
  macOSSdk,
);
Future<String> macOSX64TargetTripleLatest = _versionedTargetTriple(
  macOSX64TargetTripleUnversioned,
  macOSSdk,
);

Future<Uri> hostSdk = _findSdk([]);
Future<Uri> macOSSdk = _findSdk(['--sdk', 'macosx']);
Future<Uri> iOSSdk = _findSdk(['--sdk', 'iphoneos']);

Future<Uri> _findSdk(List<String> args) async => Uri.directory(
  (await _runStdout('xcrun', [...args, '--show-sdk-path'])).trim(),
);
