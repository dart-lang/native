import 'dart:developer';

import '../../ast/declarations/compounds/class_declaration.dart';
import '../_core/utils.dart';

void wireUpRelations(DeclarationsMap declarations, JsonMap symbolgraphJson) {
  final List relations = symbolgraphJson["relationships"];
  for (final relation in relations) {
    if (relation["kind"] != "memberOf") {
      log("Relation of kind ${relation["kind"]} is unimplemented yet");
      continue;
    }

    String methodId = relation["source"];
    String classId = relation["target"];

    final methodDeclaraion = declarations[methodId] as ClassMethodDeclaration;
    final classDeclaraion = declarations[classId] as ClassDeclaration;

    classDeclaraion.methods.add(methodDeclaraion);
  }
}
