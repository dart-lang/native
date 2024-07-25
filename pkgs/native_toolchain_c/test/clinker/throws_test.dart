// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:test/test.dart';

import '../helpers.dart';

Future<void> main() async {
  test(
    'throws on some platforms',
    () async {
      final tempUri = await tempDirForTest();

      final cLinker = CLinker.library(
        name: 'mylibname',
        linkerOptions: LinkerOptions.manual(),
      );
      await expectLater(
        () => cLinker.run(
          config: LinkConfig.build(
              outputDirectory: tempUri,
              packageName: 'testpackage',
              packageRoot: tempUri,
              targetArchitecture: Architecture.x64,
              targetOS: OS.linux,
              buildMode: BuildMode.debug,
              linkModePreference: LinkModePreference.dynamic,
              assets: []),
          output: LinkOutput(),
          logger: logger,
        ),
        throwsUnsupportedError,
      );
    },
    onPlatform: {
      'linux': const Skip('Is implemented'),
    },
  );
}
