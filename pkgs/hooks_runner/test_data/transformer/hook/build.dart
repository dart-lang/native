// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:data_assets/data_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:transformer/src/transform.dart';

void main(List<String> arguments) async {
  await build(arguments, (input, output) async {
    final dataDirectory = Directory.fromUri(input.packageRoot.resolve('data/'));
    // If data are added, rerun hook.
    output.addDependency(dataDirectory.uri);

    var transformedFiles = 0;
    var cachedFiles = 0;

    final hashesFile = File.fromUri(
      input.outputDirectoryShared.resolve('hashes.json'),
    );
    final hashes = await hashesFile.exists()
        ? (json.decoder.convert(await hashesFile.readAsString()) as Map)
              .cast<String, String>()
        : <String, String>{};
    final newHashes = <String, String>{};

    await for (final sourceFile in dataDirectory.list()) {
      if (sourceFile is! File) {
        continue;
      }

      final sourceName = sourceFile.uri.pathSegments.lastWhere(
        (e) => e.isNotEmpty,
      );
      final sourceContents = await sourceFile.readAsString();
      final sourceHash = md5.convert(sourceContents.codeUnits).toString();
      newHashes[sourceName] = sourceHash;
      final prevHash = hashes[sourceName];

      final name = sourceName.replaceFirst('data', 'data_transformed');
      final targetFile = File.fromUri(
        input.outputDirectoryShared.resolve(
          sourceName.replaceFirst('data', 'data_transformed'),
        ),
      );

      if (!await targetFile.exists() || sourceHash != prevHash) {
        await transformFile(sourceFile, targetFile);
        transformedFiles++;
      } else {
        cachedFiles++;
      }

      output.assets.data.add(
        DataAsset(package: input.packageName, name: name, file: targetFile.uri),
      );
      output.addDependency(sourceFile.uri);
    }

    await hashesFile.writeAsString(json.encoder.convert(newHashes));

    print('Transformed $transformedFiles files.');
    print('Reused $cachedFiles cached files.');
  });
}
