// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'dart:io';

import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import 'helpers.dart';

const Timeout longTimeout = Timeout(Duration(minutes: 5));

void main() async {
  test('use_dart_api build', timeout: longTimeout, () async {
    await inTempDir((tempUri) async {
      await copyTestProjects(targetUri: tempUri);
      final packageUri = tempUri.resolve('use_dart_api/');
      await runPubGet(
        workingDirectory: packageUri,
        logger: logger,
      );

      // Assume we're run from Dart SDK and try to find the include dir.
      final includeDirectory = dartExecutable.resolve('../include/');
      final versionFile = includeDirectory.resolve('dart_version.h');
      final versionContents =
          await File(versionFile.toFilePath()).readAsString();
      final regex = RegExp(
          r'#define DART_API_DL_MAJOR_VERSION (\d+)\s*#define DART_API_DL_MINOR_VERSION (\d+)');
      final match = regex.firstMatch(versionContents)!;
      final major = int.parse(match.group(1)!);
      final minor = int.parse(match.group(2)!);
      final dartCApi = DartCApi(
        includeDirectory: includeDirectory,
        version: Version(major, minor, 0),
      );

      // Run the build.
      final result = (await buildCodeAssets(
        packageUri,
        dartCApi: dartCApi,
      ))!;
      final codeAsset = CodeAsset.fromEncoded(result.encodedAssets.single);

      // Check that we can load the dylib and run the init.
      final dylib = DynamicLibrary.open(codeAsset.file!.toFilePath());
      final initDartApiDl = dylib.lookupFunction<IntPtr Function(Pointer<Void>),
          int Function(Pointer<Void>)>('InitDartApiDL');
      final initResult = initDartApiDl(NativeApi.initializeApiDLData);
      expect(initResult, 0);
    });
  });
}
