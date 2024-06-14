import 'package:swift2objc/src/ast/_core/interfaces/declaration.dart';
import 'package:swift2objc/src/parser/_core/json.dart';
import 'package:swift2objc/src/parser/_core/utils.dart';

class ParsedSymbolgraph {
  final ParsedSymbolsMap symbols;
  final ParsedRelationsMap relations;

  ParsedSymbolgraph(this.symbols, this.relations);
}

class ParsedSymbol {
  Json json;
  Declaration? declaration;

  ParsedSymbol({required this.json, this.declaration});
}

class ParsedRelation {
  final Json json;
  final ParsedRelationKind kind;
  final String sourceId;
  final String targetId;

  ParsedRelation({
    required this.kind,
    required this.sourceId,
    required this.targetId,
    required this.json,
  });
}

enum ParsedRelationKind {
  memberOf;
}
