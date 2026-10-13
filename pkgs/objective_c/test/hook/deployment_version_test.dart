// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:test/test.dart';

import '../../hook/build.dart' as hook;

void main() {
  late Directory directory;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('objc_version_');
  });
  tearDown(() async => directory.delete(recursive: true));
  for (final os in [OS.iOS, OS.macOS]) {
    for (final (version, target) in [
      (AppleVersion(16), '16'),
      (AppleVersion(16, minor: 4), '16.4'),
      (AppleVersion(16, minor: 4, patch: 1), '16.4.1'),
      (AppleVersion(16, patch: 1), '16.0.1'),
    ]) {
      test('$os hook forwards deployment target $version', () {
        final builder = BuildInputBuilder()
          ..setupShared(
            packageName: 'test',
            packageRoot: directory.uri,
            outputFile: directory.uri.resolve('output.json'),
            outputDirectoryShared: directory.uri,
          )
          ..addExtension(
            CodeAssetExtension(
              targetOS: os,
              targetArchitecture: Architecture.arm64,
              linkModePreference: LinkModePreference.dynamic,
              iOS: os == OS.iOS
                  ? IOSCodeConfig(
                      targetSdk: IOSSdk.iPhoneOS,
                      targetVersion2: version,
                    )
                  : null,
              macOS: os == OS.macOS
                  ? MacOSCodeConfig(targetVersion2: version)
                  : null,
            ),
          );
        final flag = os == OS.iOS ? '-mios-version-min' : '-mmacos-version-min';
        expect(hook.minOSVersion(builder.build().config.code), '$flag=$target');
      });
    }
  }
}
