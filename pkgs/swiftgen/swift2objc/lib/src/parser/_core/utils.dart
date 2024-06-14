import 'dart:convert';
import 'dart:io';

import 'package:swift2objc/src/parser/_core/json.dart';
import 'package:swift2objc/src/parser/_core/parsed_symbolgraph.dart';

import '../../ast/_core/interfaces/declaration.dart';

typedef ParsedSymbolsMap = Map<String, ParsedSymbol>;
typedef ParsedRelationsMap = Map<String, List<ParsedRelation>>;
typedef DeclarationsMap = Map<String, Declaration>;

Json readJsonFile(String jsonFilePath) {
  final jsonStr = File(jsonFilePath).readAsStringSync();
  return Json(jsonDecode(jsonStr));
}

String parseSymbolId(Json symbolJson) {
  return symbolJson["identifier"]["precise"].get();
}

String parseSymbolName(Json symbolJson) {
  return symbolJson["names"]["subHeading"]
      .firstWhereKey("kind", "identifier")["spelling"]
      .get();
}
