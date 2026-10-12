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
    for (final (minor, patch, version) in [
      (null, null, '16'),
      (4, null, '16.4'),
      (4, 1, '16.4.1'),
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
                      targetVersion: 16,
                      targetVersionMinor: minor,
                      targetVersionPatch: patch,
                    )
                  : null,
              macOS: os == OS.macOS
                  ? MacOSCodeConfig(
                      targetVersion: 16,
                      targetVersionMinor: minor,
                      targetVersionPatch: patch,
                    )
                  : null,
            ),
          );
        final flag = os == OS.iOS ? '-mios-version-min' : '-mmacos-version-min';
        expect(
          hook.minOSVersion(builder.build().config.code),
          '$flag=$version',
        );
      });
    }
  }
  if (!Platform.isMacOS) return;
  for (final (minor, patch, version) in [
    (null, null, '14.0'),
    (4, null, '14.4'),
    (4, 1, '14.4.1'),
  ]) {
    test('Swift compilation preserves macOS minos $version', () async {
      final input =
          (BuildInputBuilder()
                ..setupShared(
                  packageName: 'test',
                  packageRoot: directory.uri,
                  outputFile: directory.uri.resolve('output.json'),
                  outputDirectoryShared: directory.uri,
                )
                ..addExtension(
                  CodeAssetExtension(
                    targetOS: OS.macOS,
                    targetArchitecture: Architecture.arm64,
                    linkModePreference: LinkModePreference.dynamic,
                    macOS: MacOSCodeConfig(
                      targetVersion: 14,
                      targetVersionMinor: minor,
                      targetVersionPatch: patch,
                    ),
                  ),
                ))
              .build();
      final source = directory.uri.resolve('deployment.swift');
      await File.fromUri(source).writeAsString(
        'public func deploymentVersionTest() -> Int32 { return 0 }',
      );
      final library = directory.uri.resolve('deployment.dylib');
      final builder = await hook.CustomBuilder.create(input, directory.path);
      await builder.buildSwift(
        source,
        'DeploymentVersionTest',
        directory.uri.resolve('deployment.h'),
        library,
      );
      final result = await Process.run('otool', ['-l', library.toFilePath()]);
      expect(result.exitCode, 0, reason: '${result.stderr}');
      expect(
        RegExp(r'\bminos (\S+)').firstMatch(result.stdout as String)?.group(1),
        version,
      );
    });
  }
}
