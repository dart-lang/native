import 'dart:convert';
import 'dart:io';

import 'package:swift2objc/src/parser/_core/json.dart';

import '../../ast/_core/interfaces/declaration.dart';
import 'parsed_symbol.dart';

typedef DeclarationsMap = Map<String, Declaration>;
typedef ParsedSymbolsMap = Map<String, ParsedSymbol>;
typedef JsonMap = Map<String, dynamic>;

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
