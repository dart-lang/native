import 'dart:developer';

import 'package:swift2objc/src/parser/_core/json.dart';

import '../../ast/declarations/compounds/class_declaration.dart';
import '../_core/utils.dart';

void wireUpRelations(DeclarationsMap declarations, Json symbolgraphJson) {
  for (final relation in symbolgraphJson["relationships"]) {
    if (relation["kind"] != "memberOf") {
      log("Relation of kind ${relation["kind"]} is unimplemented yet");
      continue;
    }

    String methodId = relation["source"].get();
    String classId = relation["target"].get();

    final methodDeclaraion = declarations[methodId] as ClassMethodDeclaration;
    final classDeclaraion = declarations[classId] as ClassDeclaration;

    classDeclaraion.methods.add(methodDeclaraion);
  }
}
