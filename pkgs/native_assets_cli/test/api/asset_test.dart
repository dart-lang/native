// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:test/test.dart';

void main() {
  test('Asset constructors', () async {
    final assets = [
      CCodeAsset(
        id: 'foo',
        path: AssetAbsolutePath(Uri.file('path/to/libfoo.so')),
        target: Target.androidX64,
        linkMode: LinkMode.dynamic,
      ),
      CCodeAsset(
        id: 'foo3',
        path: AssetSystemPath(Uri(path: 'libfoo3.so')),
        target: Target.androidX64,
        linkMode: LinkMode.dynamic,
      ),
      CCodeAsset(
        id: 'foo4',
        path: AssetInExecutable(),
        target: Target.androidX64,
        linkMode: LinkMode.dynamic,
      ),
      CCodeAsset(
        id: 'foo5',
        path: AssetInProcess(),
        target: Target.androidX64,
        linkMode: LinkMode.dynamic,
      ),
      CCodeAsset(
        id: 'bar',
        path: AssetAbsolutePath(Uri(path: 'path/to/libbar.a')),
        target: Target.linuxArm64,
        linkMode: LinkMode.static,
      ),
      CCodeAsset(
        id: 'bla',
        path: AssetAbsolutePath(Uri(path: 'path/with spaces/bla.dll')),
        target: Target.windowsX64,
        linkMode: LinkMode.dynamic,
      ),
    ];
    assets.toString();
  });
}
