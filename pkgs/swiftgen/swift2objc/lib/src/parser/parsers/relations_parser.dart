import '../../ast/declarations/compounds/class_declaration.dart';
import '../_core/type_defs.dart';

class RelationsParser {
  final JsonMap symbolgraphJson;
  final DeclarationsMap declarations;

  RelationsParser(this.symbolgraphJson, this.declarations);

  void wireUp() {
    final List relations = symbolgraphJson["relationships"];
    for (final relation in relations) {
      String methodId = relation["source"];
      String classId = relation["target"];

      final methodDeclaraion = declarations[methodId] as ClassMethodDeclaration;
      final classDeclaraion = declarations[classId] as ClassDeclaration;

      classDeclaraion.methods.add(methodDeclaraion);
    }
  }
}
