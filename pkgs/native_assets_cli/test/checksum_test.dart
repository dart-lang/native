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
      '14467cab1bec35bf16fb8c2f4cb6674e',
      '09167db5c99bdb7885e1ce56f3d322db',
      '650772a5e6639815cb90fc382a2d3b74',
      '992eb4527cf1063f82102e90da1a8b3b',
      '8a59d2c6c1838c201f51a61d581ca58c',
      'bb1065211dd4bd4bc09127eabb8e0d59',
      '9ea5e05985d33473215c61d761231efb',
      'dca9f3b1dee3ca3cd99bf09846b7b05a',
      '0560df60824772923c28a911a288c0a7',
      'd57299126dc6d2152b1227757c5e69db',
      'b8bd03516fec369bd3961587b9200bd0',
      '1ae91509da85a70735cd82573fd15034',
      '59c4ddf2dbc17f8f29bc34344fca0129',
      'c6817e34ad4ace2429ee700ea9aafaa5',
      '59a2ca5f19310116711a5d3116ba48a2',
      '2e6ad514c35dfe0ef6e807406f5aad91',
      'c6988649cadeb6be599b27fb62c79441',
      '8b4597c6c37ec390bd61f1b2d594cf4f',
      'c4983d1ae610c2ad2a8b13c06b19bca1',
      'fd49106d6de59e357b4fc08fc8ecadca',
      '9c2ac9e569e599fb9a836db63c8650a0',
      '2a9662ad8edd94a4639f316a0f1720f5',
      'fbcaec48c1e6a0c975b3cbe7b0d5b0bf',
      '2ee945d328dc1076f779d4ef406fab9b',
      '2da299e6faf63a5832f3c55d0bca6526',
      '5930992ec9350aaab2beaf52a7834046',
      '2979e8e78ce570b26d099918a07160db',
      '1cba6703c6c0ed21bf8e0461c76518a6',
      '0b0699db219436c24723a1c41fbaf9b0',
      '94cf39317b30c975326f3a82e1121cc9',
      '24184c50c99204efdcd69b433a1ad558',
      '34bb5fbeefcb8785a83ac28ea7d71f60',
      '34a006a2215e9000797b87c245b5c76e',
      '7a25aabe33082b6dd8c8cde30cede29f',
      'bf0aeb2b671a525b3aab9c92d98f88dd',
      '4728bbd9ca0b2ee47c28d802acaacff2',
      'c1eec49274a61e7651770efd9faf84fc',
      '90e668957ef8ef35ef66290e66a0f15c',
      '2ff397bd4b8fd01e07ae23774a3f8528',
      '98709d874b873f988e76458f39066c6d',
      '3b5c330f37413d3280d5768c6644dbf2',
      '7532763af0b47a892d0ee33286e3b90e',
      '0fabe0fb6901347900622977dd32286e',
      'fe21838f4287bcc3136f6bc3b459ef6d',
      '461e0fa108606e344d27d2a6b253921f',
      'd6f37cf47b243b8341572bb59dc3a94e',
      'ac7760a8df3292af12e544a051771626',
      'd4963d201d80d3e71f3a1b9f8782d9ee',
      '2370a5aba28f2620aab069c1956319b6',
      '41ac2dfbdf2e41d7206566b83b81168e',
      'b9c6b602b2129b83f4827b0e45bf1116',
      '54a21fce89d60f21c919810cb8a7f7f3',
      'ee5afa17e3d7e1d775aa38dd670788b7',
      '4eec6cff58e8c5ce65f6df7ca7675d4a',
      '187f30b16822cbcb8b20955a48b4b934',
      'ac7dc37446380c7a79a248bbb807ce8c',
      '71d8c4dd59fc6f1ac02cadb28c17dae2',
      '5c639983a598930470ee207f83953dba',
      '97ff526835ac8d7c6511f8f51ce19595',
      '0ea93279778827004ec8100113cf9449',
      'c7ec217ff823f30358ab1b7c74a402d8',
      '47ae4d4dd0953da542072e376d9689b0',
      '14afd786c5906860a854a3839d30660d',
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
