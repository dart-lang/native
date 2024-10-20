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
    params: parseInitializerParams(initializerSymbolJson, symbolgraph),
    hasObjCAnnotation: parseSymbolHasObjcAnnotation(initializerSymbolJson),
    isOverriding: parseIsOverriding(initializerSymbolJson),
  );
}

List<Parameter> parseInitializerParams(
  Json initializerSymbolJson,
  ParsedSymbolgraph symbolgraph,
) {
  // Initializers don't have `functionSignature` field in symbolgraph like
  // methods do, so we have our only option is to use `declarationFragments`.
  final fragments = initializerSymbolJson['declarationFragments'];

  // `declarationFragments` describes each part of the initializer declaration,
  // things like `init` keyword, brackets, spaces, etc. We only care about the
  // parameter fragments here, and they always appear in this order:
  // [
  //   'externalParam',
  //   ...,
  //   `internalParam`,
  //   ...,
  //   `typeIdentifier`,
  //   ...
  //   'externalParam',
  //   ...,
  //   `internalParam`,
  //   ...,
  //   `typeIdentifier`
  // ]
  // Note: `internalParam` may or may not exist.
  //
  // The following loop attempts to extract parameters from this flat array
  // while making sure the parameter fragments have the expected order.

  String? externalParam;
  String? internalParam;
  String? typeId;

  final parameters = <Parameter>[];

  for (final fragmentJson in fragments) {
    final kind = fragmentJson['kind'].get<String>();
    final invalidOrderException = Exception(
      'Invalid fragments order at ${fragmentJson.path}',
    );

    switch (kind) {
      case 'externalParam':
        if (externalParam != null || internalParam != null || typeId != null) {
          throw invalidOrderException;
        }
        externalParam = fragmentJson['spelling'].get<String>();
        break;
      case 'internalParam':
        if (externalParam == null || internalParam != null || typeId != null) {
          throw invalidOrderException;
        }
        internalParam = fragmentJson['spelling'].get<String>();
        break;
      case 'typeIdentifier':
        if (externalParam == null || typeId != null) {
          throw invalidOrderException;
        }
        typeId = fragmentJson['preciseIdentifier'].get<String>();
    }

    if (externalParam != null && typeId != null) {
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

  // This ensures there's no half-described parameter at the end
  // of `declarationFragments` array.
  if (externalParam != null || internalParam != null || typeId != null) {
    throw Exception(
      'Missing parameter fragments at the end of ${fragments.path}',
    );
  }

  return parameters;
}
