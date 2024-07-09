import 'package:swift2objc/src/ast/declarations/compounds/class_declaration.dart';

class UniqueNamer {
  final Set<String> _usedNames;

  UniqueNamer(Set<String> this._usedNames);

  UniqueNamer.inClass(ClassDeclaration classDeclaration)
      : _usedNames = {
          ...classDeclaration.methods.map((method) => method.name),
          ...classDeclaration.properties.map((property) => property.name),
        };

  String makeUnique(String name) {
    if (name.isEmpty) {
      name = "unamed";
    }

    if (!_usedNames.contains(name)) {
      _usedNames.add(name);
      return name;
    }

    var counter = 0;
    var uniqueName = name;

    do {
      counter++;
      uniqueName = "$name$counter";
    } while (_usedNames.contains(uniqueName));

    _usedNames.add(uniqueName);
    return uniqueName;
  }
}
