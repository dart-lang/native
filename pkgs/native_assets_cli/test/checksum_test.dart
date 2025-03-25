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
          [CodeAsset.type],
          [CodeAsset.type, DataAsset.type],
          [DataAsset.type],
        ]) {
          for (final os in [
            OS.android,
            if (assetTypes.contains(CodeAsset.type)) OS.iOS,
            if (assetTypes.contains(CodeAsset.type)) OS.macOS,
          ]) {
            for (final architecture in [
              Architecture.arm64,
              if (assetTypes.contains(CodeAsset.type)) Architecture.x64,
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
                    builder.config.setupBuild(
                      // no embedders will pass true anymore
                      linkingEnabled: linking,
                    );
                  }
                  builder.config.setupShared(buildAssetTypes: assetTypes);
                  if (assetTypes.contains(CodeAsset.type)) {
                    builder.config.setupCode(
                      targetArchitecture: architecture,
                      targetOS: os,
                      android:
                          os == OS.android
                              ? AndroidCodeConfig(targetNdkApi: targetVersion)
                              : null,
                      macOS:
                          os == OS.macOS
                              ? MacOSCodeConfig(targetVersion: targetVersion)
                              : null,
                      iOS:
                          os == OS.iOS
                              ? IOSCodeConfig(
                                targetVersion: targetVersion,
                                targetSdk: iOSSdk,
                              )
                              : null,
                      linkModePreference: LinkModePreference.dynamic,
                    );
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
      '94c285a130d88664be8f21c1d6ef34cd',
      '57721cad5c11285edb0016515541e2d5',
      'd9b5d713b0b6a18c67d5e490cdbd074f',
      'db5406082ee570220c97eb1f123e718c',
      'b78638ece1b0a543d09318d48aa9a6c8',
      'ca297a62f6b0dfcf2823528ae4dfd08e',
      '264c307b448f3f9304b1ccab6ec60075',
      'b4a04739d33b007f4058492d3df94955',
      'ec48ca9f46c95620b209837d710e46d4',
      'faa7c97c28a4fc4b4856e7a27f34d717',
      'cb775af7eb5733a85226089f6fb5a8c6',
      '6d815c7d59f04707891ede5a23136787',
      '0231d5d5a4def1870ea81b316c0f232b',
      'b87236e226c6338dccff134e9ee971f9',
      '6e7b17bf18d55557e0eed5d2050e4401',
      'e393e7d58700da05843a5cf8db102fde',
      'd3080b3502953a53cb63a5509bba1eee',
      'a27bf133693f18dee751b7f9661725ad',
      '93a1f07ea89f1b9f57a23bb7aed77c7e',
      '6f802ed01d66cb9529540387ec26d4bc',
      'a648f38bcc571d5800d549fa9146c161',
      'e7a0bed5b00346177a24ced2860136bb',
      '14b0fcffdc10411a0119641a04e84f24',
      '3a9112376cfba8ed524306533e0ba64c',
      '87ba90976f0ac1720ac9ae3ab3e04ed6',
      'ebcc2a8b819d79ea3bd9ba8669c49286',
      '1441b71d0db6c1fa226a013605716bcb',
      'e1946bf4587c22123e97ef19d2c63050',
      '83acde5a35b0cde1a861082d1ffd0097',
      'fd6bc0ef963c6d65ef616779f203dc0f',
      '5b5a62e841327b1afdda64dba0f8a3e2',
      'c64865e81ee7e701a2a52ea344998693',
      '050ad3d2db8581feed77c17c22564789',
      '118569cd7c4c12baa4eaea9c70dc2dd3',
      '5e38c88dcdec92bf701d170f10cb0063',
      'dd330565f2ff2a2d7bb2a480cfc25b12',
      '8e36a6f17eb303799056f0aa1737a1fe',
      '40035559d1a93b3ebe7d2986b2c99aea',
      '786716ef01b49293cf3493b22fcb2518',
      '9f8655c03f8f2f0bc27ae6917390f4e1',
      '3139d774dcddfba7705072397a59b9fe',
      '59bc110e371c5e9c8b04f6453d09584d',
      'f3c6c5de6568f639d67e03b07818acc6',
      '59b5e3250d97b1cfe15ad65198882e7c',
      '6bc2d951c8f99290a94b9a865476c512',
      '6aa6ede0d3f0be509a7ee30121403d2c',
      '80b03895e3dd0e4e4697558bf57a354d',
      '03de9929411b19bb1c840c7188e2bddb',
      'c1179c3e37c5936c915747bdaa9bc180',
      '86c530550aea1db7f07501eecd5461ab',
      'a7911874e29e9696bba7dceeaef99a78',
      '9cd55f6b3c45ecb8563c476bc88052a8',
      'b05ed1e42541d90f2ef3b4180921fc67',
      '229db175097f0ea52b6f2a995a526dff',
      'd2a66fc795288cc2e5d68d4ed7286fd0',
      'be81bebbf4c55f9deb56a73d25cc2750',
      'c2be87cc81c5a1276c454d67d00238e0',
      '4ff44ba1c783becaa20f5810fb02f9d1',
      'ed210e050e2907f66a0e420d143be823',
      '3d768c496687797c2f141cbc9af0d641',
      'e9a36b9242d1f5b5eddb7fd084903264',
      '645460d5ebb3374201eba75e5545d0d2',
      'bbdaf85e3a026c0bd87a56e7102a6beb',
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
