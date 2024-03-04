// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:logging/logging.dart';

import '../../native_assets_cli.dart';

abstract class Builder {
  Future<void> run({
    required BuildConfig config,
    required BuildOutput output,
    required Logger? logger,
  });
}

// TODO(dacoharkes): Should we really add this? It seems too specific.
// E.g. what about varying file names, zipped downloads etc. etc. ?
class AssetDownloader implements Builder {
  final Uri Function(OS, Architecture) downloadUri;

  /// Asset identifier.
  ///
  /// If omitted, no asset will be added to the build output.
  final String assetName;

  AssetDownloader({
    required this.downloadUri,
    required this.assetName,
  });

  @override
  Future<void> run({
    required BuildConfig config,
    required BuildOutput output,
    required Logger? logger,
  }) async {
    Uri? targetUri;
    if (!config.dryRun) {
      final downloadUri2 = downloadUri(
        config.targetOS,
        config.targetArchitecture!,
      );
      final fileName =
          downloadUri2.pathSegments.lastWhere((element) => element.isNotEmpty);
      targetUri = config.outputDirectory.resolve(fileName);
      final request = await HttpClient().getUrl(downloadUri2);
      final response = await request.close();
      await response.pipe(File.fromUri(targetUri).openWrite());
    }

    output.addAsset(
      CCodeAsset(
        package: config.packageName,
        name: assetName,
        file: targetUri,
        linkMode: LinkMode.dynamic,
        dynamicLoading: BundledDylib(),
        os: config.targetOS,
        architecture: config.targetArchitecture,
      ),
    );
  }
}
