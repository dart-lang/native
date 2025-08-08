import '../ast/_core/interfaces/declaration.dart';
import '../ast/declarations/compounds/class_declaration.dart';
import 'generators/class_generator.dart';

String generate(
  List<Declaration> declarations, {
  List<String> importedModuleNames = const [],
  String? preamble,
}) {
  return '${[
    preamble,
    '',
    for (final moduleName in importedModuleNames) 'import $moduleName',
    '',
    ...declarations.map((decl) => generateDeclaration(decl).join('\n')),
  ].nonNulls.join('\n')}\n';
}

List<String> generateDeclaration(Declaration declaration) {
  return switch (declaration) {
    ClassDeclaration() => generateClass(declaration),
    _ => throw UnimplementedError(
        "$declaration generation isn't implemented yet",
      ),
  };
}
