// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:code_assets/code_assets.dart';
import 'package:data_assets/data_assets.dart';
import 'package:hooks/hooks.dart';
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
                            ? MacOSCodeConfig(
                                deploymentVersion: AppleVersion(targetVersion),
                              )
                            : null,
                        iOS: os == OS.iOS
                            ? IOSCodeConfig(
                                deploymentVersion: AppleVersion(targetVersion),
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
      '61ab5ef403',
      'e3a77db8c8',
      '3ea25da965',
      '423d931460',
      'a9e58952da',
      'e0f390373a',
      'cb9b0daaf5',
      'dbd3b390f2',
      '2b5e22d8ea',
      '3483bf6e6d',
      'e5e00070ef',
      '838b8de06f',
      '80b3016468',
      '29542879ec',
      '4d96966445',
      '7d53abe072',
      '7124522282',
      '90bb7d2702',
      '3ec3326e87',
      'd7ef2863c0',
      'edeadb00c1',
      'c31e4bfcd5',
      'ab4f63c8d2',
      'f894a40ec5',
      '0437cdeffe',
      '14f0fa5413',
      '8347a20a92',
      '05aaf516e8',
      'ee4905d059',
      '9e4a03aece',
      '4106254ce2',
      '75515f1094',
      'c86127d13e',
      '8f95cd8f09',
      '60a1c72369',
      '7fd5c264b9',
      '1f66f4be41',
      '6fd45ab3c1',
      '0709f7cb54',
      'de86bf8147',
      '8799a1fa2a',
      '81bac5e642',
      '1a78f75ee1',
      '9d6adcd09c',
      '6d71a3a0bc',
      '96bfc7640a',
      '10d2c2a5fc',
      '559594ba2f',
      'be0b21a62d',
      'deebb3aa9d',
      '9f9d08d658',
      '17f1be877b',
      'f33556a6cb',
      '20cf1a9119',
      '752a9c602c',
      'a4fee07a88',
      'a2e3ff16f3',
      '3495ec0376',
      'b8f840cb04',
      '805eb6a026',
      '958e527076',
      '02f4edf11e',
      '9fe464ec31',
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
