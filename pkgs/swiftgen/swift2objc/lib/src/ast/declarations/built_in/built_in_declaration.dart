import '../../_core/interfaces/declaration.dart';
import '../../_core/interfaces/type_parameterizable.dart';
import '../../_core/shared/referred_type.dart';

/// Describes a built-in Swift type (e.g Int, String, etc).
class BuiltInDeclaration implements Declaration, TypeParameterizable {
  @override
  final String id;

  @override
  final String name;

  @override
  final List<GenericType> typeParams;

  const BuiltInDeclaration({
    required this.id,
    required this.name,
    this.typeParams = const [],
  });
}
