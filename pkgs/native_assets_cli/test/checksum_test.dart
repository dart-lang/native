// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/code_assets_builder.dart';
import 'package:native_assets_cli/data_assets_builder.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  test('checksum', () async {
    // metadata, cc, link vs build, metadata, haslink

    final checksums = <String>[];
    final inputs = <String, Object?>{};

    for (final hook in ['build', 'link']) {
      for (final linking in [true, if (hook == 'build') false]) {
        for (final assetTypes in [
          [CodeAsset.type],
          [CodeAsset.type, DataAsset.type],
          [DataAsset.type],
        ]) {
          for (final os in [
            OS.android,
            if (assetTypes.contains(CodeAsset.type)) OS.iOS,
            if (assetTypes.contains(CodeAsset.type)) OS.macOS,
          ]) {
            for (final architecture in [
              Architecture.arm64,
              if (assetTypes.contains(CodeAsset.type)) Architecture.x64,
            ]) {
              for (final targetVersion in [
                if (os == OS.android) 30,
                if (os == OS.iOS) flutteriOSHighestBestEffort,
                if (os == OS.iOS) flutteriOSHighestSupported,
                if (os == OS.macOS) defaultMacOSVersion,
              ]) {
                for (final iOSSdk in [
                  if (architecture == Architecture.arm64 && os == OS.iOS)
                    IOSSdk.iPhoneOS,
                  IOSSdk.iPhoneSimulator,
                ]) {
                  final builder = BuildInputBuilder();
                  if (hook == 'build') {
                    builder.config.setupBuild(
                      dryRun: false, // no embedders will pass true anymore
                      linkingEnabled: linking,
                    );
                  }
                  builder.config.setupShared(buildAssetTypes: assetTypes);
                  if (assetTypes.contains(CodeAsset.type)) {
                    builder.config.setupCode(
                      targetArchitecture: architecture,
                      targetOS: os,
                      android: os == OS.android
                          ? AndroidCodeConfig(targetNdkApi: targetVersion)
                          : null,
                      macOS: os == OS.macOS
                          ? MacOSCodeConfig(targetVersion: targetVersion)
                          : null,
                      iOS: os == OS.iOS
                          ? IOSCodeConfig(
                              targetVersion: targetVersion,
                              targetSdk: iOSSdk,
                            )
                          : null,
                      linkModePreference: LinkModePreference.dynamic,
                    );
                  }
                  final checksum = builder.computeChecksum();
                  checksums.add(checksum);

                  if (inputs[checksum] != null) {
                    expect(builder.json['config'], inputs[checksum]);
                  }
                  inputs[checksum] = builder.json['config'];
                }
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
      '24ccf8d332a8c8d55e476dc3c6bc583b',
      '7f36bc59f947abd6af6cee575138e754',
      'd0aba834036fead9bab453d527eae4ed',
      '1ceb39975433d22ece4a862af5ebc13e',
      '92a29907211743f4dfa05214efca2f5b',
      '43579d544a56d1c2f41324690122e16f',
      'd88c23a4c520275ed03e9b8edee48674',
      '2765b39d6a39e71712109588acf05c03',
      '66a6f953369ef21ee2576e4e3fde3ad3',
      '611a7687747e116ddcc7e50d8ac079d4',
      'c92a32ed941614b8343197d1d42fa27e',
      '7498ff7cbb07d9d2dd127377b30f26fa',
      '5c0a592096625690802ac0671f4034e0',
      '65e125ee71ea5fe4bc79d54003cab931',
      '790b552e75a98b90a77455da90c1ea87',
      '98fba8ecfc7dd07c798503dfc87da0bb',
      '7784fdf4afe8b22c017c5d3f7983777b',
      'eff20a22ed0e429fa20c1458a2c1f0b8',
      'c4b179cfd16d663ae58bd1a06618d23b',
      'd31c785c41b9d852aef30251a46bf214',
      'a89fc3d8de5647d6825b47592e5dd7b5',
      'f13c6adb12346391761a9e0fcfa37568',
      '887b0c294956ffe456687778a80913f7',
      'c0cb2fe6ed8f7bc27d0fb166a139c31e',
      'c51f6b56cd8083e2e6d9d5db2997c7fd',
      '9ccb0b5e6f39d3655f7ef2cb1b3f02b7',
      '440a909a495e1445cc89392176fceec8',
      '99e61d87aaaba64b91cedffcb50c521b',
      'f0150c4470ef8e9917d1f500b60f0a8b',
      'bce703d4756f1345959d99f371f70be7',
      'c24f96a671ac4320163ba6ad01e08c22',
      '4813128ab93a41cf6a2ba92e1ac87bd8',
      '6b8f417d14bdc9cdda90122dc2e16ca4',
      '306ae22675d94f717eb58db9bfd7ac14',
      'b4c4531503bd3f814367e78081f183f2',
      'c5903374f46c510508f9d6314ac82c2d',
      'd5bf990a551941d29309dbdd26c0cdf1',
      'e773863012e1cea85b39134357c12c45',
      '36eb9110b66f57866c565495fa145f02',
      'b527b041d448d9d3938391348b2b296d',
      '9f9a66ee78bdec8e4dab4a63029dbde3',
      '0376b13decbf88bc0901b7c853f76bb0',
      '527bbf58f698036f78b5519553186d0f',
      '8e937a8834d9fcb697b5a3c80ac04dd0',
      '4358d31df880c53face01c18945fa14b',
      '518e6a0bed957d3e5e88a18a44532ca2',
      '614152ce8d7b591916d78838711b75f9',
      '0f89f3db1d379ec581b4e896f5060d0a',
      'f7a554031e353366b157d5af0a774bf8',
      'a96c3052f878d4d08585b640ea77970e',
      '7c3f0134505f73c91825ea837f1e885e',
      '575b6bd07de1a3fdb150b7626526bd47',
      'ecdfaaa2f4bc2708375e6e6a980578a8',
      '06c509e166c7fa7d8ac8c56806da53ba',
      'dfb39e5ac164e4f269fb7e9ae084a2a4',
      '1b3cbac826b58a001e3ed7539f55f652',
      '6fbc5b8630c3d27abf3a810051dd9271',
      '43025538d82ed0492a5928aefb0767ab',
      '0172735fa45b76ec9f8c3a0416608721',
      '547dfca0aa25ffa8e68ae1218c19b339',
      '19e984d77d877f7d5a20eb8fe523bee6',
      '5f644023cc187fe71f01daccc9bdbe76',
      'bbdaf85e3a026c0bd87a56e7102a6beb',
    ];
    printOnFailure('final expectedChecksums = <String>[');
    printOnFailure(checksums.map((e) => "  '$e',").join('\n'));
    printOnFailure('];');
    for (var i = 0; i < checksums.length; ++i) {
      expect(checksums[i], expectedChecksums[i]);
    }
  });
}

const flutteriOSHighestBestEffort = 16;
const flutteriOSHighestSupported = 17;
