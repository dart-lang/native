// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:file/local.dart' show LocalFileSystem;
import 'package:hooks_runner/hooks_runner.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import 'helpers.dart';

const Timeout longTimeout = Timeout(Duration(minutes: 5));

void main() async {
  test('build custom OS and architecture', timeout: longTimeout, () async {
    await inTempDir((tempUri) async {
      await copyTestProjects(targetUri: tempUri);
      final packageUri = tempUri.resolve('custom_os_arch/');

      // First, run `pub get` to resolve our dependencies.
      await runPubGet(workingDirectory: packageUri, logger: logger);

      final packageLayout = await PackageLayout.fromWorkingDirectory(
        const LocalFileSystem(),
        packageUri,
        'custom_os_arch',
        includeDevDependencies: false,
      );

      final buildRunner = NativeAssetsBuildRunner(
        logger: logger,
        dartExecutable: dartExecutable,
        fileSystem: const LocalFileSystem(),
        packageLayout: packageLayout,
      );

      final result = await buildRunner.build(
        extensions: [
          CodeAssetExtension(
            targetOS: CustomOS.ohos,
            targetArchitecture: CustomArchitecture.mips,
            linkModePreference: CustomLinkModePreference.myPreference,
            sanitizer: CustomSanitizer.mySanitizer,
          ),
        ],
        linkingEnabled: false,
      );

      expect(result.isSuccess, isTrue);
      final buildResult = result.success;

      expect(buildResult.encodedAssets.length, 1);
      final codeAsset = buildResult.encodedAssets.first.asCodeAsset;
      expect(codeAsset.id, 'package:custom_os_arch/my_asset');

      expect(codeAsset.linkMode, isA<CustomLinkMode>());
      final customLinkMode = codeAsset.linkMode as CustomLinkMode;
      expect(customLinkMode.type, 'my_custom_link_mode');
      expect(customLinkMode.json['extra_data'], 'some_value');

      final fileContents = await File.fromUri(codeAsset.file!).readAsString();
      expect(
        fileContents,
        'dummy: ohos, mips, my_sanitizer, my_preference',
      );
    });
  });
}

extension CustomOS on OS {
  static final ohos = OS.fromString('ohos');
}

extension CustomArchitecture on Architecture {
  static final mips = Architecture.fromString('mips');
}

extension CustomSanitizer on Sanitizer {
  static final mySanitizer = Sanitizer.fromString('my_sanitizer');
}

extension CustomLinkModePreference on LinkModePreference {
  static final myPreference = LinkModePreference.fromString('my_preference');
}
