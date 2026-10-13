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
                                targetVersion2: AppleVersion(targetVersion),
                              )
                            : null,
                        iOS: os == OS.iOS
                            ? IOSCodeConfig(
                                targetVersion2: AppleVersion(targetVersion),
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
      '0674760df9',
      '4184e7eaa9',
      'd362489caa',
      'a502f593b2',
      '0aa26fe724',
      '0327699f64',
      'c3189bd3b2',
      'd7b451cb34',
      'e5e00070ef',
      '838b8de06f',
      '92b8885c60',
      'ba6aec46ca',
      'b108e64dd4',
      'bf6a4a01bb',
      '67b14eaf3b',
      '84703329eb',
      'aae24f405c',
      'a296c5140e',
      'edeadb00c1',
      'c31e4bfcd5',
      'ab4f63c8d2',
      '683178bcbc',
      'f1114924f8',
      '680bbab250',
      'e56fc40c72',
      '436e47bdce',
      '54ec64b261',
      '4710a15d3a',
      '06f6223675',
      '75515f1094',
      'c86127d13e',
      '40f193b877',
      '20d8a08f5a',
      '49f675dc14',
      'e1e2cb3d61',
      '3d42f69479',
      '19dc3405ca',
      '3c367fcdf7',
      'c4e44b0980',
      '81bac5e642',
      '1a78f75ee1',
      '9d6adcd09c',
      '1e15643ea6',
      'f467c9a8ac',
      'c0cb878d33',
      '50ce08ed08',
      '5127e15489',
      '99460631db',
      '223d142c3a',
      '9e50a1184c',
      'f33556a6cb',
      '20cf1a9119',
      '5fb125a2fd',
      '8f6eaf8bf0',
      '865e7878fe',
      '745948fb48',
      'c3e3dc87bc',
      '9d3d9113fc',
      '650b3c0c53',
      'dd4df04123',
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
