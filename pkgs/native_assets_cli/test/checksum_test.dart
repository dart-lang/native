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
    final inputs = <String>[];
    final checksums = <String>[];

    for (final dryRun in [true, false]) {
      for (final linking in [true, false]) {
        for (final assetType in [CodeAsset.type, DataAsset.type]) {
          for (final os in [
            OS.linux,
            if (assetType == CodeAsset.type) OS.macOS,
          ]) {
            for (final architecture in [
              Architecture.arm64,
              if (assetType == CodeAsset.type) Architecture.x64,
            ]) {
              final builder = BuildInputBuilder()
                ..targetConfig.setupBuildConfig(
                  dryRun: dryRun,
                  linkingEnabled: linking,
                );
              builder.targetConfig
                  .setupTargetConfig(buildAssetTypes: [assetType]);
              if (assetType == CodeAsset.type) {
                builder.targetConfig.setupCodeConfig(
                  targetArchitecture: architecture,
                  targetOS: os,
                  macOSConfig: os == OS.macOS
                      ? MacOSConfig(targetVersion: defaultMacOSVersion)
                      : null,
                  linkModePreference: LinkModePreference.dynamic,
                );
              }
              inputs.add(
                const JsonEncoder.withIndent(' ').convert(builder.json),
              );
              checksums.add(builder.computeChecksum());
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
      '079353bf7f09a5a78aad5dfb74d160ce',
      '3f77f197abd56950f6878720f40f1d78',
      '95afb0b082567b75143a5a3fe23ded7f',
      '20a82fc01786d82ec2e70c81e384ca53',
      '9b4a6923ab07618074631e9ee8ea5451',
      '1ba05dccc6b7d760f2c085dfb3b3e9be',
      '86ca6c0d669baa2f0d29b81aa9db65d9',
      'ad261f0ea9c06e69eaf9870161da902f',
      '4973835d48a96917eb2b4fe3266c60f4',
      '1c4bddfe0111033df5fd1903123a759b',
      '07d32fc26a66558589bd2ef3d243a1bf',
      '6237121ffae0bb44b6489913f859e595',
      '5ab1d45dc1b8365df17dc13bfe725e3e',
      'efff82f6321e8f2ad2d83f7b87890d12',
      '9939ebdbc70de2750b26857ccdf7a308',
      '2ac3ed117b93db3686b51c8d3da6947d',
      '47d6a16f82e7dc71156af0578e1cde4c',
      '07eaf868dd64ef1ffd717111d7a73263',
      '5df468122615987a0daa4da40c3f4e07',
      '0e551c890758631dfc1dd549d8278fc8',
    ];
    printOnFailure('final expectedChecksums = <String>[');
    printOnFailure(checksums.map((e) => "  '$e',").join('\n'));
    printOnFailure('];');
    for (var i = 0; i < checksums.length; ++i) {
      expect(checksums[i], expectedChecksums[i]);
    }
  });
}
