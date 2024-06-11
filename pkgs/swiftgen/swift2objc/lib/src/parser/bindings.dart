import '../ast/_core/interfaces/declaration.dart';
import '../ast/declarations/built_in/built_in_declaration.dart';

class Bindings {
  final declarations = <String, Declaration>{
    for (final decl in _builtInDeclarations) decl.id: decl
  };
}

final _builtInDeclarations = [
  BuiltInDeclaration(id: "s:SS", name: "String"),
  BuiltInDeclaration(id: "s:Si", name: "Int"),
  BuiltInDeclaration(id: "s:Sd", name: "Double"),
];
