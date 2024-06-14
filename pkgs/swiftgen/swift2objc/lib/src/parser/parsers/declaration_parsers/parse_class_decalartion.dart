import '../../../ast/declarations/compounds/class_declaration.dart';
import '../../_core/utils.dart';

ClassDeclaration parseClassDeclaration(JsonMap classSymbolJson) {
  return ClassDeclaration(
    id: parseSymbolId(classSymbolJson),
    name: parseSymbolName(classSymbolJson),
  );
}
