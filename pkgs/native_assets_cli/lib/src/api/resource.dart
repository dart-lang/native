/// Identifies a call site of a static method annotated with the
/// `ResourceIdentifier` annotation. It consists of the [name] of the
/// method, and the [metadata] used in the constructor of the annotation.
///
/// Example:
/// ```dart
/// @ResourceAnnotation('add_func')
/// static external add(int i, int j);
/// ```
/// will result in the `Resource` object:
/// ```dart
/// Resource(name: 'add', metadata: 'add_func')
/// ```
///
/// See also
/// https://pub.dev/documentation/meta/latest/meta/ResourceIdentifier-class.html
/// .
class Resource {
  /// The name of the method which was called.
  final String name;

  /// The metadata used in the annotation constructor on this method.
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
