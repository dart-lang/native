import '../../ast/_core/interfaces/declaration.dart';
import 'utils.dart';

class ParsedSymbol {
  JsonMap json;
  Declaration? declaration;

  ParsedSymbol({required this.json, this.declaration});
}
