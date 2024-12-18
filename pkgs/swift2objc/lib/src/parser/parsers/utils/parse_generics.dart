import '../../../ast/_core/interfaces/compound_declaration.dart';
import '../../../ast/_core/interfaces/declaration.dart';
import '../../../ast/_core/shared/referred_type.dart';
import '../../_core/json.dart';
import '../../_core/parsed_symbolgraph.dart';
import '../parse_declarations.dart';


List<GenericType> parseTypeParams(
  Json declarationSymbolJson,
  ParsedSymbolgraph symbolgraph,
) {
  // get type params
  final genericInfo = declarationSymbolJson['swiftGenerics'];

  final parameters = genericInfo['parameters'];

  if (genericInfo.jsonWithKeyExists('constraints')) {
    return parameters.map((e) {
      return parseDeclGenericType(genericInfo, e['name'].get<String>(), 
        symbolgraph, declarationSymbolJson);
    }).toList();
  } else {
    // how to make a good id for generic types
    return parameters
        .map((e) => GenericType(
            id: e['name'].get<String>(), name: e['name'].get<String>()))
        .toList();
  }
}

GenericType parseDeclGenericType(Json genericInfo, String name, 
    ParsedSymbolgraph symbolgraph, 
    Json declSymbolJson, {String? id}) {
  final constraintsDesc = genericInfo['constraints'].where(
      (element) => element['lhs'].get<String>() == name);
  
  return GenericType(
      id: id ?? name,
      name: name,
      constraints: constraintsDesc.map((c) {
        final constraintId = c['rhsPrecise'].get<String>();
  
        final constraintTypeSymbol = symbolgraph.symbols[constraintId];
  
        if (constraintTypeSymbol == null) {
          throw Exception(
            'The type constraint at path "${declSymbolJson.path}"'
            ' has a return type that does not exist among parsed symbols.',
          );
        }
  
        final constraintDeclaration = parseDeclaration(
          constraintTypeSymbol,
          symbolgraph,
        ) as CompoundDeclaration;
  
        return constraintDeclaration.asDeclaredType;
      }).toList());
}
