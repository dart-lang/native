// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_test_helpers/native_test_helpers.dart';
import 'package:test/test.dart';

void main() {
  // These examples are referenced to in resources external to this repository
  // such as:
  // - https://dart.dev The Dart website.
  // - https://pub.dev/packages/ The example tab of packages.
  // - https://pub.dev/documentation/ The package API references.
  // - Tutorial video descriptions.
  //
  // Therefore, these examples should:
  // 1. never move, and
  // 2. not change in scope.
  //
  // We commit to keeping these samples evergreen, so that any developers
  // following those external links will find the most up to date version of the
  // sample.
  //
  // Note: Developers _might_ find a version of the sample that doesn't work
  // just yet, since a package version has not been published. However, that is
  // a small price to pay for the maintainers of this repo only ever having to
  // worry about a single version.
  test('Do not move externally referenced samples.', () {
    final packageRoot = findPackageRoot('code_assets');
    final example = packageRoot.resolve('example/');
    const buildCLibraryFromSource = [
      // The essence of this sample is building with native_toolchain_c.
      'native_toolchain_c',
      'CBuilder.library(',
    ];
    const filesMustExist = <String, List<String>?>{
      'host_name/hook/build.dart': [
        // The essence of this sample is accessing a system API.
        'DynamicLoadingSystem',
        'LookupInProcess',
      ],
      'mini_audio/hook/build.dart': buildCLibraryFromSource,
      'sqlite_prebuilt/hook/build.dart': [
        // The essence of this sample is downloading a prebuilt binary.
        '_windowsDownloadInfo',
      ],
      'sqlite/hook/build.dart': buildCLibraryFromSource,
      'stb_image/hook/build.dart': buildCLibraryFromSource,
    };
    for (final fileMustExist in filesMustExist.keys) {
      final file = File.fromUri(example.resolve(fileMustExist));
      expect(file, _exists);
      final mustContain = filesMustExist[fileMustExist];
      if (mustContain != null) {
        final readAsStringSync = file.readAsStringSync();
        for (final needle in mustContain) {
          expect(readAsStringSync, contains(needle));
        }
      }
    }
  });
}

bool _exists(Object? file) {
  if (file is! File) {
    throw Exception('$file is not a File.');
  }
  if (file.existsSync()) {
    return true;
  }
  throw Exception('File $file does not exist.');
}
