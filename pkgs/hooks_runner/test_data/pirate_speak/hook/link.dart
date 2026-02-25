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
    final translationAsset = _findTranslationAsset(input);

    if (translationAsset == null) return;

    // ignore: experimental_member_use
    final recordedUsagesFile = input.recordedUsagesFile;
    if (recordedUsagesFile == null) {
      output.assets.data.add(translationAsset.asDataAsset);
      return;
    }

    final recordings = await _loadRecordings(recordedUsagesFile);
    final usedPhrases = _extractUsedPhrases(recordings);
    final allTranslations = await _loadTranslations(translationAsset);
    final filteredTranslations = _filterTranslations(
      allTranslations,
      usedPhrases,
    );

    await _writeOutputAsset(input, output, filteredTranslations);
  });
}

EncodedAsset? _findTranslationAsset(LinkInput input) => input
    .assets
    .encodedAssets
    .where(
      (a) =>
          a.isDataAsset &&
          a.asDataAsset.id == 'package:pirate_speak/translations',
    )
    .firstOrNull;

Future<Recordings> _loadRecordings(Uri file) async {
  final content = await File.fromUri(file).readAsString();
  return Recordings.fromJson(jsonDecode(content) as Map<String, Object?>);
}

Set<String> _extractUsedPhrases(Recordings recordings) {
  final usages = RecordedUsages.fromJson(recordings.toJson());
  final usedPhrases = <String>{};
  final pirateSpeakDef = Definition(
    'package:pirate_speak/src/definitions.dart',
    [
      Name(
        kind: DefinitionKind.methodKind,
        'pirateSpeak',
        disambiguators: {DefinitionDisambiguator.staticDisambiguator},
      ),
    ],
  );

  for (final call in usages.constArgumentsFor(pirateSpeakDef)) {
    if (call.positional.isNotEmpty) {
      if (call.positional.first case StringConstant(:final value)) {
        usedPhrases.add(value);
      }
    }
  }
  return usedPhrases;
}

Future<Map<String, dynamic>> _loadTranslations(EncodedAsset asset) async {
  final file = asset.asDataAsset.file;
  return jsonDecode(await File.fromUri(file).readAsString())
      as Map<String, dynamic>;
}

Map<String, dynamic> _filterTranslations(
  Map<String, dynamic> allTranslations,
  Set<String> usedPhrases,
) => {
  for (final entry in allTranslations.entries)
    if (usedPhrases.contains(entry.key)) entry.key: entry.value,
};

Future<void> _writeOutputAsset(
  LinkInput input,
  LinkOutputBuilder output,
  Map<String, dynamic> content,
) async {
  final filteredFile = input.outputDirectory.resolve(
    'filtered_translations.json',
  );
  await File.fromUri(filteredFile).writeAsString(jsonEncode(content));

  output.assets.data.add(
    DataAsset(
      package: input.packageName,
      name: 'translations',
      file: filteredFile,
    ),
  );
}
