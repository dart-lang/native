import '../../../ast/_core/shared/parameter.dart';
import '../../../ast/declarations/compounds/members/initializer_declaration.dart';
import '../../_core/json.dart';
import '../../_core/parsed_symbolgraph.dart';
import '../../_core/token_list.dart';
import '../../_core/utils.dart';
import '../parse_type.dart';

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

  return InitializerDeclaration(
    id: id,
    params: parseInitializerParams(declarationFragments, symbolgraph),
    hasObjCAnnotation: parseSymbolHasObjcAnnotation(initializerSymbolJson),
    isOverriding: parseIsOverriding(initializerSymbolJson),
    isFailable: parseIsFailableInit(id, declarationFragments),
  );
}

bool parseIsFailableInit(String id, Json declarationFragments) =>
    matchFragment(declarationFragments[1], 'text', '?(');

List<Parameter> parseInitializerParams(
  Json declarationFragments,
  ParsedSymbolgraph symbolgraph,
) {
  // `declarationFragments` describes each part of the initializer declaration,
  // things like `init` keyword, brackets, spaces, etc. We only care about the
  // parameter fragments here, and they always appear in this order:
  // [
  //   ..., '(',
  //   externalParam, ' ', internalParam, ': ', type..., ', '
  //   externalParam, ': ', type..., ', '
  //   externalParam, ' ', internalParam, ': ', type..., ')'
  // ]
  // Note: `internalParam` may or may not exist.
  //
  // The following loop attempts to extract parameters from this flat array
  // while making sure the parameter fragments have the expected order.

  final parameters = <Parameter>[];

  var tokens = TokenList(declarationFragments);
  final openParen = tokens.indexWhere((tok) => matchFragment(tok, 'text', '('));
  if (openParen != -1) {
    tokens = tokens.slice(openParen + 1);
    String? consume(String kind) {
      if (tokens.isEmpty) return null;
      final token = tokens[0];
      tokens = tokens.slice(1);
      return getSpellingForKind(token, kind);
    }

    final malformedInitializerException = Exception(
      'Malformed initializer at ${declarationFragments.path}',
    );
    while (true) {
      final externalParam = consume('externalParam');
      if (externalParam == null) throw malformedInitializerException;

      var sep = consume('text');
      String? internalParam;
      if (sep == ' ') {
        internalParam = consume('internalParam');
        if (internalParam == null) throw malformedInitializerException;
        sep = consume('text');
      }

      if (sep != ': ') throw malformedInitializerException;
      final (type, remainingTokens) = parseType(symbolgraph, tokens);
      tokens = remainingTokens;

      parameters.add(Parameter(
        name: externalParam,
        internalName: internalParam,
        type: type,
      ));

      final end = consume('text');
      if (end == ')') break;
      if (end != ', ') throw malformedInitializerException;
    }
    if (!tokens.isEmpty) throw malformedInitializerException;
  }

  return parameters;
}
