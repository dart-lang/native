// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_assets_cli/data_assets.dart';
import 'package:transformer/src/transform.dart';

void main(List<String> arguments) async {
  await build(arguments, (config, output) async {
    final dataDirectory =
        Directory.fromUri(config.packageRoot.resolve('data/'));
    // If data are added, rerun hook.
    output.addDependency(dataDirectory.uri);

    var transformedFiles = 0;
    var cachedFiles = 0;

    await for (final sourceFile in dataDirectory.list()) {
      if (sourceFile is! File) {
        continue;
      }

      final sourceName =
          sourceFile.uri.pathSegments.lastWhere((e) => e.isNotEmpty);
      final name = sourceName.replaceFirst('data', 'data_transformed');
      final targetFile = File.fromUri(config.outputDirectoryShared
          .resolve(sourceName.replaceFirst('data', 'data_transformed')));

      // ignore: deprecated_member_use
      if (!config.dryRun) {
        // TODO(dacoharkes): Timestamps are not enough for correct caching.
        if (!await targetFile.exists() ||
            !(await sourceFile.lastModified())
                .isBefore(await targetFile.lastModified())) {
          await transformFile(sourceFile, targetFile);
          transformedFiles++;
        } else {
          cachedFiles++;
        }
      }

      output.dataAssets.add(
        DataAsset(
          package: config.packageName,
          name: name,
          file: targetFile.uri,
        ),
      );
      output.addDependency(
        sourceFile.uri,
      );
    }

    // ignore: deprecated_member_use
    if (!config.dryRun) {
      print('Transformed $transformedFiles files.');
      print('Reused $cachedFiles cached files.');
    }
  });
}
