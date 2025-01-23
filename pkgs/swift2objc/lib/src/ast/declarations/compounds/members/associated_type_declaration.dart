
import '../../../_core/interfaces/declaration.dart';
import '../../../_core/shared/referred_type.dart';
import '../../../ast_node.dart';

class AssociatedTypeDeclaration extends AstNode implements Declaration {
  @override
  String id;

  @override
  String name;

  AssociatedTypeDeclaration({
    required this.id,
    required this.name,
  });
}

extension AsAssociatedType<T extends AssociatedTypeDeclaration> on T {
  AssociatedType asType() => AssociatedType(
    id: id, name: name
  );
}