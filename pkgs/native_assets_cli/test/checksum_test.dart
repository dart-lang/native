// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:native_assets_cli/code_assets_builder.dart';
import 'package:native_assets_cli/data_assets_builder.dart';
import 'package:test/test.dart';

void main() {
  test('checksum', () async {
    // metadata, cc, link vs build, metadata, haslink
    final configs = <String>[];
    final checksums = <String>[];
    for (final os in [OS.linux, OS.macOS]) {
      for (final packageName in ['foo', 'bar']) {
        for (final assetType in [CodeAsset.type, DataAsset.type]) {
          for (final dryRun in [true, false]) {
            for (final linking in [true, false]) {
              final builder = BuildConfigBuilder()
                ..setupHookConfig(
                  packageRoot: Uri.file('foo'),
                  packageName: packageName,
                  targetOS: os,
                  buildAssetTypes: [assetType],
                )
                ..setupBuildConfig(dryRun: dryRun, linkingEnabled: linking);
              configs
                  .add(const JsonEncoder.withIndent(' ').convert(builder.json));
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
      '4cfa5fbd14f8d73d04014ee5b453b000',
      '365e989ba01bac43d654981fec67205d',
      '2191c07f18b5ef13999eb6f8356ae02e',
      '257890f33b84d191746a378fb0db4eba',
      'c22d663cde074a6722c2d5253b8e0619',
      'f520e2f4fd0f2fd76da0c6c18db9559b',
      '7cc71dd803c24a424db70444002df999',
      'a5774f32e91551e8dfdcc3f63e45f3ed',
      '0f361f3a5072f66f68eb4d7a7e4b92d6',
      '5cc8e330ea24c647a1dbf2d82497c73c',
      '97b5dbdf7a76cf5839de3bd0cac63b6d',
      'ccc846104ddc0dbd700190638b756435',
      '0fca1f77969d6e24602cf44c28695c2b',
      '683be025644ff73c5eba9d1f99f9808c',
      '7a6982964efcf50507669706e31bdab5',
      'd2b17c98c64e750d8bd2ed5beb907401',
      'de3ac273831822414783f0d72acf9d82',
      '09c17c21bd277ea2709c35205a2fdfa6',
      'f07b3399888444bc2b7fa837c0c1dddb',
      '6e92bc3271d65229793d8bd1ed4e00be',
      'd353ae01cf04e201180edf8c5e4dac37',
      '25044b641a83b33860cf8f79154652bb',
      'afc5e24300cf70245146148111b8a746',
      '8023595c2343952c02e2aa47f6ee809f',
      '226d39440aa5380bbcf71fb9a804a4b0',
      '26cab023910889c0c96cbba2bb04ad97',
      '32bea1c49326ae259fe97a6fc7b1e08d',
      'a0cccc3aa7069efc86a84b0299dba682',
      '28280ef1dfe5e5922eb97577e8a85c40',
      '69595125d5987c952355903deaa87684',
      'b5328455769192919339d0e6158d728d',
      'ed827ce888b9929ba83e04af8d5b7a37',
    ];
    printOnFailure('final expectedChecksums = <String>[');
    printOnFailure(checksums.map((e) => "  '$e',").join('\n'));
    printOnFailure('];');
    for (var i = 0; i < checksums.length; ++i) {
      expect(checksums[i], expectedChecksums[i]);
    }
  });
}
