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
                ..setupBuildInput(
                  dryRun: dryRun,
                  linkingEnabled: linking,
                );
              if (assetType == CodeAsset.type) {
                builder.setupCodeConfig(
                  targetArchitecture: architecture,
                  targetOS: os,
                  macOSConfig: os == OS.macOS
                      ? MacOSConfig(targetVersion: defaultMacOSVersion)
                      : null,
                  linkModePreference: LinkModePreference.dynamic,
                );
              } else if (assetType == DataAsset.type) {
                builder.setupDataConfig();
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
      '925d600dcf296b3090580facc3edf2b7',
      'a35c6ee872e040d4ca593607411d55c7',
      '7ed08edc547bdbe7c23bfeb784a5d90d',
      'c59378da8732d8620ba1cda6a14fa9cf',
      '1613613b3b24c7dac73624418db30f41',
      '9f7fe6e014687f1ce831239367b68904',
      '128835661e973a964f225e7ff5304bd7',
      '3c26493d1d349d36f58742a241d77f46',
      'cb00634068dd970a26a4a47284d21b6d',
      'cb235612943ce5da476fb59b9586d2f9',
      '713c68c5c49c82a9dc6beb9a04a91c66',
      'cd13b83470137df0fb784764b37ab354',
      'db469c8d73e15e3101112c69e480c1ff',
      'b61381f045bacd8dba8c7f194d41bdcd',
      'f50070c54e062007738c89fc7cde22a7',
      '62de27e9d1c6ed6a413f42d111cc8255',
      '58e02cb492c5c5b4ed1a85f6fcfa5819',
      'cc2a451252f53a570c05b392f366c599',
      'f65f000e8501a32c20ec7c0270b0b9ae',
      '4ef9faec8957250d56603a9e13c8fe80',
    ];
    printOnFailure('final expectedChecksums = <String>[');
    printOnFailure(checksums.map((e) => "  '$e',").join('\n'));
    printOnFailure('];');
    for (var i = 0; i < checksums.length; ++i) {
      expect(checksums[i], expectedChecksums[i]);
    }
  });
}
