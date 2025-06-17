import '../../../_core/interfaces/declaration.dart';
import '../../../_core/shared/referred_type.dart';
import '../../../ast_node.dart';
import '../protocol_declaration.dart';

class AssociatedTypeDeclaration extends AstNode implements Declaration {
  @override
  String id;

  @override
  String name;

  List<DeclaredType<ProtocolDeclaration>> conformedProtocols;

  AssociatedTypeDeclaration(
      {required this.id, required this.name, required this.conformedProtocols});
}

extension AsAssociatedType<T extends AssociatedTypeDeclaration> on T {
  AssociatedType asType() => AssociatedType(
      id: id, name: name, conformedProtocols: conformedProtocols);
}
