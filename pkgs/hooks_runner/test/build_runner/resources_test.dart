// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:data_assets/data_assets.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:record_use/record_use_internal.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import 'helpers.dart';

const Timeout longTimeout = Timeout(Duration(minutes: 5));

void main() async {
  test('simple_link linking', timeout: longTimeout, () async {
    await inTempDir((tempUri) async {
      await copyTestProjects(targetUri: tempUri);
      final packageUri = tempUri.resolve('simple_link/');

      final resourcesUri = tempUri.resolve('treeshaking_info.json');
      final recordings = Recordings(
        metadata: Metadata(version: Version(1, 0, 0), comment: 'Empty'),
        calls: {},
        instances: {},
      );
      await File.fromUri(
        resourcesUri,
      ).writeAsString(jsonEncode(recordings.toJson()));

      // First, run `pub get`, we need pub to resolve our dependencies.
      await runPubGet(workingDirectory: packageUri, logger: logger);

      final buildResult = (await buildDataAssets(
        packageUri,
        linkingEnabled: true,
      )).success;

      Iterable<String> buildFiles() => Directory.fromUri(
        packageUri.resolve('.dart_tool/hooks_runner/'),
      ).listSync(recursive: true).map((file) => file.path);

      expect(buildFiles(), isNot(anyElement(endsWith('recorded_uses.json'))));

      await link(
        packageUri,
        logger,
        dartExecutable,
        buildResult: buildResult,
        resourceIdentifiers: resourcesUri,
        buildAssetTypes: [BuildAssetType.data],
      );
      expect(buildFiles(), anyElement(endsWith('recorded_uses.json')));
    });
  });

  test('record_use_filtering linking', timeout: longTimeout, () async {
    await inTempDir((tempUri) async {
      await copyTestProjects(targetUri: tempUri);
      final packageUri = tempUri.resolve('pirate_adventure/');

      final resourcesUri = tempUri.resolve('treeshaking_info.json');
      await File.fromUri(
        resourcesUri,
      ).writeAsString(jsonEncode(_pirateAdventureRecordings.toJson()));

      // First, run `pub get`, we need pub to resolve our dependencies.
      await runPubGet(workingDirectory: packageUri, logger: logger);

      final buildResult = (await buildDataAssets(
        packageUri,
        linkingEnabled: true,
      )).success;

      final linkResult = (await link(
        packageUri,
        logger,
        dartExecutable,
        buildResult: buildResult,
        resourceIdentifiers: resourcesUri,
        buildAssetTypes: [BuildAssetType.data],
      )).success;

      // Verify outputs
      final pirateSpeakAssets = linkResult.encodedAssets
          .where((a) => a.asDataAsset.package == 'pirate_speak')
          .toList();
      expect(pirateSpeakAssets, hasLength(1));
      final pirateSpeakFile = pirateSpeakAssets.first.asDataAsset.file;
      final pirateSpeakContent = jsonDecode(
        await File.fromUri(pirateSpeakFile).readAsString(),
      );
      expect(
        pirateSpeakContent,
        equals({'Hello': 'Ahoy', 'Money': 'Doubloons'}),
      );

      final pirateTechAssets = linkResult.encodedAssets
          .where((a) => a.asDataAsset.package == 'pirate_technology')
          .toList();
      expect(pirateTechAssets, hasLength(1));
      final pirateTechFile = pirateTechAssets.first.asDataAsset.file;
      final pirateTechContent = jsonDecode(
        await File.fromUri(pirateTechFile).readAsString(),
      );
      expect(
        pirateTechContent,
        equals({
          'Cannon': {'range': 100, 'damage': 50},
        }),
      );
    });
  });
}

/// Expected result of the compiler when running from pirate_adventure
/// bin/pirate_adventure.dart.
final _pirateAdventureRecordings = Recordings(
  metadata: Metadata(version: Version(1, 0, 0), comment: 'Filtering test'),
  calls: {
    const Definition('package:pirate_speak/src/definitions.dart', [
      Name('pirateSpeak'),
    ]): [
      const CallWithArguments(
        loadingUnit: 'root',
        positionalArguments: [StringConstant('Hello')],
        namedArguments: {},
      ),
      const CallWithArguments(
        loadingUnit: 'root',
        positionalArguments: [StringConstant('Money')],
        namedArguments: {},
      ),
    ],
    const Definition('package:pirate_technology/src/definitions.dart', [
      Name('useCannon'),
    ]): [
      const CallWithArguments(
        loadingUnit: 'root',
        positionalArguments: [],
        namedArguments: {},
      ),
    ],
  },
  instances: {},
);
