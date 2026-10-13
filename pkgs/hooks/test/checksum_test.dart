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
                                targetVersionString: targetVersion.toString(),
                              )
                            : null,
                        iOS: os == OS.iOS
                            ? IOSCodeConfig(
                                targetVersionString: targetVersion.toString(),
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
      '39e2818dd5',
      '1dbe097ce9',
      '74acc29536',
      '2c0d432dde',
      'd9ff7a3aa2',
      '025b84dec0',
      '784e36c5a8',
      'a06d163488',
      'e5e00070ef',
      '838b8de06f',
      '6e8857bcce',
      '9333a9b397',
      '1618bd27ad',
      'a9c3b070f9',
      'd19d903e69',
      '58890ca087',
      'e7d4dec81f',
      'cfd2e3cbb5',
      'edeadb00c1',
      'c31e4bfcd5',
      'ab4f63c8d2',
      '697ae53644',
      '2946dc6264',
      'fb499e4565',
      'b1f5d143fe',
      '6f5a93989a',
      'cff1c76810',
      '1d83ba046d',
      'fa363b536a',
      '75515f1094',
      'c86127d13e',
      '2678388b47',
      '1bead76c0a',
      'cd2195bf06',
      'f2a0bcc2d7',
      '8d3fdda6b2',
      '4519d4b114',
      '6e74b6e3c8',
      '815caabefb',
      '81bac5e642',
      '1a78f75ee1',
      '9d6adcd09c',
      '0a640fa181',
      '0fabef1e4c',
      'a699a64b26',
      '1cf5ac063e',
      '41a0c3e703',
      '5206e18914',
      '4fff5418e8',
      '15a8509a71',
      'f33556a6cb',
      '20cf1a9119',
      '40de8c1cc3',
      '2c31cc7349',
      '3ba5a79299',
      '46427b11dc',
      'd579170897',
      '0e8ffa22c6',
      'e638e5009a',
      '246c2e7e60',
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
