// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:collection/collection.dart';

import 'arguments.dart';
import 'field.dart';
import 'location.dart';

sealed class Reference {
  final String? loadingUnit;

  /// Represents the "@" field in the JSON
  final Location location;

  const Reference({this.loadingUnit, required this.location});

  Map<String, dynamic> toJson(List<String> uris) => {
        'loadingUnit': loadingUnit,
        '@': location.toJson(uris: uris),
      };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Reference &&
        other.loadingUnit == loadingUnit &&
        other.location == location;
  }

  @override
  int get hashCode => Object.hash(loadingUnit, location);
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
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!(super == other)) return false;

    return other is CallReference && other.arguments == arguments;
  }

  @override
  int get hashCode => Object.hash(arguments, super.hashCode);
}

final class InstanceReference extends Reference {
  final String className;
  final List<Field> fields;

  InstanceReference({
    super.loadingUnit,
    required super.location,
    required this.fields,
    required this.className,
  });

  factory InstanceReference.fromJson(
      Map<String, dynamic> json, List<String> uris) {
    return InstanceReference(
      className: json['className'] as String,
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
        'className': className,
        ...super.toJson(uris),
      };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!(super == other)) return false;
    final listEquals = const DeepCollectionEquality().equals;

    return other is InstanceReference &&
        other.className == className &&
        listEquals(other.fields, fields);
  }

  @override
  int get hashCode => Object.hash(className, fields, super.hashCode);
}
