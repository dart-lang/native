// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:math';

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
      '10d9fce0028fdbb72b5994307ebf227c',
      '4116af41354c68fd64b58cb6a308ebbb',
      '157fda96bdf938d4fe055180bf4dbabc',
      'c5507af2f5f7e8601710c5c2fffb6188',
      '2ab19c5f0f4c8f6c17826f6fabca2e6e',
      'c7c3e28d58191051c70c2748aa1377ef',
      'f81cf883235927d5cca9d510c2446a3a',
      '8396b8b2541fe6ee9f39ece6aede06b6',
      '9e092722bb54a9bdc6434119786a538c',
      'd2d421c2c497ff6a16bbd43f4ba27152',
      '6c45154e7e0be87367fd000a9386aa2a',
      '4b1257c34a3de0ce91171eadb84be35f',
      '7a9a8d4a6e226dbd08e3c591e379d967',
      '996f318e4d30a472358d7f21eb14585b',
      '7adf24fb2f2cac19d41f439fed3fa5d8',
      '99574fa166e54a5c740d0e85f46bc5af',
      '2c592c067f97ed13d900bc2bb8c16f86',
      'e5b8f39328001ed0417e8cd70aad4fa8',
      '923b4534ee62e50b596e04aaf1392901',
      '4df91b08cd288e9a5069a5fe55c64395',
      'dde8372e52f886b8293f6b691a7b76f1',
      'bfeb49adc617a567671c78936130af4c',
      'de7b54bfd2d9ab26796951592967dca2',
      'f3e73bb91a351c1743e81cd32babf90c',
      'ac98097f3d916d7bde50d9c67b2a8d9e',
      'c87086e206e304191a13baed3f29da9e',
      'c85ced6ed90adc35f0dd03b27486d66e',
      'aed9f8805210068380e2556b1bab0a99',
      'e4314b23825c872590bbb384c1072cb8',
      '3f9b69de7a31c609a4b6ec125adcaca5',
      '0102baa7f1f5071aefa90a18179d0d7d',
      '40f84eefd62ff9062b78b655ad3ee6b1',
      '723e2805985a094838464d4ab4e0af7d',
      'f5ca710868b73059ce61ded27bd0faac',
      '1b0e1ad58ff192d204ca9750505b2d55',
      'a2def75febdaa8a332fc588ee3ef8014',
      '59a936e9e646387fcf322a794b753b54',
      '8f5945499965afcb5d6eebf30bbacb77',
      '4ed56caadaf9079c96dcec668624bf2a',
      '0f2a4864df014a824034f9e29ed48ee8',
      '0aed524d105e71a3bfd432ade52ed132',
      '6ba03bd61a4d8979fcd64e5b6ae245b6',
      'cd70cfa54dad2b6859d5c1d23b83b074',
      '2aa7bf1eda6a6fb1bf3edaadcbb9a804',
      'b6fd8e4dc466f8aa1b758134d454b191',
      '22c71b4626f3f59463e1276afccfd2fb',
      '70ff946f65f2d46be9b323d45e4edf0e',
      '7862c709b255bde8debb5ee06ddbcd74',
      'b948929ac5fd276c69ab9f76e5b280f0',
      'aa479a711b010893b3bfb46d68028ed7',
      '74c9bf5365c62bd9655f7b773b5e5113',
      'bc6224160b985a2c338f414899eed664',
      '78ec380b3257d8b4ca35006e922978bd',
      'c0656028d1e11a2b6cd972464e23cd30',
      '11b75baa322bd7cb1362852fc4238a0e',
      '6eff070403ac6171ff42fdfbdc1a36ea',
      '9d026a26c3788e9d2606ee0c5e0e0e10',
      '2dcc623fce0dfc380761b9e2f396d955',
      '9ce27557bb269768d25b5f1bd8ffdfa4',
      'e9b1c4c9511c02c64c2112dc16924598',
      'b38af392d228d193ba3d3943d7bb189a',
      'ab5753aa337cf91a224fe89e53173324',
      'a99ffcf470d3b570fed923bbf7257d37',
      '630d35827f0193efbb1b439d792ebe23',
    ];
    printOnFailure('final expectedChecksums = <String>[');
    printOnFailure(checksums.map((e) => "  '$e',").join('\n'));
    printOnFailure('];');
    for (var i = 0; i < checksums.length; ++i) {
      expect(checksums[i], expectedChecksums[i]);
    }
  });
}
