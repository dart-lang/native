import 'dart:convert';
import 'dart:io';

import '../ast/_core/interfaces/declaration.dart';
import '../ast/_core/shared/parameter.dart';
import '../ast/_core/shared/referred_type.dart';
import '../ast/declarations/compounds/class_declaration.dart';
import 'bindings.dart';

typedef JsonMap = Map<String, dynamic>;

class Parser {
  late Bindings _bindings;

  JsonMap _readSymbolgraphJson(String filePath) {
    final jsonStr = File(filePath).readAsStringSync();
    return jsonDecode(jsonStr);
  }

  void _parseSymbols(JsonMap symbolgraph) {
    final List symbols = symbolgraph["symbols"];
    for (final symbol in symbols) {
      final declaration = _parseSymbol(symbol);
      _bindings.declarations[declaration.id] = declaration;
    }
  }

  Declaration _parseSymbol(JsonMap symbol) {
    final String symbolType = symbol["kind"]["identifier"];

    return switch (symbolType) {
      "swift.class" => _parseClassSymbol(symbol),
      "swift.method" => _parseMethodSymbol(symbol),
      _ => throw UnsupportedError(
          "Symbol of type ${symbolType} is not supported",
        ),
    } as Declaration;
  }

  ClassDeclaration _parseClassSymbol(JsonMap classSymbol) {
    return ClassDeclaration(
      id: _parseSymbolId(classSymbol),
      name: _parseSymbolName(classSymbol),
    );
  }

  ClassMethodDeclaration _parseMethodSymbol(JsonMap methodSymbol) {
    return ClassMethodDeclaration(
      id: _parseSymbolId(methodSymbol),
      name: _parseSymbolName(methodSymbol),
      returnType: _parseMehodReturnType(methodSymbol),
      params: _parseMehodParams(methodSymbol),
    );
  }

  ReferredType _parseMehodReturnType(JsonMap methodSymbol) {
    final returnTypeId =
        methodSymbol["functionSignature"]["returns"][0]["preciseIdentifier"];
    final returnTypeDeclaration = _bindings.declarations[returnTypeId];
    if (returnTypeDeclaration == null) {
      return PlaceholderType.instance;
    } else {
      return DeclaredType(id: returnTypeId, declaration: returnTypeDeclaration);
    }
  }

  List<Parameter> _parseMehodParams(JsonMap methodSymbol) {
    final List paramList = methodSymbol["functionSignature"]["parameters"];

    return paramList
        .map(
          (param) => Parameter(
            name: param["name"],
            internalName: param["internalName"],
            type: _parseParamType(param),
          ),
        )
        .toList();
  }

  ReferredType _parseParamType(JsonMap paramSymbol) {
    final List fragments = paramSymbol["declarationFragments"];

    final paramTypeId = fragments.firstWhere(
      (fragment) => fragment["kind"] == "typeIdentifier",
    )["preciseIdentifier"];

    final paramTypeDeclaration = _bindings.declarations[paramTypeId];

    if (paramTypeDeclaration == null) {
      return PlaceholderType.instance;
    } else {
      return DeclaredType(id: paramTypeId, declaration: paramTypeDeclaration);
    }
  }

  String _parseSymbolName(JsonMap symbol) {
    final List subHeadings = symbol["names"]["subHeading"];
    return subHeadings.firstWhere(
      (map) => map["kind"] == "identifier",
    )["spelling"];
  }

  String _parseSymbolId(JsonMap symbol) {
    return symbol["identifier"]["precise"];
  }

  void _parseRelations(JsonMap symbolgraph) {
    final List relations = symbolgraph["relationships"];
    for (final relation in relations) {
      String methodId = relation["source"];
      String classId = relation["target"];

      final methodDeclaraion =
          _bindings.declarations[methodId] as ClassMethodDeclaration;
      final classDeclaraion =
          _bindings.declarations[classId] as ClassDeclaration;

      classDeclaraion.methods.add(methodDeclaraion);
    }
  }

  Bindings parseSymbolgraph(String filePath) {
    _bindings = Bindings();

    final symbolgraph = _readSymbolgraphJson(filePath);

    // Call twice to replace any placeholder types from the first time
    _parseSymbols(symbolgraph);
    _parseSymbols(symbolgraph);

    _parseRelations(symbolgraph);

    return _bindings;
  }
}
