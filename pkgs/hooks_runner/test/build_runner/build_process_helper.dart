// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:code_assets/code_assets.dart';
import 'package:data_assets/data_assets.dart';
import 'package:file/local.dart';
import 'package:hooks_runner/hooks_runner.dart';
import 'package:logging/logging.dart';

import '../helpers.dart';

/// Runs the build process for a test package.
///
/// Extracted into a separate file so that this can be invoked as an independent
/// process to patch environment variables or to test concurrency.
void main(List<String> args) async {
  final packageUri = Uri.directory(args[0]);
  final packageName = packageUri.pathSegments.lastWhere((e) => e.isNotEmpty);
  final target = Target.fromString(args[1]);

  final logger = Logger('')
    ..level = Level.ALL
    ..onRecord.listen((event) => print(event.message));

  final targetOS = target.os;
  final packageLayout = await PackageLayout.fromWorkingDirectory(
    const LocalFileSystem(),
    packageUri,
    packageName,
    includeDevDependencies: false,
  );
  final result =
      await NativeAssetsBuildRunner(
        logger: logger,
        dartExecutable: dartExecutable,
        fileSystem: const LocalFileSystem(),
        packageLayout: packageLayout,
      ).build(
        // Set up the code input, so that the builds for different targets are
        // in different directories.
        extensions: [
          CodeAssetExtension(
            targetArchitecture: target.architecture,
            targetOS: targetOS,
            macOS: targetOS == .macOS
                ? MacOSCodeConfig(targetVersion: defaultMacOSVersion)
                : null,
            android: targetOS == .android
                ? AndroidCodeConfig(targetNdkApi: 30)
                : null,
            linkModePreference: .dynamic,
          ),
          DataAssetsExtension(),
        ],
        linkingEnabled: false,
      );
  if (result.isFailure) {
    throw Error();
  }
  print('done');
}

int defaultMacOSVersion = 13;
