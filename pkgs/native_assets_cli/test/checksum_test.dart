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
      '94bc85e935634df06e208ac8ab9643d3',
      'ee4cd19fc3ac5d4a85ceaf2e80e44682',
      '661bf4e49dff3c104784a0d75cf45204',
      '0b3529f1337b3759e97733095a868d29',
      '1522580f1e96c5ea5dc68ca7a720adee',
      '5c08a30f498edf9962c8ff20a1ab4fba',
      '69f4f6640eba043f4df2e6f109f07b90',
      '62db9da306210856e44bb7f8a75a15fd',
      '125f6fa99282a3b7e8937030a3aa2c6d',
      '1cf817dd1a1710bfacb82ef71da94e4f',
      '1eccd6e8e62985cb9955db4fd8c22d2f',
      '4becc04d3263f2b362dd76c0e0eb6d7b',
      '74ecd3c74beb88f2f7f02921a8de1143',
      'ad6bf3865f8addf4233e3a83192f5464',
      'edf54995d97ad818449f09d9b2fc86e2',
      '89014c91ebb4075bdea2d52f2d35b4ae',
      'cb59b4041a0a7bbf636ed4e3b30d06be',
      '3dd69a72235c9b45e1f85c143e8f97bc',
      'b08bec82fca775aeec2e4f400b20a4a0',
      '79381e4fd8c1191f2fceb7ad30b3fd64',
      'b8e5434a62d4b0a381363dca1152a0d5',
      'f70e0798fa96df0b6e1d14d69fd0deaa',
      '3d807e9c6306c16f2ee61a32e8081e2f',
      '0646eefc0cfd913506051f0c8a900983',
      'b5adb85aeaf88a23e7bafd29e63c03ac',
      '7b269c3e21fe9e29285daba8c370073f',
      '1a47af48f1e3158000d44ef59ab597da',
      '2665c64ac2a9d919fff7420c0e770db3',
      '27c0acf56ef48f3855fc20ea8810ff8d',
      '2a9a03940008cdd6f9231f1f54dd94bf',
      '86d87e3cb682646e5d1158898ed7913f',
      '6a7b30ccd5a35694c515d22f165be589',
    ];
    printOnFailure('final expectedChecksums = <String>[');
    printOnFailure(checksums.map((e) => "  '$e',").join('\n'));
    printOnFailure('];');
    for (var i = 0; i < checksums.length; ++i) {
      expect(checksums[i], expectedChecksums[i]);
    }
  });
}
