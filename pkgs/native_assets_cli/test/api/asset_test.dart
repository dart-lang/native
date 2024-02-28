// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:native_assets_cli/src/api/asset.dart';
import 'package:test/test.dart';

void main() {
  test('Asset constructors', () async {
    final assets = [
      CCodeAsset(
        id: 'package:my_package/foo',
        file: Uri.file('path/to/libfoo.so'),
        dynamicLoading: BundledDylib(),
        os: OS.android,
        architecture: Architecture.x64,
        linkMode: LinkMode.dynamic,
      ),
      CCodeAsset(
        id: 'package:my_package/foo3',
        dynamicLoading: SystemDylib(Uri(path: 'libfoo3.so')),
        os: OS.android,
        architecture: Architecture.x64,
        linkMode: LinkMode.dynamic,
      ),
      CCodeAsset(
        id: 'package:my_package/foo4',
        dynamicLoading: LookupInExecutable(),
        os: OS.android,
        architecture: Architecture.x64,
        linkMode: LinkMode.dynamic,
      ),
      CCodeAsset(
        id: 'package:my_package/foo5',
        dynamicLoading: LookupInProcess(),
        os: OS.android,
        architecture: Architecture.x64,
        linkMode: LinkMode.dynamic,
      ),
      CCodeAsset(
        id: 'package:my_package/bar',
        file: Uri(path: 'path/to/libbar.a'),
        os: OS.linux,
        architecture: Architecture.arm64,
        linkMode: LinkMode.static,
      ),
      CCodeAsset(
        id: 'package:my_package/bla',
        file: Uri(path: 'path/with spaces/bla.dll'),
        dynamicLoading: BundledDylib(),
        os: OS.windows,
        architecture: Architecture.x64,
        linkMode: LinkMode.dynamic,
      ),
      DataAsset(
        id: 'package:my_package/data/some_text.txt',
        file: Uri(path: 'data/some_text.txt'),
      ),
    ];
    assets.toString();
  });

  test('Errors', () {
    expect(
      () => CCodeAsset(
        id: 'package:my_package/foo',
        file: Uri.file('path/to/libfoo.so'),
        dynamicLoading: BundledDylib(),
        os: OS.android,
        architecture: Architecture.x64,
        linkMode: LinkMode.static,
      ),
      throwsArgumentError,
    );
    expect(
      () => CCodeAsset(
        id: 'package:my_package/foo',
        file: Uri.file('path/to/libfoo.so'),
        os: OS.android,
        architecture: Architecture.x64,
        linkMode: LinkMode.dynamic,
      ),
      throwsArgumentError,
    );
    expect(
      () => CCodeAsset(
        id: 'package:my_package/foo',
        file: Uri.file('path/to/libfoo.so'),
        dynamicLoading: LookupInExecutable(),
        os: OS.android,
        architecture: Architecture.x64,
        linkMode: LinkMode.dynamic,
      ),
      throwsArgumentError,
    );

    final staticLinkingAsset = CCodeAsset(
      id: 'package:my_package/foo',
      file: Uri.file('path/to/libfoo.so'),
      os: OS.android,
      architecture: Architecture.x64,
      linkMode: LinkMode.static,
    );
    expect(
      () => staticLinkingAsset.dynamicLoading,
      throwsStateError,
    );
  });
}
