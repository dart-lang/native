class Resource {
  final String name;
  final Object? metadata;

  Resource({required this.name, required this.metadata});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Resource &&
        other.name == name &&
        other.metadata == metadata;
  }

  @override
  int get hashCode => name.hashCode ^ metadata.hashCode;

  @override
  String toString() => 'Resource(name: $name, metadata: $metadata)';
}
