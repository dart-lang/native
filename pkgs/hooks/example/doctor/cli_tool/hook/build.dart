// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:cli_tool/src/find_git.dart';
import 'package:data_assets/data_assets.dart';
import 'package:hooks/hooks.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    if (!input.config.buildDataAssets) {
      return;
    }
    final git = await findGit();
    if (git == null) {
      throw BuildError(
        message: 'git not found on PATH. Run doctor for installation details.',
      );
    }

    final result = await Process.run(git.toFilePath(), ['--version']);
    if (result.exitCode != 0) {
      throw BuildError(message: 'Failed to run git --version.');
    }

    final outFile = File.fromUri(
      input.outputDirectory.resolve('git_version.txt'),
    );
    await outFile.writeAsString((result.stdout as String).trim());

    output.assets.data.add(
      DataAsset(
        package: input.packageName,
        name: 'git_version.txt',
        file: outFile.uri,
      ),
    );
  });
}
