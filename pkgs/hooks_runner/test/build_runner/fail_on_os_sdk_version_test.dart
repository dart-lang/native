// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:code_assets/code_assets.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import 'helpers.dart';

const Timeout longTimeout = Timeout(Duration(minutes: 5));

// Simulate needing some version of the API.
const minNdkApiVersionForThisPackage = 28;
const minIosVersionForThisPackage = 16;
const minMacOSVersionForThisPackage = 13;

final List<(OS, List<(int sdkVersion, bool success)>)> osInput = [
  (
    OS.android,
    [
      (minNdkApiVersionForThisPackage, true),
      (minNdkApiVersionForThisPackage - 1, false),
    ],
  ),
  if (OS.current == OS.macOS) ...[
    (
      OS.macOS,
      [
        (minMacOSVersionForThisPackage, true),
        (minMacOSVersionForThisPackage - 1, false),
      ],
    ),
    (
      OS.iOS,
      [
        (minIosVersionForThisPackage, true),
        (minIosVersionForThisPackage - 1, false),
      ],
    ),
  ],
];

final List<(String hook, String testPath)> hooks = [
  ('build', 'fail_on_os_sdk_version/'),
  ('link', 'fail_on_os_sdk_version_link/'),
];

void main() async {
  for (final (targetOS, versions) in osInput) {
    for (final (version, success) in versions) {
      final statusString = success ? 'succeed' : 'fail';
      for (final (hook, packagePath) in hooks) {
        test(
          '$statusString $hook for $targetOS sdk version',
          timeout: longTimeout,
          () async {
            await inTempDir((tempUri) async {
              await copyTestProjects(targetUri: tempUri);
              final packageUri = tempUri.resolve(packagePath);

              await runPubGet(workingDirectory: packageUri, logger: logger);

              {
                final logMessages = <String>[];
                final (buildResult, linkResult) = await buildAndLink(
                  targetOS: targetOS,
                  targetArchitecture: Architecture.arm64,
                  targetIOSSdk: (targetOS == OS.iOS) ? IOSSdk.iPhoneOS : null,
                  targetIOSVersion: (targetOS == OS.iOS) ? version : null,
                  targetMacOSVersion: (targetOS == OS.macOS) ? version : null,
                  targetAndroidNdkApi: (targetOS == OS.android)
                      ? version
                      : null,
                  packageUri,
                  createCapturingLogger(logMessages, level: Level.SEVERE),
                  dartExecutable,
                  buildAssetTypes: [BuildAssetType.code, BuildAssetType.data],
                );
                final fullLog = logMessages.join('\n');
                if (hook == 'build') {
                  expect(buildResult, success ? isNotNull : isNull);
                } else {
                  assert(hook == 'link');
                  expect(buildResult, isNotNull);
                  expect(linkResult, success ? isNotNull : isNull);
                }
                if (!success) {
                  expect(
                    fullLog,
                    contains(
                      'The native assets for this package require at least',
                    ),
                  );
                }
              }
            });
          },
        );
      }
    }
  }
}
