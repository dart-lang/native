// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:collection/collection.dart';

import 'identifier.dart';

class Annotation {
  final Identifier identifier;
  final Map<String, dynamic> fields;

  Annotation({
    required this.identifier,
    required this.fields,
  });

  factory Annotation.fromJson(
    Map<String, dynamic> json,
    List<Identifier> identifiers,
  ) =>
      Annotation(
        identifier: identifiers[json['id'] as int],
        fields: json['fields'] as Map<String, dynamic>,
      );

  Map<String, dynamic> toJson(List<Identifier> identifiers) => {
        'id': identifiers.indexOf(identifier),
        'fields': fields,
      };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final mapEquals = const DeepCollectionEquality().equals;

    return other is Annotation &&
        other.identifier == identifier &&
        mapEquals(other.fields, fields);
  }

  @override
  int get hashCode => identifier.hashCode ^ fields.hashCode;
}
