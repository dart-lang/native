// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: undefined_hidden_name

import 'package:native_assets_builder/src/model/asset.dart';
import 'package:native_assets_cli/native_assets_cli_internal.dart'
    hide AssetIterable, AssetRelativePath;
import 'package:test/test.dart';

void main() {
  final fooUri = Uri.file('path/to/libfoo.so');
  final foo2Uri = Uri.file('path/to/libfoo2.so');
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
      id: 'foo2',
      path: AssetRelativePath(foo2Uri),
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

  final assetsDartEncoding = '''format-version:
  - 1
  - 0
  - 0
native-assets:
  android_x64:
    foo:
      - absolute
      - ${fooUri.toFilePath()}
    foo2:
      - relative
      - ${foo2Uri.toFilePath()}
    foo3:
      - system
      - ${foo3Uri.toFilePath()}
    foo4:
      - executable
    foo5:
      - process
  linux_arm64:
    bar:
      - absolute
      - ${barUri.toFilePath()}
  windows_x64:
    bla:
      - absolute
      - ${blaUri.toFilePath()}''';

  test('asset yaml', () async {
    final fileContents = assets.toNativeAssetsFile();
    expect(fileContents, assetsDartEncoding);
  });

  test('List<Asset> whereLinkMode', () async {
    final assets2 = assets.whereLinkMode(LinkMode.dynamic);
    expect(assets2.length, 6);
  });

  test('satisfy coverage', () async {
    expect(() => assets[1].toYaml(), throwsUnimplementedError);
  });
}
