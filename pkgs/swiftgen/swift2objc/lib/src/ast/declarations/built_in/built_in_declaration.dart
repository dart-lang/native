import '../../_core/interfaces/declaration.dart';
import '../../_core/interfaces/type_parameterizable.dart';
import '../../_core/shared/referred_type.dart';

/// Describes a built-in Swift type (e.g Int, String, etc).
class BuiltInDeclaration implements Declaration, TypeParameterizable {
  @override
  String id;

  @override
  String name;

  @override
  List<GenericType> typeParams;

  BuiltInDeclaration({
    required this.id,
    required this.name,
    List<GenericType>? typeParams,
  }) : this.typeParams = typeParams ?? [];
}
