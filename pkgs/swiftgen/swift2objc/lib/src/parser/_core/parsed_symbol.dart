import '../../ast/_core/interfaces/declaration.dart';
import 'type_defs.dart';

class ParsedSymbol {
  JsonMap json;
  Declaration? declaration;

  ParsedSymbol({required this.json, this.declaration});
}
