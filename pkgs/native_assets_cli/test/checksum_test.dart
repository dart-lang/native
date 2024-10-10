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
      '49daf3450cda2d6f703fd1c5615723e1',
      '5b071ecc8b32a1dd7ae71cec893da765',
      '42e0e9ef9b52243b2a033708c5614692',
      '779e7bd31c6671c69c15bffe20b9b882',
      'e1684c0558449dc47dd6e95eed9c8f20',
      '42264730ed1bac426fd9b0de85ca355a',
      'fae528a60605783f326c1e61af02a943',
      '375be74dab1457c8ba637444654a4a3a',
      '390e8e89b417572229bf7f2c02883a3c',
      'd2931555f8c5f3610b45012f63fafae4',
      '423dc47a44ce262b6d1d30fd159752fe',
      '1616bd24aa7745c19272cb7776c740d8',
      '1dfafc3008d703fb5670cae22955e7f0',
      '27c8a7891663bdea5791f0a4a0b00f0a',
      '33628656d5ba5acff5ba6d672e6266e9',
      '6a99fa1285cdbdf07e7f2f16dd9c124f',
      '6d6fca403370aa7ea4ae309eb3e19272',
      '09aadc73a263858f3b0724c3ca1c886a',
      '920c1e3d286c746065652bfd2d740698',
      'cbf2c911f9d3e5b0d644b402d8feebd3',
      'ac36f6d4b530ddbd77d7c9fd93514bfc',
      'a77d9a81e1f66c43ba16743263516fc1',
      '7619ec268bb1c4da8116db2605bd2ab8',
      '3eaa505790a10afc93b4402799c735d2',
      'c9378ada5a069e0ea1f4906e6e981092',
      '2915954b795f02d688269214b3db0cf7',
      'c6c895b2c738ff19eba67044f0dbbbd0',
      '953a29fc8f4015a57fb44749dd576837',
      '4c6c58417ab2e732e9b2952fedacce68',
      '9cfb486089a705226ee8a138d14f7fd7',
      '8a9fc2ebf5cc1fa39cd03179a5959fad',
      'b956d47a5613b89e09f00763fc7b30b6',
      'fe690851eb75c9566fbf2060f8b37df9',
      'f29ec64febd078bd188041ccb7d545f7',
      '3f54f0ceca274275c71c4fa2ca3ef919',
      '9896e8326e43a114ca1fa833a00f0e80',
      '8f5c3abb4578159f37a3f585a4e52b62',
      'fd2e5b9cd4ccbe35a7b515f49b44a6f4',
      '90d3dfc0dab4617da8b3b261c6d42ed6',
      '4491024a82b1ae5545b3bb90f37c47bd',
      '491e8c4549b80de2de7366f75deb6fb7',
      'bf8ce548a070836411efc4ffab36f00d',
      '5562ecf90c8ea05f8cff98099a16c6bd',
      '451b5c9be02a42cb5cf6359355241f6a',
      '3b39694a45d1c427dbf24229ad88f969',
      'd4527aec8dc183f1f61819a414fe3a52',
      '95ea9db54a39dfc3d7eecbf120b93ee0',
      '2ac0ee9854562c6274749fdcc1fb3609',
      'd1ef410112e3f3ed8a98e1dc7e64f653',
      '5e05ca0cd3496beebe8f3a3c5dec2e3c',
      '3e2febea1b3c111eed26c9a5a6b90ef3',
      '969f85ffb945e52278b0b55b895f12a1',
      'd00132dd4a88b01e4071e8b1e1d6cf28',
      '5d940c16b18065eb2579a48d12a9cdd0',
      '144cbd4cd41f6bf3a3bee7b0776cff40',
      '793cd15349782e52b009a5337301c2b9',
      '676def9232cfb0ad832311cf6c29defb',
      '7010c8c6d8124e35b1c9ad643f219ffd',
      'd0b705242470e18b6caf62dc1765e70f',
      'e0874bd58e0a72f341406fef23979bd0',
      '4174d81f0fa117071a58abc5886cce45',
      '6221a8463b3978352a1cc6f0b0945f0a',
      '154c04f511463b7f73033559561ca88d',
      '66fc47c7320a7af96716f17c80b0eb3f',
    ]);
  });
}
