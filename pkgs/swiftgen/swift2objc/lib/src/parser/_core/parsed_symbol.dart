import 'package:swift2objc/src/parser/_core/json.dart';
import '../../ast/_core/interfaces/declaration.dart';

class ParsedSymbol {
  Json json;
  Declaration? declaration;

  ParsedSymbol({required this.json, this.declaration});
}
