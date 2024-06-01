import '../../_core/interfaces/enum_declaration.dart';
import '../../_core/shared/referred_type.dart';
import '../compounds/protocol_declaration.dart';

class NormalEnumDeclaration implements EnumDeclaration {
  @override
  String id;

  @override
  String name;

  @override
  covariant List<NormalEnumCase> cases;

  @override
  List<GenericType> genericParams;

  @override
  List<ProtocolDeclaration> conformedProtocols;

  NormalEnumDeclaration({
    required this.id,
    required this.name,
    required this.cases,
    required this.genericParams,
    required this.conformedProtocols,
  });

}

class NormalEnumCase implements EnumCase {
  @override
  String id;

  @override
  String name;

  NormalEnumCase({
    required this.id,
    required this.name,
  });
}
