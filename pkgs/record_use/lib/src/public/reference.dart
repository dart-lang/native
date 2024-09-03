// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:equatable/equatable.dart';

import 'arguments.dart';
import 'field.dart';
import 'location.dart';

sealed class Reference extends Equatable {
  final String? loadingUnit;

  /// Represents the "@" field in the JSON
  final Location location;

  const Reference({this.loadingUnit, required this.location});

  Map<String, dynamic> toJson(List<String> uris) => {
        'loadingUnit': loadingUnit,
        '@': location.toJson(uris: uris),
      };

  @override
  List<Object?> get props => [loadingUnit, location];
}

final class CallReference extends Reference {
  final Arguments? arguments;

  const CallReference({
    required this.arguments,
    super.loadingUnit,
    required super.location,
  });

  factory CallReference.fromJson(Map<String, dynamic> json, List<String> uris) {
    return CallReference(
      arguments: json['arguments'] != null
          ? Arguments.fromJson(json['arguments'] as Map<String, dynamic>)
          : null,
      loadingUnit: json['loadingUnit'] as String?,
      location:
          Location.fromJson(json['@'] as Map<String, dynamic>, null, uris),
    );
  }

  @override
  Map<String, dynamic> toJson(List<String> uris) {
    final argumentJson = arguments?.toJson() ?? {};
    return {
      if (argumentJson.isNotEmpty) 'arguments': argumentJson,
      ...super.toJson(uris),
    };
  }

  @override
  List<Object?> get props => super.props..add(arguments);
}

final class InstanceReference extends Reference {
  final List<Field> fields;

  InstanceReference({
    super.loadingUnit,
    required super.location,
    required this.fields,
  });

  factory InstanceReference.fromJson(
      Map<String, dynamic> json, List<String> uris) {
    return InstanceReference(
      loadingUnit: json['loadingUnit'] as String?,
      location:
          Location.fromJson(json['@'] as Map<String, dynamic>, null, uris),
      fields: (json['fields'] as List)
          .map((fieldStr) => Field.fromJson(fieldStr as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson(List<String> uris) => {
        if (fields.isNotEmpty)
          'fields': fields.map((field) => field.toJson()).toList(),
        ...super.toJson(uris),
      };
  @override
  List<Object?> get props => super.props..add(fields);
}
