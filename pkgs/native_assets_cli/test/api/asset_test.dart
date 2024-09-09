// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:test/test.dart';

void main() {
  test('Asset constructors', () async {
    final assets = [
      NativeCodeAsset(
        id: 'package:my_package/foo',
        file: Uri.file('path/to/libfoo.so'),
        linkMode: DynamicLoadingBundled(),
        os: OS.android,
        architecture: Architecture.x64,
      ),
      NativeCodeAsset(
        id: 'package:my_package/foo3',
        linkMode: DynamicLoadingSystem(Uri(path: 'libfoo3.so')),
        os: OS.android,
        architecture: Architecture.x64,
      ),
      NativeCodeAsset(
        id: 'package:my_package/foo4',
        linkMode: LookupInExecutable(),
        os: OS.android,
        architecture: Architecture.x64,
      ),
      NativeCodeAsset(
        id: 'package:my_package/foo5',
        linkMode: LookupInProcess(),
        os: OS.android,
        architecture: Architecture.x64,
      ),
      NativeCodeAsset(
        id: 'package:my_package/bar',
        file: Uri(path: 'path/to/libbar.a'),
        os: OS.linux,
        architecture: Architecture.arm64,
        linkMode: StaticLinking(),
      ),
      NativeCodeAsset(
        id: 'package:my_package/bla',
        file: Uri(path: 'path/with spaces/bla.dll'),
        linkMode: DynamicLoadingBundled(),
        os: OS.windows,
        architecture: Architecture.x64,
      ),
      DataAsset(
        package: 'my_package',
        name: 'data/some_text.txt',
        file: Uri(path: 'data/some_text.txt'),
      ),
    ];
    assets.toString();
  });

  test('toString', () {
    StaticLinking().toString();
    DynamicLoadingBundled().toString();
    DynamicLoadingSystem(Uri.file('foo.so')).toString();
    LookupInProcess().toString();
    LookupInExecutable().toString();
  });

  test('Errors', () {
    expect(
      () => NativeCodeAsset(
        id: 'package:my_package/foo',
        file: Uri.file('path/to/libfoo.so'),
        linkMode: LookupInExecutable(),
        os: OS.android,
        architecture: Architecture.x64,
      ),
      throwsArgumentError,
    );
  });
}
