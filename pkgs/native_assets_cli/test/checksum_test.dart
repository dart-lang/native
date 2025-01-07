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
    for (final packageName in ['foo', 'bar']) {
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
                final builder = BuildConfigBuilder()
                  ..setupHookConfig(
                    packageRoot: Uri.file('foo'),
                    packageName: packageName,
                  )
                  ..setupBuildConfig(
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
      '65ad5d4fb66745aad4e5a2969a1e45b1',
      'b1bddc0ed6904d52d8455779ea22ca7e',
      '266de1a05af22f800e9018dcacf5f9d5',
      '09acb9f7772848f34d6feccb61f26903',
      '5d5cf5cf7916bd7adc26f5d5611f23ec',
      '29da0a967b9cfd5e4d21d61c97d2a99e',
      'ddc148493501a29584b859bbad703dc8',
      '899d2db19759e703b5093f4919db72b4',
      '36946a716480beb2e22759b06ecfb1a0',
      '29cb9cf638acac26c1e7eb20bf4e359a',
      'efef4a8ab871ed05a9358a2e4d6d4e03',
      'f61b611c5cdf32c1251547c63773be4b',
      'ba8fa2cfec652f80588ce5080cb8e0d7',
      'd043edb14bd3892d1b0687e076561f26',
      '2214edee21375319f5612344dfe6acbc',
      '672a07ce5b6f82204ba92b45c287781c',
      '754258bb3497d76670f306c3bdcfb72e',
      'aa946213d19406fa2db5ba89be7037ba',
      '5a6c6bbf6da42353e324bff75e8ec57e',
      '95ec14e605b3519f00ea8816b328e0ad',
      '1056f2bf80b3c1979952af1e62e34576',
      '755e4a51021d2f06f81800d06005d3e8',
      '1bfafa1611cef338271a338500a49d13',
      '0f6f75ecfc5292a14d526fd6d6b04e33',
      'fc5792f6beb3c0e0f7894537a3fa4850',
      'b7d943b4bab492e10c582bdd58aced0e',
      '18739efa01630bfb69b359f3471813e3',
      'e59b31a6d8a958f1b894b6e536043b18',
      '0154de8bc993fb40308a091e2b2de7f9',
      'bbf84c44fb1ce09636a70d3e9a8590be',
      'ed56d7afbd306393c3206685e6d1ba81',
      '6532e84b2020034445983b4aaca63cf6',
      '39c6bf2b59d2e335b444638352967969',
      '41645e3c0bb11234e9c005e4b388b80d',
      '9c83dfb94b98c6f4ec79cbabc95e6198',
      '1463940666f69e3b132f3766570ef83b',
      '400486e5b7fd7bcee2cca005d9e365ef',
      '672fe8c89974fbc794bf992da475b264',
      '1d66c4f38cf30a5d96ba196242257dad',
    ];
    printOnFailure('final expectedChecksums = <String>[');
    printOnFailure(checksums.map((e) => "  '$e',").join('\n'));
    printOnFailure('];');
    for (var i = 0; i < checksums.length; ++i) {
      expect(checksums[i], expectedChecksums[i]);
    }
  });
}
