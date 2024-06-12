import '../type_defs.dart';

String parseSymbolId(JsonMap symbolJson) {
  return symbolJson["identifier"]["precise"];
}
