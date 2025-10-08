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
      '61ab5ef403',
      'e3a77db8c8',
      'e7a12aac9e',
      'cf1dd12731',
      'ad93ea8c70',
      '38c7c121e0',
      'c08bfcfb82',
      'e1270f247e',
      'e78c9baa33',
      '9ad4121bad',
      'e5e00070ef',
      '838b8de06f',
      '589ee41a4f',
      '4746317758',
      '61773dc007',
      'cbdc799766',
      '81ab30daef',
      'c3b5b08d9d',
      '817d7a4498',
      '43bf049e1e',
      'edeadb00c1',
      'c31e4bfcd5',
      'ab4f63c8d2',
      '2ef2c44c95',
      '553911c581',
      'bab035bb05',
      'c011395901',
      'e9f7fadde6',
      'ebba044d32',
      '0b282c055b',
      '9a8e06eeda',
      '75515f1094',
      'c86127d13e',
      '4667534582',
      'f94ee3512b',
      '799b09a9cb',
      '1c2bddd1f0',
      'af00c3aa52',
      'c1505e20a9',
      '31f2609c73',
      '7cd688235b',
      '81bac5e642',
      '1a78f75ee1',
      '9d6adcd09c',
      '55fc558767',
      '9edb0db4a6',
      'd30575bba4',
      '29d89c1c64',
      'a304174ba2',
      '7e55d4def0',
      '89bed1462b',
      '3d6cb53899',
      'f33556a6cb',
      '20cf1a9119',
      '6b965e4744',
      '64fffab256',
      'b4c4b511d1',
      '20a0433b2e',
      '517b3c6690',
      'ebc520c76a',
      '7769c411f1',
      '1baf5b978e',
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
