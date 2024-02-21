// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: undefined_hidden_name

import 'package:native_assets_builder/src/model/kernel_assets.dart';
import 'package:native_assets_cli/native_assets_cli_internal.dart';
import 'package:test/test.dart';

void main() {
  final fooUri = Uri.file('path/to/libfoo.so');
  final foo2Uri = Uri.file('path/to/libfoo2.so');
  final foo3Uri = Uri(path: 'libfoo3.so');
  final barUri = Uri(path: 'path/to/libbar.a');
  final blaUri = Uri(path: 'path/with spaces/bla.dll');
  final assets = KernelAssets([
    KernelAsset(
      id: 'foo',
      path: KernelAssetAbsolutePath(fooUri),
      target: Target.androidX64,
    ),
    KernelAsset(
      id: 'foo2',
      path: KernelAssetRelativePath(foo2Uri),
      target: Target.androidX64,
    ),
    KernelAsset(
      id: 'foo3',
      path: KernelAssetSystemPath(foo3Uri),
      target: Target.androidX64,
    ),
    KernelAsset(
      id: 'foo4',
      path: KernelAssetInExecutable(),
      target: Target.androidX64,
    ),
    KernelAsset(
      id: 'foo5',
      path: KernelAssetInProcess(),
      target: Target.androidX64,
    ),
    KernelAsset(
      id: 'bar',
      path: KernelAssetAbsolutePath(barUri),
      target: Target.linuxArm64,
    ),
    KernelAsset(
      id: 'bla',
      path: KernelAssetAbsolutePath(blaUri),
      target: Target.windowsX64,
    ),
  ]);

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
}
