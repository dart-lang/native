import '../ast/_core/interfaces/declaration.dart';
import '../ast/declarations/compounds/class_declaration.dart';
import 'generators/class_generator.dart';

String generate(List<Declaration> declarations) {
  return [
    'import Foundation',
    ...declarations.map(generateDeclaration),
  ].join('\n\n');
}

String generateDeclaration(Declaration declaration) {
  return switch (declaration) {
    ClassDeclaration() => generateClass(declaration),
    _ => throw UnimplementedError(
        "$declaration generation isn't implemented yet",
      ),
  };
}
