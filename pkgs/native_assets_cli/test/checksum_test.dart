// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:native_assets_cli/code_assets_builder.dart';
import 'package:native_assets_cli/data_assets_builder.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  test('checksum', () async {
    // metadata, cc, link vs build, metadata, haslink
    final configs = <String>[];
    final checksums = <String>[];
    for (final os in [OS.linux, OS.macOS]) {
      for (final architecture in [Architecture.arm64, Architecture.x64]) {
        for (final packageName in ['foo', 'bar']) {
          for (final assetType in [CodeAsset.type, DataAsset.type]) {
            for (final dryRun in [true, false]) {
              for (final linking in [true, false]) {
                final builder = BuildConfigBuilder()
                  ..setupHookConfig(
                    packageRoot: Uri.file('foo'),
                    packageName: packageName,
                    buildAssetTypes: [assetType],
                  )
                  ..setupBuildConfig(
                    dryRun: dryRun,
                    linkingEnabled: linking,
                  )
                  ..setupCodeConfig(
                    targetArchitecture: architecture,
                    targetOS: os,
                    macOSConfig: os == OS.macOS
                        ? MacOSConfig(targetVersion: defaultMacOSVersion)
                        : null,
                    linkModePreference: LinkModePreference.dynamic,
                  );
                configs.add(
                  const JsonEncoder.withIndent(' ').convert(builder.json),
                );
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
      'd666127fab5478b736d505c0cbd2e08e',
      '5d5cf5cf7916bd7adc26f5d5611f23ec',
      '29cb9cf638acac26c1e7eb20bf4e359a',
      '2214edee21375319f5612344dfe6acbc',
      '40b61c96feff406659bc35e24875744b',
      'a0492f5322cea695e3bc1522d66a20ce',
      '9f5269a2c0c663023af449e77ac39980',
      'c9add26b586b1fb897f9ff0d2edb235d',
      '95ec14e605b3519f00ea8816b328e0ad',
      'fc5792f6beb3c0e0f7894537a3fa4850',
      'bbf84c44fb1ce09636a70d3e9a8590be',
      '9c83dfb94b98c6f4ec79cbabc95e6198',
      'af8712f4857423f455d2912c55fe6766',
      '99d1eba44f3e914b58768c210d139cc1',
      '12cc255c3fc076d3550ac32b43166631',
      '2188cca31e8306cbacb9c3d799b5513c',
      '65ad5d4fb66745aad4e5a2969a1e45b1',
      '29da0a967b9cfd5e4d21d61c97d2a99e',
      'efef4a8ab871ed05a9358a2e4d6d4e03',
      '672a07ce5b6f82204ba92b45c287781c',
      '4bcdd217687c15fb108dc9a9b8f8537c',
      'c0593c4282d42a659d66d8b72e44b2a6',
      'dd428de57da1d45149f4ff8a27fa3ea0',
      'c04f80b8be73bcfe435c586ef8a979bc',
      '1056f2bf80b3c1979952af1e62e34576',
      'b7d943b4bab492e10c582bdd58aced0e',
      'ed56d7afbd306393c3206685e6d1ba81',
      '1463940666f69e3b132f3766570ef83b',
      '5451c1a2a24bc5e1206b245b028e0078',
      '5f2c169a71039d3d6b2ae74e3c2723d7',
      '67759625e5a0908dabcaeeb2b1264f84',
      '921b2b7012548949e9b465addccc2e71',
      'b1bddc0ed6904d52d8455779ea22ca7e',
      'ddc148493501a29584b859bbad703dc8',
      'f61b611c5cdf32c1251547c63773be4b',
      '754258bb3497d76670f306c3bdcfb72e',
      '9d7f0c3ea090c5c9a50bc68970b691de',
      '2fb6a652e863e63b877bcf4d0f9c18ee',
      'e6c27bf9b26cd1b9e093d8df3eb701f1',
      '21b14473b8f4513afc07b10fc49b3a42',
      '755e4a51021d2f06f81800d06005d3e8',
      '18739efa01630bfb69b359f3471813e3',
      '6532e84b2020034445983b4aaca63cf6',
      '400486e5b7fd7bcee2cca005d9e365ef',
      'ca9415247d3caf7469f7ef256dbfec7d',
      '5f7e1b8477f41b8676d076375edc4160',
      '79440103b796d05d7f2e3fe6a7eaaa3c',
      '291e0f37d19c0b59abeeb96577f98295',
      '266de1a05af22f800e9018dcacf5f9d5',
      '899d2db19759e703b5093f4919db72b4',
      'ba8fa2cfec652f80588ce5080cb8e0d7',
      'aa946213d19406fa2db5ba89be7037ba',
      '7e29bcee52269e094cf7645dba7b2257',
      'c423ef2466bd1370d04ef82a7676e82c',
      '7b258ea5c87c103e12968ea979339e13',
      '344189c289fceff30a21681b28be98fb',
      '1bfafa1611cef338271a338500a49d13',
      'e59b31a6d8a958f1b894b6e536043b18',
      '39c6bf2b59d2e335b444638352967969',
      '672fe8c89974fbc794bf992da475b264',
      '0690975592703ed47f236c8815d115f0',
      '51d7e1b0c5b4a855d070f409150d2bcf',
      '3299a12d5041c50fbe81167bf0aca0ff',
      '46007e911efe370c1774c3a1d6c35ddd',
    ];
    printOnFailure('final expectedChecksums = <String>[');
    printOnFailure(checksums.map((e) => "  '$e',").join('\n'));
    printOnFailure('];');
    for (var i = 0; i < checksums.length; ++i) {
      expect(checksums[i], expectedChecksums[i]);
    }
  });
}
