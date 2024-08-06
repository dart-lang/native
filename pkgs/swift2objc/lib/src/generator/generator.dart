import '../ast/_core/interfaces/declaration.dart';
import '../ast/declarations/compounds/class_declaration.dart';
import '../config.dart';
import 'generators/class_generator.dart';

String generate(Config config, List<Declaration> declarations) {
  return '${[
    config.preamble,
    'import Foundation',
    ...declarations.map(generateDeclaration),
  ].nonNulls.join('\n\n')}\n';
}

String generateDeclaration(Declaration declaration) {
  return switch (declaration) {
    ClassDeclaration() => generateClass(declaration),
    _ => throw UnimplementedError(
        "$declaration generation isn't implemented yet",
      ),
  };
}
