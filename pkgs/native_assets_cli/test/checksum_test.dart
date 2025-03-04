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
                      // no embedders will pass true anymore
                      linkingEnabled: linking,
                    );
                  }
                  builder.config.setupShared(buildAssetTypes: assetTypes);
                  if (assetTypes.contains(CodeAsset.type)) {
                    builder.config.setupCode(
                      targetArchitecture: architecture,
                      targetOS: os,
                      android:
                          os == OS.android
                              ? AndroidCodeConfig(targetNdkApi: targetVersion)
                              : null,
                      macOS:
                          os == OS.macOS
                              ? MacOSCodeConfig(targetVersion: targetVersion)
                              : null,
                      iOS:
                          os == OS.iOS
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
      '373d25ca3201cf61ff42048b5fe67c24',
      '76c914f249d8e0dec9ea88eedd796737',
      '03846a8382cf6f5052f82f9917562e70',
      'b219b76aa364c90168b4a1e57372c7a0',
      '61288538db9d98b280f5c27dc094aeb8',
      'fde745d50ebcc6d16d312fdc493a30c5',
      '65444c11c83a84e63b974e3643a10da7',
      'aaee85324a2b2ddc9d641c4cef1780a9',
      '9cbb27c2c60e6336985f7083715eeb15',
      '2898b73da7fd05f28b066ab212aff277',
      '7b823719e472096087c6dc6ed16c1322',
      'f11f9e90c3611524429786301a345763',
      '1939726b2173808f28e1de412165f541',
      'a56d14a636b307825d9dca40531ebbe4',
      '6c9f6b3254a394727bef590cc9bcf7c2',
      '2ed14db4ec08a01cdd293a91201b668b',
      'c6558f264707b7cec3ba59a213a51a07',
      'b9bdf9933922c88f1f858565aed2f9b2',
      '04b4dd22c9917cea4d0876d3a4a7c076',
      '89b4df38c0750b959e3b91556b5340c5',
      'a648f38bcc571d5800d549fa9146c161',
      '9d6255bb88e0c174cfd73326374653fb',
      '3a5c1e777cb824b9df6e8812db7f014f',
      '569bbc36d2252ad007e86bbbc91cab4a',
      '85f5f97cd1b4c42f88e77d23bf9337d2',
      'db76cd3ef567bc0a20a805d7ff78c89b',
      '81861002f1a66a0d0edbd8191a550b9d',
      '4b5e64761e6a8aaafc489ed0d627caa5',
      '6e493366b0ff7e397134fcc004840b61',
      'fcdb6b85f369b18ce0bf6e71dfed9711',
      '6505fb7e18c7572486d4bceb9267c829',
      '2f208ebb3f2a86fadf16f30d6eb83c60',
      '8a1a8a1378f0205cf82b39d6d9ef0c06',
      '3d9a25a9a4724ef6b9c4098117d476ea',
      '427caa5594959f686108440aae237d23',
      '3b1fd713e83549612ec6813fc21d406d',
      '35e34c04cb001ef1df0a91debe4ec876',
      '1d44781858b032eab6081840a33cb992',
      '0dec96f613afa0481e7359069060cc3d',
      '1a2b62ccd83da975b42752c5a136d104',
      'e132b66dbb18e36e85dfa0c817a74590',
      '59bc110e371c5e9c8b04f6453d09584d',
      '8ee9d30cc420cd9212348d2c4222c6ee',
      '70e422b86e227f740b9a72980d0d12d8',
      'fc6fbfe32afac158157cb02dde609e52',
      '5dec2c2e2ff5ba0403ae6ff7d7ae5b3b',
      '116057a6e64e3aaf95cdbd70dd056bce',
      '07b4c2e72d4a3c2cb684edff2037bd38',
      '91c7ff44c0d157514eba5f01ac960dd9',
      'c5b859d9d1d59cd46368ebbabb78902f',
      '8b94ecb5699de5730c8545abafe30c11',
      '936624d135da96cdfc0dd7b038909521',
      'b158baa7fc7a12252592f02e672e31a7',
      '47514c281f37a35ba6b70090dadf787d',
      '0de0ab1c36a35279d6f7fc2a1d69174f',
      'dc97054090baaaf646f73d11c9142293',
      '153aa59e1a9dc2667a69c1388ef2dca9',
      '5d4c049a66acc31f54d2a99d2b8ecf98',
      '36f450524b4ab720c243c3daf54ff283',
      '8d701a6f5446d10c1f965eece8cf4b8a',
      'd7e29713d72316e019e0f512f91b432d',
      '19be742ac2c24d9764de06aba70a31eb',
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
