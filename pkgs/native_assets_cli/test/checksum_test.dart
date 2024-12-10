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
                    buildAssetTypes: [assetType],
                  )
                  ..setupBuildConfig(dryRun: dryRun, linkingEnabled: linking)
                  ..setupCodeConfig(
                    targetArchitecture: Architecture.arm64,
                    linkModePreference: LinkModePreference.dynamic,
                    buildMode: buildMode,
                  );
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
      '3afc417379877ec7280b53258a72645e',
      '986147109fd67a6e6430d1703d4ba6a4',
      '390c1d8887cac2222f6aaa4ca1901b1d',
      'a2031ac703b726644e55feff0c7998a4',
      '801088189566f50fe90fe7170da90183',
      '8ba8301ae5377b09bb68e2c1db5879b5',
      'a32794290d784565715d8a8e1bf60002',
      '4d6aa96309297e01a1c496ba7a7b54c5',
      'b69a835c452c3edf7a5e9c1fc2a83a5f',
      '78e98f3911a5d5af2747f64cb6a23969',
      '60cf3c5edea13dbfc24cdd32070f8e7a',
      '8370808ee3047dcffe0ccc531d0be9dd',
      '34972fb4d7d6515758e9a6bf973f48b9',
      '4b7680552075fbb52fe4296acddfdfc8',
      'ab89942b62dd2bd3b205172c7f7bcb6b',
      '72f9f56185f6a5345b95b218a86c6783',
      '2c3a780a9638b4c4d2b20780e1e0e29e',
      '01c2643fb01f1b6624ebcd533c1ec3c2',
      '84e868b93d2acea37a3264222b550690',
      'e7f1303da62e5b6e9d059e620c75eaea',
      '759917e7ad61be646cf65395aa316eb3',
      '27b61baf20a7e21fdf5c9326696020bf',
      '1d2cc30a899fc928cc6cff27293cd9b7',
      '366da09f263d021c4be84b586e05db05',
      '1a8f6ada78b1018bf002745a2f757777',
      '5485077f07833255feb24689dbc8a566',
      'f96939ac337bebf6cb9694fbba48ea9c',
      '691c4f107fc3752f3ae8a5d7f03153e5',
      '6634ac9d584adb0a16c3824f960a276f',
      '8054c31db96c133302845cecad825530',
      '085de916df9cb13f173d03d5c8a886a4',
      '19d38519db956d1ceb63e043f28c8152',
      'ef98199267bdda8af74f1b8c2d5e5848',
      '3f0f8da2449a43b2dbf3de73229c8211',
      '66f127af3a898266ffae80dd7228be29',
      '911c193950f8bf8e9e6cf7f881e5a458',
      '892d3ffa4b049c942f61e415c102464b',
      '24bf6b84a1283c9c9c508e073f958378',
      '230267554e82f44dfe87a44cdc12ae80',
      '412720c8d707e71a292c919d52f84307',
      'f7fb9de0d209218a3753e36c81ed0a42',
      'bc591cc1f83f4e466d8c461b7ae9e980',
      '457ab08bade95a96b30e6f975482d182',
      '257e1b9c9c4e5a63678d440a0ec6a2a6',
      '654fbb39fe7b1e99e5ce0e12bfed2602',
      '94c530c1e1ae16d7b16de76f1d30fafb',
      'cf0655281a366b5d07c098dd58b1a8f8',
      '4adde8bcaf20bccb334da06c643a2272',
      '49cf030abd3970c76701178e578ff507',
      'acca8292948400e33ea9b6ae8a11fc61',
      '90c522fcf03dd928a562a384035a34ae',
      '09332daabb7870e4ca35619f9c6772e1',
      'd8eba8ff4adc4b406938927e8c3f13e3',
      'ff119d2ecf1ac08ed794f581069d784f',
      'aa31fafc0ff4b1f8b5a5280fde184cfb',
      '98193215aa93a976b475e96f0dfba3be',
      '875ddcc7485958acfd8ef28a7b9b8f39',
      'ade4c6d9ab881e44edb27906cccf6939',
      '576eb46797aab7369d2e6e7d1c55c534',
      '21b1c3290d6c2272d9c744a3e1561c6a',
      'aa5f2a2cd496a910609a753c9ff49c66',
      'efd0fe669261bac298b7c720107a7a26',
      '05ba0d56d2b45a17388702b2b5419814',
      '89468cd1ffaee1396c532499790414a8',
    ];
    printOnFailure('final expectedChecksums = <String>[');
    printOnFailure(checksums.map((e) => "  '$e',").join('\n'));
    printOnFailure('];');
    for (var i = 0; i < checksums.length; ++i) {
      expect(checksums[i], expectedChecksums[i]);
    }
  });
}
