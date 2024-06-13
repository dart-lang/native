import '../type_defs.dart';

String parseSymbolName(JsonMap symbolJson) {
  final List subHeadings = symbolJson["names"]["subHeading"];
  return subHeadings.firstWhere(
    (map) => map["kind"] == "identifier",
  )["spelling"];
}
