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
          [BuildAssetType.code],
          [BuildAssetType.code, BuildAssetType.data],
          [BuildAssetType.data],
        ]) {
          for (final os in [
            OS.android,
            if (assetTypes.contains(BuildAssetType.code)) OS.iOS,
            if (assetTypes.contains(BuildAssetType.code)) OS.macOS,
          ]) {
            for (final architecture in [
              Architecture.arm64,
              if (assetTypes.contains(BuildAssetType.code)) Architecture.x64,
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
                    builder.config.setupBuild(linkingEnabled: linking);
                  }
                  if (assetTypes.contains(BuildAssetType.code)) {
                    builder.addExtension(
                      CodeAssetExtension(
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
                      ),
                    );
                  }
                  if (assetTypes.contains(BuildAssetType.data)) {
                    builder.addExtension(DataAssetsExtension());
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
      '61ab5ef403d9f006b6b5574a50e50daf',
      'e3a77db8c85c6b3549c8421e59e38e95',
      'e7a12aac9e17ddbb64887cd6cd9232d2',
      'cf1dd12731866d00afbbcdfe70e61589',
      'ad93ea8c702c5f11c92c52191883099c',
      '38c7c121e0c15cf54c984824e5051f4c',
      'c08bfcfb8272762b33a98f79bf350724',
      'e1270f247e192dc50b652621ae2e5a93',
      'e78c9baa330705077190565d8a847fb1',
      '9ad4121bade1db392de9ce083c13fc8f',
      'e5e00070ef4bc56a7ce3069424df4120',
      '838b8de06f73db3cea251697402babb0',
      '589ee41a4f1fdaaa428406cada32c4e3',
      '4746317758d511ffd2f47c44ea1e9ff8',
      '61773dc007d379d913773be8dab6d027',
      'cbdc799766b327b719acda0c8fa362df',
      '81ab30daef84759670866735ab9bdafe',
      'c3b5b08d9dfd763eefe1548fe1cebd15',
      '817d7a4498017835e17ed855fdcc810e',
      '43bf049e1e796472d5bf91b225026cda',
      'edeadb00c19dd64b77617ae191e4bedd',
      'c31e4bfcd55d57f37ca1e1ec96ffe592',
      'ab4f63c8d2bb35fa00568e682b800843',
      '2ef2c44c9571c14aeccae1d99f32a1b4',
      '553911c58185ec4bc0a91d38066f04b8',
      'bab035bb051f235c39b78e5607a8a01c',
      'c011395901dd42b098f486d2ff06a4dd',
      'e9f7fadde6dab0e7cc4ac0c7fb1a628c',
      'ebba044d322c1ceb81cf4e1e7c0e120e',
      '0b282c055b7817b099f84613af0c5c8a',
      '9a8e06eedabd3c6001aa114064390ce9',
      '75515f1094704fa6cfd486e506d2af18',
      'c86127d13e36019097d0707baf98e8f7',
      '4667534582f16a6551428fd045b3ac27',
      'f94ee3512b58bcc7f55e5f518d9441ce',
      '799b09a9cb7041165adc850c3bc34607',
      '1c2bddd1f0a1e8b889ca5b46817694f0',
      'af00c3aa5215cab39e58a696b886dc37',
      'c1505e20a93de1ab1143a79e965cd245',
      '31f2609c732d83722c420f8fb8465830',
      '7cd688235b6d1d8edb2f81fecb0a8da4',
      '81bac5e642e7b84dbd5fb1f71b07962d',
      '1a78f75ee147bbb5edf68b2e56e78a22',
      '9d6adcd09c95cc55d80f6cac5cc93590',
      '55fc558767c6e43269dc3de4556562ab',
      '9edb0db4a6b1e629f8fa949e42dc35e1',
      'd30575bba443794ee26b362fcd177406',
      '29d89c1c649dd8e60d2d4be8c8f87fae',
      'a304174ba2dcf0146bdd5b311bea9479',
      '7e55d4def09b16926719d5c3267ca6b8',
      '89bed1462b388cfed8e20a9f5d2cbb97',
      '3d6cb538997816a0c051748607352a79',
      'f33556a6cbc01e6e1390fdcb9f3aa82c',
      '20cf1a9119f96e519419e1b83633e289',
      '6b965e47445f5ff5549ff87b5b5d73c7',
      '64fffab256c810f794441a0f207d1691',
      'b4c4b511d1744f61eb95758e3a54386d',
      '20a0433b2ea9181634efa432d671a77e',
      '517b3c6690c52e6c2f905c22a6aa0096',
      'ebc520c76af5f114423363be7b025586',
      '7769c411f18744248a58b52d63ace420',
      '1baf5b978ec51f44383c407d31dc5ebf',
      '9fe464ec313e3465c9e43e12ec4fa5df',
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

enum BuildAssetType { code, data }
