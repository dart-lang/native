// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

class ResourceIdentifiers {
  final List<Identifier> identifiers;

  ResourceIdentifiers({required this.identifiers});

  factory ResourceIdentifiers.fromFile(String fileContents) =>
      ResourceIdentifiers(
          identifiers: (jsonDecode(fileContents) as List)
              .map((e) => e as Map<String, dynamic>)
              .map(Identifier.fromJson)
              .toList());
}

class Identifier {
  final String name;
  final String id;
  final String uri;
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
        'uri': uri,
        'nonConstant': nonConstant,
        'files': files.map((x) => x.toJson()).toList(),
      };

  @override
  String toString() =>
      '''Identifier(name: $name, id: $id, uri: $uri, nonConstant: $nonConstant, files: $files)''';

  factory Identifier.fromJson(Map<String, dynamic> map) => Identifier(
        name: map['name'] as String,
        id: map['id'] as String,
        uri: map['uri'] as String,
        nonConstant: map['nonConstant'] as bool,
        files: List<ResourceFile>.from((map['files'] as List)
            .map((e) => e as Map<String, dynamic>)
            .map(ResourceFile.fromJson)),
      );
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
        references: List<ResourceReference>.from((map['files'] as List)
            .map((e) => e as Map<String, dynamic>)
            .map(ResourceReference.fromJson)),
      );

  @override
  String toString() => 'ResourceFile(part: $part, references: $references)';
}

class ResourceReference {
  final String uri;
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
          'uri': uri,
          'line': line,
          'column': column,
        },
        ...arguments,
      };

  @override
  String toString() =>
      '''ResourceReference(uri: $uri, line: $line, column: $column, arguments: $arguments)''';

  factory ResourceReference.fromJson(Map<String, dynamic> map) =>
      ResourceReference(
        uri: map['uri'] as String,
        line: map['line'] as int,
        column: map['column'] as int,
        arguments:
            Map<String, Object?>.from(map['arguments'] as Map<String, dynamic>),
      );
}
