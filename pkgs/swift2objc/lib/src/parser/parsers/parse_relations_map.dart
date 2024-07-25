// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../_core/json.dart';
import '../_core/parsed_symbolgraph.dart';
import '../_core/utils.dart';

final _supportedRelationKindsMap = {
  for (final relationKind in ParsedRelationKind.values)
    relationKind.name: relationKind
};

ParsedRelationsMap parseRelationsMap(Json symbolgraphJson) {
  final ParsedRelationsMap relationsMap;

  relationsMap = {};

  for (final relationJson in symbolgraphJson['relationships']) {
    final relationKindString = relationJson['kind'].get<String>();
    final relationKind = _supportedRelationKindsMap[relationKindString];

    if (relationKind == null) {
      continue;
    }

    final sourceId = relationJson['source'].get<String>();
    final targetId = relationJson['target'].get<String>();

    final relation = ParsedRelation(
      kind: relationKind,
      sourceId: sourceId,
      targetId: targetId,
      json: relationJson,
    );

    for (var id in [sourceId, targetId]) {
      (relationsMap[id] ??= []).add(relation);
    }
  }

  return relationsMap;
}
