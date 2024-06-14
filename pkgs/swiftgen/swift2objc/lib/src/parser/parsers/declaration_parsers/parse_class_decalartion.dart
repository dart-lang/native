import 'package:swift2objc/src/parser/_core/json.dart';

import '../../../ast/declarations/compounds/class_declaration.dart';
import '../../_core/utils.dart';

ClassDeclaration parseClassDeclaration(Json classSymbolJson) {
  return ClassDeclaration(
    id: parseSymbolId(classSymbolJson),
    name: parseSymbolName(classSymbolJson),
  );
}
