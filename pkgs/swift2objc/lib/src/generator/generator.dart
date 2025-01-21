import '../ast/_core/interfaces/declaration.dart';
import '../ast/declarations/compounds/class_declaration.dart';
import 'generators/class_generator.dart';

String generate(
  List<Declaration> declarations, {
  String? moduleName,
  String? preamble,
}) =>
    '${[
      preamble,
      '',
      if (moduleName != null) 'import $moduleName',
      'import Foundation\n',
      ...declarations.map((decl) => generateDeclaration(decl).join('\n')),
    ].nonNulls.join('\n')}\n';

List<String> generateDeclaration(Declaration declaration) =>
    switch (declaration) {
      ClassDeclaration() => generateClass(declaration),
      _ => throw UnimplementedError(
          "$declaration generation isn't implemented yet",
        ),
    };
