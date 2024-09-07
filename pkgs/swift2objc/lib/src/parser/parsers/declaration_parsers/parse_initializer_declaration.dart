import '../../../ast/_core/shared/parameter.dart';
import '../../../ast/declarations/compounds/members/initializer_declaration.dart';
import '../../_core/json.dart';
import '../../_core/parsed_symbolgraph.dart';
import '../../_core/utils.dart';

InitializerDeclaration parseInitializerDeclaration(
  Json initializerSymbolJson,
  ParsedSymbolgraph symbolgraph,
) {
  return InitializerDeclaration(
    id: parseSymbolId(initializerSymbolJson),
    params: _parseInitializerParams(initializerSymbolJson, symbolgraph),
    hasObjCAnnotation: symbolHasObjcAnnotation(initializerSymbolJson),
  );
}

List<Parameter> _parseInitializerParams(
  Json initializerSymbolJson,
  ParsedSymbolgraph symbolgraph,
) {
  final fragments = initializerSymbolJson['declarationFragments'];

  final externalParamKind = 'externalParam';
  final internalParamKind = 'internalParam';
  final typeIdentifierKind = 'typeIdentifier';

  String? externalParam;
  String? internalParam;
  String? typeId;

  final parameters = <Parameter>[];

  for (final fragmentJson in fragments) {
    final kind = fragmentJson['kind'].get<String>();
    final invalidOrderException =
        Exception('Invalid fragments order at ${fragmentJson.path}');
    if (kind == externalParamKind) {
      if (externalParam != null) throw invalidOrderException;
      externalParam = fragmentJson['spelling'].get<String>();
      continue;
    }

    if (kind == internalParamKind) {
      if (internalParam != null) throw invalidOrderException;
      internalParam = fragmentJson['spelling'].get<String>();
      continue;
    }

    if (kind == typeIdentifierKind) {
      if (typeId != null) throw invalidOrderException;
      typeId = fragmentJson['preciseIdentifier'].get<String>();

      if (externalParam == null) throw invalidOrderException;

      parameters.add(Parameter(
        name: externalParam,
        internalName: internalParam,
        type: parseTypeFromId(typeId, symbolgraph),
      ));

      internalParam = null;
      externalParam = null;
      typeId = null;
    }
  }

  return parameters;
}
