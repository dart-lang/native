import '../ast/_core/interfaces/declaration.dart';
import '../ast/declarations/compounds/class_declaration.dart';
import '../ast/declarations/compounds/protocol_declaration.dart';
import 'generators/class_generator.dart';
import 'generators/protocol_generator.dart';

String generate(
  List<Declaration> declarations, {
  String? moduleName,
  String? preamble,
}) {
  return '${[
    preamble,
    '',
    if (moduleName != null) 'import $moduleName',
    'import Foundation\n',
    ...declarations.map((decl) => generateDeclaration(decl).join('\n')),
  ].nonNulls.join('\n')}\n';
}

List<String> generateDeclaration(Declaration declaration) {
  return switch (declaration) {
    ClassDeclaration() => generateClass(declaration),
    ProtocolDeclaration() => generateProtocol(declaration),
    _ => throw UnimplementedError(
        "$declaration generation isn't implemented yet",
      ),
  };
}
