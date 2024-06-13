import '../../ast/_core/interfaces/declaration.dart';
import 'parsed_symbol.dart';

typedef DeclarationsMap = Map<String, Declaration>;
typedef ParsedSymbolsMap = Map<String, ParsedSymbol>;
typedef JsonMap = Map<String, dynamic>;

String parseSymbolId(JsonMap symbolJson) {
  return symbolJson["identifier"]["precise"];
}

String parseSymbolName(JsonMap symbolJson) {
  final List subHeadings = symbolJson["names"]["subHeading"];
  return subHeadings.firstWhere(
    (map) => map["kind"] == "identifier",
  )["spelling"];
}