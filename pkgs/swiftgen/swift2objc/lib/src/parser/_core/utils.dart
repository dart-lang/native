import 'dart:convert';
import 'dart:io';

import '../../ast/_core/interfaces/declaration.dart';
import 'parsed_symbol.dart';

typedef DeclarationsMap = Map<String, Declaration>;
typedef ParsedSymbolsMap = Map<String, ParsedSymbol>;
typedef JsonMap = Map<String, dynamic>;

JsonMap readJsonFile(String jsonFilePath) {
  final jsonStr = File(jsonFilePath).readAsStringSync();
  return jsonDecode(jsonStr);
}

String parseSymbolId(JsonMap symbolJson) {
  return symbolJson["identifier"]["precise"];
}

String parseSymbolName(JsonMap symbolJson) {
  final List subHeadings = symbolJson["names"]["subHeading"];
  return subHeadings.firstWhere(
    (map) => map["kind"] == "identifier",
  )["spelling"];
}
