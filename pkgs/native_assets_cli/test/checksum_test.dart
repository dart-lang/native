// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:native_assets_cli/code_assets_builder.dart';
import 'package:native_assets_cli/data_assets_builder.dart';
import 'package:test/test.dart';

void main() {
  test('checksum', () async {
    // metadata, cc, link vs build, metadata, haslink
    final configs = <String>[];
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
                configs.add(
                    const JsonEncoder.withIndent(' ').convert(builder.json));
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
    final expectedChecksums = <String>[
      '05cdbdf4976a68c33e75e6b57781c5f5',
      'c36ad7dc2f0846ed134029edaeb59195',
      '7f90e825f08edafe99ac7314d02f46e0',
      '82279ed0fb55f7e02b8e6cf857b5a7b9',
      '8aa77a554828663ccfdb30d026caf729',
      '6a69060c347c20000354bb9e7cca21f5',
      'c0a1cd20d08aa29044af633dec235b36',
      '72a098e698316a60e6ca2b67c4de82b1',
      '16dc68a85ea9cab4a9d35c77f9d8bc6c',
      'fbb47d28d4db2082f331a6710ae293f6',
      'c557d0bffbf479b85861a648ceda8912',
      '7c23bce4887d70915a5d5824142cb75f',
      '88d164985687d11445a1bba4c83b299e',
      'e6b3d1a31ea2ea2c37babbf8a52393de',
      'dfe63dab862fa7789f3bf4ad882c87c7',
      'b146d5dfbcb2bfdd295cdd548832d717',
      '4267a4d5f5b7e1ae3278e590cab52e48',
      '461e627475397d461da3c985e17466ba',
      '2e5d01733c132b2801e3068bf008e023',
      'aee031592879b62e8512cc73a064c883',
      '439222774886f776f2da9a5c0051310f',
      'a59d7e43b0a9562518863d6379fddd16',
      '90a0e05df0f56c8d33b3bdbe7ff785b3',
      'e00db5df53778da8aaecace162d20325',
      'b4f8ef47ab0a43f0760c68d66297f1a8',
      '17c758237c24c96e1d92a4681ba2b889',
      'dd6ee4832b2c11d31a2488f671d13e9a',
      '7ac636c075bcc1423e80c635fed6de6c',
      '427db33751df11daa8dc9809614b66e6',
      'c8d5918f01d365e0d6c2a1d610a47d1d',
      '534fce1b658242d7942f3eb6e4ca987d',
      '3dcea3a8a52eebea225eacd44ee370f1',
      '55fe838d0d2a01e288b3faed2adc7a04',
      '80727044903ebea814198f4001fdebf0',
      '6198b46894c081193b9209f9ddb66b3d',
      '856c0ffe90c97d9629e847ba1b3bbb67',
      '3e3d7e551f1392f53d73fd3362693184',
      '5244e64af596a46940892b28739737e2',
      '8a875dc22c02d815e16f50386d03195d',
      '50464749a3288f2d655ccef290835776',
      '1982534a5ba2f13f8ed5b4ba38386d8c',
      '012e03aad8221afab6200718f7e68fa6',
      '9ddaa64eadc3b21ba48d77062a12bee7',
      'f2b802ce9d7c055f721e017db5582312',
      'abc578f0fe5c4a4c43b185a7940d0dd7',
      '771cd5ab05e5838cccf4a75cc224f506',
      'd41f53ff6aca0cdd74bbea8b0c26b83e',
      '24c8e4535afc18981f7470cbd05a5787',
      'fddca58e36cc89868114bb399bc6cec2',
      'fec6330fac0d3d9316f2f580602fc06a',
      '092c7130962283f35d5de02604cc3852',
      '130517517742ea571ab39d69f56c87a0',
      'e17135e1be677fb428a761b6c3b5f421',
      '510c5b24f5bbd414917c96444ff41df3',
      '75993da8d1508dc1e556096da0a7c00f',
      'aad9665f7c2a8e28e99c92a90d0f2168',
      'bab93955a78ab99e6157b1568e4b03d1',
      'f2ad0bb263fd38d9fba3ca9ed5c7c66b',
      '7743132a908a48c183a75d8c25635de6',
      '3b326f5a0ef295d3109bcf95a63b446e',
      'e0775404b93fadf74f5bce5410854346',
      'd1fd0e95194d8d4bc513666e2067548c',
      '0541de11331a9ca647f7cbde69c1abf4',
      'c8c85515946c890e3056f379ca757cfe',
    ];
    for (var i = 0; i < checksums.length; ++i) {
      if (checksums[i] != expectedChecksums[i]) {
        print('Expected ${expectedChecksums[i]} but was ${checksums[i]}');
        print('Config:\n${configs[i]}');
      }
      expect(checksums[i], expectedChecksums[i]);
    }
  });
}
