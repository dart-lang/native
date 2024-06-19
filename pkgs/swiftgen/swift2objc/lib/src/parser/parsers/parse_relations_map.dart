// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:swift2objc/src/parser/_core/json.dart';
import 'package:swift2objc/src/parser/_core/parsed_symbolgraph.dart';
import 'package:swift2objc/src/parser/_core/utils.dart';

final _supportedRelationKindsMap = {
  for (final relationKind in ParsedRelationKind.values)
    relationKind.name: relationKind
};

ParsedRelationsMap parseRelationsMap(Json symbolgraphJson) {
  final ParsedRelationsMap relationsMap = {};

  for (final relationJson in symbolgraphJson["relationships"]) {
    final relationKindString = relationJson["kind"].get();
    final relationKind = _supportedRelationKindsMap[relationKindString];

    if (relationKind == null) {
      throw UnimplementedError(
        'Relation of value "$relationKindString" at path ${relationJson["kind"].path} is not implemneted yet',
      );
    }

    final sourceId = relationJson["source"].get();
    final targetId = relationJson["target"].get();

    final relation = ParsedRelation(
      kind: relationKind,
      sourceId: sourceId,
      targetId: targetId,
      json: relationJson,
    );

    [sourceId, targetId].forEach(
      (id) => (relationsMap[id] ??= []).add(relation),
    );
  }

  return relationsMap;
}
