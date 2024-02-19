// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:logging/logging.dart';

import '../../native_assets_cli.dart';

abstract class Builder {
  Future<void> run({
    required BuildConfig buildConfig,
    required BuildOutput buildOutput,
    required Logger? logger,
  });
}

// TODO(dacoharkes): Should we really add this? It seems too specific.
// E.g. what about varying file names, zipped downloads etc. etc. ?
class AssetDownloader implements Builder {
  final Uri Function(Target) downloadUri;

  /// Asset identifier.
  ///
  /// If omitted, no asset will be added to the build output.
  final String assetId;

  AssetDownloader({
    required this.downloadUri,
    required this.assetId,
  });

  @override
  Future<void> run({
    required BuildConfig buildConfig,
    required BuildOutput buildOutput,
    required Logger? logger,
  }) async {
    final assetId = this.assetId.startsWith('package:')
        ? this.assetId
        : 'package:${buildConfig.packageName}/${this.assetId}';
    final List<Target> targets;
    if (buildConfig.dryRun) {
      targets = [
        for (final target in Target.values)
          if (target.os == buildConfig.targetOs) target
      ];
    } else {
      targets = [buildConfig.target];
    }
    for (final target in targets) {
      final downloadUri2 = downloadUri(buildConfig.target);
      final fileName =
          downloadUri2.pathSegments.lastWhere((element) => element.isNotEmpty);
      final targetUri = buildConfig.outDir.resolve(fileName);
      if (!buildConfig.dryRun) {
        final request = await HttpClient().getUrl(downloadUri2);
        final response = await request.close();
        await response.pipe(File.fromUri(targetUri).openWrite());
      }
      buildOutput.addAssets([
        CCodeAsset(
          id: assetId,
          file: targetUri,
          linkMode: LinkMode.dynamic,
          path: AssetAbsolutePath(),
          target: target,
        )
      ]);
    }
  }
}
