import '../../_core/interfaces/enum_declaration.dart';
import '../../_core/shared/referred_type.dart';
import '../compounds/protocol_declaration.dart';

class AssociatedValueEnumDeclaration implements EnumDeclaration {
  @override
  String id;

  @override
  String name;

  @override
  covariant List<AssociatedValueEnumCase> cases;

  @override
  List<GenericType> genericParams;

  @override
  List<DeclaredType<ProtocolDeclaration>> conformedProtocols;

  AssociatedValueEnumDeclaration({
    required this.id,
    required this.name,
    required this.cases,
    required this.genericParams,
    required this.conformedProtocols,
  });
}

class AssociatedValueEnumCase implements EnumCase {
  @override
  String id;

  @override
  String name;

  List<AssociatedValueParam> associatedValues;

  AssociatedValueEnumCase({
    required this.id,
    required this.name,
    required this.associatedValues,
  });
}

class AssociatedValueParam {
  String name;
  ReferredType type;

  AssociatedValueParam({
    required this.name,
    required this.type,
  });
}
