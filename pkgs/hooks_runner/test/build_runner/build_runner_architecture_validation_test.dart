// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:test/test.dart';

import '../helpers.dart';
import 'helpers.dart';

const Timeout longTimeout = Timeout(Duration(minutes: 5));

void main() {
  test(
    'rejects a real library built for the wrong architecture',
    () async {
      await inTempDir((tempUri) async {
        await copyTestProjects(targetUri: tempUri);
        final packageUri = tempUri.resolve('wrong_architecture_asset/');
        await runPubGet(workingDirectory: packageUri, logger: logger);

        final logMessages = <String>[];
        final result = await build(
          packageUri,
          createCapturingLogger(logMessages, level: .SEVERE),
          dartExecutable,
          buildAssetTypes: [.code],
        );

        expect(result.isFailure, isTrue);
        expect(
          logMessages.join('\n'),
          allOf(
            contains('is built for'),
            contains('but the target architecture is'),
          ),
        );
      });
    },
    timeout: longTimeout,
    // The test project builds a macOS library for a mismatched architecture,
    // which requires a macOS host. Reported as a visible skip elsewhere rather
    // than silently registering no tests.
    skip: Platform.isMacOS
        ? null
        : 'Building a macOS library for the wrong architecture requires a '
              'macOS host.',
  );
}
