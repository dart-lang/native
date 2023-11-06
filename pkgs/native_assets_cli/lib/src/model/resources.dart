class ResourceIdentifiers {
  final List<Identifier> identifiers;

  ResourceIdentifiers({required this.identifiers});

  factory ResourceIdentifiers.fromFile() =>
      ResourceIdentifiers(identifiers: []);
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
      'Identifier(name: $name, id: $id, uri: $uri, nonConstant: $nonConstant, files: $files)';
}

class ResourceFile {
  final int part;
  final List<ResourceReference> references;

  ResourceFile({required this.part, required this.references});

  Map<String, dynamic> toJson() => {
        'part': part,
        'references': references.map((x) => x.toJson()).toList(),
      };

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
      'ResourceReference(uri: $uri, line: $line, column: $column, arguments: $arguments)';
}
