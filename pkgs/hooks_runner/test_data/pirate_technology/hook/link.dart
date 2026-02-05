// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:data_assets/data_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:record_use/record_use_internal.dart';

void main(List<String> args) async {
  await link(args, (input, output) async {
    final techAsset = _findTechAsset(input);

    if (techAsset == null) {
      throw StateError('Could not find technologies asset.');
    }

    // ignore: experimental_member_use
    final recordedUsagesFile = input.recordedUsagesFile;

    if (recordedUsagesFile == null) {
      output.assets.data.add(techAsset.asDataAsset);
      return;
    }

    final recordings = await _loadRecordings(recordedUsagesFile);
    final usedTechnologies = _extractUsedTechnologies(recordings);
    final allTech = await _loadTechnologies(techAsset);
    final filteredTech = _filterTechnologies(allTech, usedTechnologies);

    await _writeOutputAsset(input, output, filteredTech);
  });
}

EncodedAsset? _findTechAsset(LinkInput input) => input.assets.encodedAssets
    .where(
      (a) =>
          a.isDataAsset &&
          a.asDataAsset.id == 'package:pirate_technology/technologies',
    )
    .firstOrNull;

Future<Recordings> _loadRecordings(Uri file) async {
  final content = await File.fromUri(file).readAsString();
  return Recordings.fromJson(jsonDecode(content) as Map<String, Object?>);
}

Set<String> _extractUsedTechnologies(Recordings recordings) {
  final usedTechnologies = <String>{};
  for (final def in recordings.callsForDefinition.keys) {
    if (def.identifier.importUri ==
        'package:pirate_technology/src/definitions.dart') {
      // Map function name to tech key (simple capitalization)
      // e.g. useCannon -> Cannon
      final name = def.identifier.name;
      if (name.startsWith('use')) {
        usedTechnologies.add(name.substring(3));
      }
    }
  }
  return usedTechnologies;
}

Future<Map<String, dynamic>> _loadTechnologies(EncodedAsset asset) async {
  final file = asset.asDataAsset.file;
  return jsonDecode(await File.fromUri(file).readAsString())
      as Map<String, dynamic>;
}

Map<String, dynamic> _filterTechnologies(
  Map<String, dynamic> allTech,
  Set<String> usedTechnologies,
) => {
  for (final entry in allTech.entries)
    if (usedTechnologies.contains(entry.key)) entry.key: entry.value,
};

Future<void> _writeOutputAsset(
  LinkInput input,
  LinkOutputBuilder output,
  Map<String, dynamic> content,
) async {
  final filteredFile = input.outputDirectory.resolve('filtered_tech.json');
  await File.fromUri(filteredFile).writeAsString(jsonEncode(content));

  output.assets.data.add(
    DataAsset(
      package: input.packageName,
      name: 'technologies',
      file: filteredFile,
    ),
  );
}
