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
      'bd9690f00c931db8c6c30808a8f1cde9',
      '0b8ee01ab5670140b009588e3f083ff4',
      'e694c17d347cdb155a31857f770b5c92',
      'ab4bd1af9b3d1b688903b37c77bd8020',
      '9ce75907a01f3e0580e697619ead5e92',
      'c61b2dca0e198fc2c989541300b81f88',
      'ba62e22d54212a304c317caad42ec845',
      '65da7b33bab3187145d00c9728386346',
      '6fe78cf88ec338f52a11adc70fb5a1dd',
      '38a3455207083f317402e18d743b66d6',
      'ac6ee76ec70e91990e231e6deca22e2c',
      '5852caaef24a1dbd09369d9610efb1f6',
      '933ccde655cd848665a364a73bfc41bf',
      '7b9b1acdfa7b534ac195475d666dcae4',
      '77985d7269baa0ceeea5ce4c8f78132e',
      '007f3c94a5f46e5d2193b4609e933aa8',
      '02e0846c1d8cab3d3f3d153d9eb3abe6',
      'd985d4f76ffabf8cb50799c5c7047907',
      '8287982d50fc9d24a5a8b9caa92f53fa',
      '3e980a7cd3824cb931f0cec4eaaba852',
      'edeadb00c19dd64b77617ae191e4bedd',
      'e2f57dd491415fcb126d0fcf5fbd6ad8',
      'dc000b9f8f74ed89e1920c6f4e73ec71',
      'f8cb300fa892d0a89feecd99767e62c8',
      '8125df1da5b7240f8fffe55703991bda',
      'fab51a95bbdbddb969a205bda986a1c2',
      '3cf31b6b812e40808012798a06415006',
      '318994fa4438ee9a696c2f0d44990fb0',
      'df86f6cd9139ba8cbe886e136a835aa2',
      '9614324bd0b7dcf10d3519ede425e08c',
      '1a88b01b071f4548fb144a1de7af7930',
      '04c76dc39e3d239c98c95f523dcf73d5',
      '90d99a26b43030659c414ccec228e50c',
      '73d045b89a97df12b569b1f4eb3de901',
      '08068f90a5027536da383c8cd69b5413',
      '13048fabeabaa3f594e0f84f74026c55',
      '42df0997fffca20e1ea235cfb8f26b33',
      'a031105b078e5c529cc0f006cb32d082',
      '384a96ffe009db50c6519c0c3fbde186',
      '7146608d686db3ea662e903a1b658d71',
      'ecfc19b70841c37f974892bd9dd5cf6c',
      '81bac5e642e7b84dbd5fb1f71b07962d',
      '0b5834235f76d74e1c0e421f931b56e5',
      'f54129ea72f73738bba7db94f23ebbfd',
      'f751ee056930928dc9ef116eaf764861',
      'f0db90d146cbbc5204da7505b556ae30',
      '06145a287b8f59f8f760dff4a4a82c21',
      '18024b2d4c64ec81dcf26c5a50e1972b',
      '32cc339e14ca1e925457ed62566a2395',
      '311294eb2f68ab507ab6fce91f94eff3',
      'acf7450a5b53664262c780d5b044ecf3',
      'a84c9207e3ab011ce8e63190baca72b2',
      '2554f04bd60ca06a3ca4ca1ddc93c63e',
      'a2f4c2deb7e7ae4fb4b79d6a75688347',
      '78e667bd827f2c786980750d4cbcadb9',
      'b28d2f17304340966622c8cc49d5d2c0',
      'f7e4053963dbe6c4ad71b7da33ada6e1',
      'd8b00533f06e9d2771afc21ab9313ec8',
      'e971ff2017f15f77f6aeaa4723a13ad1',
      'e5f886c5816fa705903d2ff8080d9f86',
      '1398000924687b7bd167d9e4584961a8',
      '79672bd8fc07a6fc328cb3eca8ddc737',
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
