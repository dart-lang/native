import '../../../ast/declarations/compounds/members/initializer_declaration.dart';
import '../../_core/json.dart';
import '../../_core/parsed_symbolgraph.dart';
import '../../_core/utils.dart';
import 'parse_function_declaration.dart';

InitializerDeclaration parseInitializerDeclaration(
  Json initializerSymbolJson,
  ParsedSymbolgraph symbolgraph,
) {
  final id = parseSymbolId(initializerSymbolJson);

  // Initializers don't have `functionSignature` field in symbolgraph like
  // methods do, so we have our only option is to use `declarationFragments`.
  final declarationFragments = initializerSymbolJson['declarationFragments'];

  // All initializers should start with an `init` keyword.
  if (!matchFragment(declarationFragments[0], 'keyword', 'init')) {
    throw Exception('Invalid initializer at ${declarationFragments.path}: $id');
  }

  final info = parseFunctionInfo(declarationFragments, symbolgraph);
  return InitializerDeclaration(
    id: id,
    params: info.params,
    hasObjCAnnotation: parseSymbolHasObjcAnnotation(initializerSymbolJson),
    isOverriding: parseIsOverriding(initializerSymbolJson),
    isFailable: parseIsFailableInit(id, declarationFragments),
    throws: info.throws,
  );
}

bool parseIsFailableInit(String id, Json declarationFragments) =>
    matchFragment(declarationFragments[1], 'text', '?(');
