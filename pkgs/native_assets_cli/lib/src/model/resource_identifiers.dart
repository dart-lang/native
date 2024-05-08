// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';

class ResourceIdentifiers {
  final List<Identifier> identifiers;

  ResourceIdentifiers({required this.identifiers});

  /// Read resources from a resources.json file
  factory ResourceIdentifiers.fromFile(String path) =>
      ResourceIdentifiers.fromFileContents(File(path).readAsStringSync());

  /// Read resources from the contents of a resources.json file
  factory ResourceIdentifiers.fromFileContents(String fileContents) {
    final fileJson = (jsonDecode(fileContents) as Map)['identifiers'] as List;
    return ResourceIdentifiers(
        identifiers: fileJson
            .map((e) => e as Map<String, dynamic>)
            .map(Identifier.fromJson)
            .toList());
  }

  factory ResourceIdentifiers.fromJson(Map<String, dynamic> map) =>
      ResourceIdentifiers(
        identifiers: List<Identifier>.from((map['identifiers'] as List?)
                ?.whereType<Map<String, dynamic>>()
                .map(Identifier.fromJson) ??
            []),
      );

  Map<String, dynamic> toJson() => {
        'identifiers': identifiers.map((x) => x.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other is ResourceIdentifiers &&
        listEquals(other.identifiers, identifiers);
  }

  @override
  int get hashCode => identifiers.hashCode;

  @override
  String toString() => 'ResourceIdentifiers(identifiers: $identifiers)';
}

class Identifier {
  final String name;
  final String id;
  final Uri uri;
  final bool nonConstant;
  final List<ResourceFile> files;

  Identifier({
    required this.name,
    required this.id,
    required this.uri,
    required this.nonConstant,
    required this.files,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'id': id,
        'uri': uri.toFilePath(),
        'nonConstant': nonConstant,
        'files': files.map((x) => x.toJson()).toList(),
      };

  @override
  String toString() =>
      '''Identifier(name: $name, id: $id, uri: $uri, nonConstant: $nonConstant, files: $files)''';

  factory Identifier.fromJson(Map<String, dynamic> map) => Identifier(
        name: map['name'] as String,
        id: map['id'] as String,
        uri: Uri.file(map['uri'] as String),
        nonConstant: map['nonConstant'] as bool,
        files: List<ResourceFile>.from((map['files'] as List)
            .map((e) => e as Map<String, dynamic>)
            .map(ResourceFile.fromJson)),
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other is Identifier &&
        other.name == name &&
        other.id == id &&
        other.uri == uri &&
        other.nonConstant == nonConstant &&
        listEquals(other.files, files);
  }

  @override
  int get hashCode =>
      name.hashCode ^
      id.hashCode ^
      uri.hashCode ^
      nonConstant.hashCode ^
      files.hashCode;
}

class ResourceFile {
  final int part;
  final List<ResourceReference> references;

  ResourceFile({required this.part, required this.references});

  Map<String, dynamic> toJson() => {
        'part': part,
        'references': references.map((x) => x.toJson()).toList(),
      };

  factory ResourceFile.fromJson(Map<String, dynamic> map) => ResourceFile(
        part: map['part'] as int,
        references: List<ResourceReference>.from((map['references'] as List)
            .map((e) => e as Map<String, dynamic>)
            .map(ResourceReference.fromJson)),
      );

  @override
  String toString() => 'ResourceFile(part: $part, references: $references)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other is ResourceFile &&
        other.part == part &&
        listEquals(other.references, references);
  }

  @override
  int get hashCode => 95911 ^ part.hashCode ^ references.hashCode;
}

class ResourceReference {
  final Uri uri;
  final int line;
  final int column;
  final Map<String, Object?> arguments;

  ResourceReference({
    required this.uri,
    required this.line,
    required this.column,
    required this.arguments,
  });

  Map<String, dynamic> toJson() => {
        '@': {
          'uri': uri.toFilePath(),
          'line': line,
          'column': column,
        },
        ...arguments,
      };

  @override
  String toString() =>
      '''ResourceReference(uri: $uri, line: $line, column: $column, arguments: $arguments)''';

  factory ResourceReference.fromJson(Map<String, dynamic> map) {
    final submap = map['@'] as Map<String, dynamic>;
    return ResourceReference(
      uri: Uri.file(submap['uri'] as String),
      line: submap['line'] as int,
      column: submap['column'] as int,
      arguments: Map<String, Object?>.from(map)..remove('@'),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final mapEquals = const DeepCollectionEquality().equals;

    return other is ResourceReference &&
        other.uri == uri &&
        other.line == line &&
        other.column == column &&
        mapEquals(other.arguments, arguments);
  }

  @override
  int get hashCode =>
      uri.hashCode ^ line.hashCode ^ column.hashCode ^ arguments.hashCode;
}
