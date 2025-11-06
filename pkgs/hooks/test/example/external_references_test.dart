// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_test_helpers/native_test_helpers.dart';
import 'package:test/test.dart';

void main() {
  // These examples are referenced in resources external to this repository such
  // as:
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
    final packageRoot = findPackageRoot('hooks');
    final example = packageRoot.resolve('example/');

    // TODO(dcharkes): Migrate the samples referred to on
    // https://dart.dev/tools/hooks#example-projects to the samples in
    // package:code_assets.
    const filesMustExist = <String, List<String>?>{
      'build/native_add_library/hook/build.dart': [
        // Referred to from https://dart.dev/tools/hooks#example-projects.
        'CBuilder.library(',
      ],
      'build/native_add_app/bin/native_add_app.dart': [
        // Referred to from https://dart.dev/tools/hooks#example-projects.
      ],
      'build/download_asset/hook/build.dart': [
        // Referred to from https://dart.dev/tools/hooks#example-projects.
        'package:download_asset/src/hook_helpers/download.dart',
      ],
      'build/native_dynamic_linking/hook/build.dart': [
        // Referred to from https://dart.dev/tools/hooks#example-projects.
        'src/add.c',
        'src/math.c',
        'src/debug.c',
      ],
      'build/system_library/hook/build.dart': [
        // Referred to from https://dart.dev/tools/hooks#example-projects.
        'name: \'memory.dart\'',
      ],
      'build/use_dart_api/hook/build.dart': [
        // The essence of this sample is accessing the Dart C API.
        'src/dart_api_dl.c',
      ],
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
