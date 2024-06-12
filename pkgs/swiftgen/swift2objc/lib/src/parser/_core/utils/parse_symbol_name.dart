import '../type_defs.dart';

parseSymbolName(JsonMap symbolJson) {
  final List subHeadings = symbolJson["names"]["subHeading"];
  return subHeadings.firstWhere(
    (map) => map["kind"] == "identifier",
  )["spelling"];
}
