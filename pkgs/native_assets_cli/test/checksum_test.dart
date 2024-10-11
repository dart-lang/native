// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/native_assets_cli_internal.dart';
import 'package:test/test.dart';

void main() {
  test('checksum', () async {
    // metadata, cc, link vs build, metadata, haslink
    final checksums = <String>[];
    for (final os in [OS.linux, OS.macOS]) {
      for (final buildMode in [BuildMode.release, BuildMode.debug]) {
        for (final packageName in ['foo', 'bar']) {
          for (final assetType in [CodeAsset.type, DataAsset.type]) {
            for (final dryRun in [true, false]) {
              for (final linking in [true, false]) {
                final builder = BuildConfigBuilder()
                  ..setupHookConfig(
                    packageRoot: Uri.file('foo'),
                    packageName: packageName,
                    targetOS: os,
                    supportedAssetTypes: [assetType],
                    buildMode: buildMode,
                  )
                  ..setupBuildConfig(dryRun: dryRun, linkingEnabled: linking);
                checksums.add(builder.computeChecksum());
              }
            }
          }
        }
      }
    }
    // As all variants have something different, we expect the checksums to be
    // unique.
    expect(checksums.toSet().length, checksums.length);

    // If format or algorithm for checksumming changes we'd like to know (by
    // needing to update this list).
    expect(checksums, [
      'ba2bc300017587a47517a4572526b933',
      '26ccc134a7a0dbca796c084da8a8f2ab',
      '9353b5a4743d5846966982c617f8c6d3',
      '38256f2a773b1d2e4bdc75ae08fc5aca',
      '2e7889e3525851cb5f52917c1433f276',
      '636c833769cbc78ebe6c50aa143bdb7c',
      'ff5af0c4a25ad97bea69046d90816795',
      '6d0d5e14aeeb05df47ac0a609834a919',
      '43d41135168d8ddeba8bd75a5ecdd23b',
      '5a13ce6c9e3631caf83541d53490503e',
      'b2c53aa181d573f773c531d33a4ecaaa',
      '75dcb30bbc0881082c336d94f04ba6cf',
      'c0d52057e60ec03f6e1e353c833cdb58',
      '873ffa4c448ba9a4700c7287969265c5',
      'fd5d647936a2359641f005c1f63d6c9b',
      'd6c94a9cc87ceee6bdbddcf6b1a44430',
      'c317380eafe0d801d69ad41527817e4c',
      '88e797f27103025280032ea58dfe3286',
      '602a6129ed715ef7f0d64f1a3d06c79d',
      '35b049dbbfc14eafe6eff9784fbc043c',
      'c7d2dcad8a49fb378c1156bc3e0eb076',
      '099bd7788d3d1035a9ef0703bc8c5e3a',
      'b4127e80ac8ff38350c0561219bd4829',
      '1e0c648381278c5f8a1e700117b68481',
      'f31b2395ece58f7ce0050401fbfc6ee3',
      'd7e0c607f6c273191935fe3c503f5edc',
      'c764f9a7d1fe73f7e25914785822228f',
      '6631019d7da3f4895f73a8552b594ed7',
      '3c6e6ae969948fdf2d5483c25cf4de9b',
      '453c7605eb2530da9f73370d0b547b74',
      '064065551068620fc01871981d7d78be',
      '5fb0fef97089d96b73b2e36c472d3ea3',
      '5d031c711a4c967d69230300884043b4',
      '6766828a69d373a5cca7b8d6ab02de68',
      'e0b5b6179fa12fca7c6c485fff6c9604',
      'e96485164e8cd8cc67786a695aa1ef41',
      '54b31167d328cef00adccaa1a58817a2',
      '0220c1091cfbffd04c04b7a4c85042f1',
      'b28fa401faa29491a44196d26a97b207',
      '361a44ba78a1d1c83a3ac69c54698427',
      '1f1d1e5c34e55fc2befd1d9c8406c6e6',
      '5a5b2e61f4bd2d6becf09794c076052c',
      'e876ee447141fcf3340fd2be9e0e7150',
      'f39056ec56716ac8126d028f5b173af3',
      '9583a43d92f68823bf7ed48cee58a31f',
      '55bad15339b118e2a5499d9c6e4d6712',
      'a13a80b07b2652e875ad2d6085c1d18b',
      '32c7e1206e515c1d1e70ce377297d54b',
      '6a184b55796ea1e881d770e738b7ab50',
      'f8447318c2425bb9b61867b3893c076e',
      '3799d315dcd32cb4ef04f7c696864a97',
      '03e5f35bbddb6eabb31d204956553929',
      '38a184c0de890152e827818d91262a03',
      '89712caccd036a44d57532af16b5edac',
      '25262ba7da76224ac55b25fc2c0f72e7',
      'b9a88e9fd06e9f5d61f21ff2f2bbb7a1',
      'e13d2a99df2448b3c3dda18ed4e25d10',
      'ef0b2152ae957394bb790cfa253297ad',
      '7d64c455ce832456b15c11d363fb78f5',
      'f8f697616faeb8a37c754cb5753b87a9',
      'ebb22b7ebe0e7ac29ce841cc237a941f',
      'b527639217b053dde60a34d7fb0d576b',
      '1b5b1ef52b505d5858eb30d86ccd26a2',
      'fc4654d784f30ab97a72f089ad7e5684',
    ]);
  });
}
