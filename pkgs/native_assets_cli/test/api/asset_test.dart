// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:test/test.dart';

void main() {
  final fooUri = Uri.file('path/to/libfoo.so');
  final foo3Uri = Uri(path: 'libfoo3.so');
  final barUri = Uri(path: 'path/to/libbar.a');
  final blaUri = Uri(path: 'path/with spaces/bla.dll');
  final assets = [
    Asset(
      id: 'foo',
      path: AssetAbsolutePath(fooUri),
      target: Target.androidX64,
      linkMode: LinkMode.dynamic,
    ),
    Asset(
      id: 'foo3',
      path: AssetSystemPath(foo3Uri),
      target: Target.androidX64,
      linkMode: LinkMode.dynamic,
    ),
    Asset(
      id: 'foo4',
      path: AssetInExecutable(),
      target: Target.androidX64,
      linkMode: LinkMode.dynamic,
    ),
    Asset(
      id: 'foo5',
      path: AssetInProcess(),
      target: Target.androidX64,
      linkMode: LinkMode.dynamic,
    ),
    Asset(
      id: 'bar',
      path: AssetAbsolutePath(barUri),
      target: Target.linuxArm64,
      linkMode: LinkMode.static,
    ),
    Asset(
      id: 'bla',
      path: AssetAbsolutePath(blaUri),
      target: Target.windowsX64,
      linkMode: LinkMode.dynamic,
    ),
  ];

  test('Asset toString', () async {
    assets.toString();
  });
}
