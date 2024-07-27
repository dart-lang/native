import '../../../ast/_core/interfaces/declaration.dart';
import '../../../ast/_core/shared/referred_type.dart';
import '../../../ast/declarations/compounds/class_declaration.dart';
import '../../_core/json.dart';
import '../../_core/parsed_symbolgraph.dart';
import '../../_core/utils.dart';
import '../parse_declarations.dart';

ClassPropertyDeclaration parsePropertyDeclaration(
  Json propertySymbolJson,
  ParsedSymbolgraph symbolgraph,
) {
  return ClassPropertyDeclaration(
    id: parseSymbolId(propertySymbolJson),
    name: parseSymbolName(propertySymbolJson),
    type: _parsePropertyType(propertySymbolJson, symbolgraph),
    hasObjCAnnotation: symbolHasObjcAnnotation(propertySymbolJson),
    hasSetter: _propertyHasSetter(propertySymbolJson),
  );
}

ReferredType _parsePropertyType(
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
      '''The property at path "${propertySymbolJson.path}" has a return type that does not exist among parsed symbols.''',
    );
  }

  final typeDeclaration = parseDeclaration(
    typeSymbol,
    symbolgraph,
  );

  return typeDeclaration.asDeclaredType;
}

bool _propertyHasSetter(Json propertySymbolJson) {
  final fragmentsJson = propertySymbolJson['declarationFragments'];

  final declarationKeywordJson = fragmentsJson.firstWhere(
    (json) {
      if (json['kind'].get<String>() != 'keyword') return false;

      final keyword = json['spelling'].get<String>();
      if (keyword != 'var' && keyword != 'let') return false;

      return true;
    },
    orElse: () => throw ArgumentError(
      '''Invalid property declaration fragments at path: ${fragmentsJson.path}. Expected to find "var" or "let" as a keyword, found none''',
    ),
  );

  final declarationKeyword = declarationKeywordJson['spelling'].get<String>();

  if (declarationKeyword == 'var') {
    final hasExplicitSetter = fragmentsJson.any(
      (json) => json['spelling'].get<String>() == 'set',
    );

    final hasExplicitGetter = fragmentsJson.any(
      (json) => json['spelling'].get<String>() == 'get',
    );

    if (hasExplicitGetter) {
      if (hasExplicitSetter) {
        return true;
      } else {
        return false;
      }
    }

    return true;
  }

  return false;
}
