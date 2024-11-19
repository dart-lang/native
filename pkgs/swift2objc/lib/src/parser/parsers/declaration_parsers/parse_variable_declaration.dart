import '../../../ast/_core/interfaces/declaration.dart';
import '../../../ast/_core/shared/referred_type.dart';
import '../../../ast/declarations/compounds/members/property_declaration.dart';
import '../../../ast/declarations/globals/globals.dart';
import '../../_core/json.dart';
import '../../_core/parsed_symbolgraph.dart';
import '../../_core/utils.dart';
import '../parse_declarations.dart';

PropertyDeclaration parsePropertyDeclaration(
  Json propertySymbolJson,
  ParsedSymbolgraph symbolgraph, {
  bool isStatic = false,
}) {
  final isConstant = _parseVariableIsConstant(propertySymbolJson);
  return PropertyDeclaration(
    id: parseSymbolId(propertySymbolJson),
    name: parseSymbolName(propertySymbolJson),
    type: _parseVariableType(propertySymbolJson, symbolgraph),
    hasObjCAnnotation: parseSymbolHasObjcAnnotation(propertySymbolJson),
    isConstant: isConstant,
    hasSetter: isConstant ? false : _parsePropertyHasSetter(propertySymbolJson),
    isStatic: isStatic,
  );
}

GlobalVariableDeclaration parseGlobalVariableDeclaration(
  Json variableSymbolJson,
  ParsedSymbolgraph symbolgraph, {
  bool isStatic = false,
}) {
  return GlobalVariableDeclaration(
    id: parseSymbolId(variableSymbolJson),
    name: parseSymbolName(variableSymbolJson),
    type: _parseVariableType(variableSymbolJson, symbolgraph),
    isConstant: _parseVariableIsConstant(variableSymbolJson),
  );
}

ReferredType _parseVariableType(
  Json propertySymbolJson,
  ParsedSymbolgraph symbolgraph,
) {
  final subHeadings = propertySymbolJson['names']['subHeading'];

  final typeSymbolJson =
      subHeadings.firstJsonWhereKey('kind', 'typeIdentifier');
  final typeSymbolId = typeSymbolJson['preciseIdentifier'].get<String>();
  final typeSymbol = symbolgraph.symbols[typeSymbolId];

  if (typeSymbol == null) {
    throw Exception(
      'The property at path "${propertySymbolJson.path}" has a return type '
      'that does not exist among parsed symbols.',
    );
  }

  final typeDeclaration = parseDeclaration(
    typeSymbol,
    symbolgraph,
  );

  return typeDeclaration.asDeclaredType;
}

bool _parseVariableIsConstant(Json variableSymbolJson) {
  final fragmentsJson = variableSymbolJson['declarationFragments'];

  final declarationKeywordJson = fragmentsJson.firstWhere(
    (json) {
      if (json['kind'].get<String>() != 'keyword') return false;

      final keyword = json['spelling'].get<String>();
      if (keyword != 'var' && keyword != 'let') return false;

      return true;
    },
    orElse: () => throw ArgumentError(
      'Invalid property declaration fragments at path: ${fragmentsJson.path}. '
      'Expected to find "var" or "let" as a keyword, found none',
    ),
  );

  final declarationKeyword = declarationKeywordJson['spelling'].get<String>();

  return declarationKeyword == 'let';
}

bool _parsePropertyHasSetter(Json propertySymbolJson) {
  final fragmentsJson = propertySymbolJson['declarationFragments'];

  final hasExplicitSetter = fragmentsJson.any(
    (json) => json['spelling'].get<String>() == 'set',
  );

  final hasExplicitGetter = fragmentsJson.any(
    (json) => json['spelling'].get<String>() == 'get',
  );

  if (hasExplicitGetter) {
    if (hasExplicitSetter) {
      // has explicit getter and has explicit setter
      return true;
    } else {
      // has explicit getter and no explicit setter
      return false;
    }
  } else {
    if (hasExplicitSetter) {
      // has no explicit getter and but has explicit setter
      throw Exception(
        'Invalid property at ${propertySymbolJson.path}. '
        'Properties can not have a setter without a getter',
      );
    } else {
      // has no explicit getter and no explicit setter
      return true;
    }
  }
}
