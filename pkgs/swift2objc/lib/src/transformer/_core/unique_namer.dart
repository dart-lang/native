// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../ast/_core/interfaces/compound_declaration.dart';

class UniqueNamer {
  final Set<String> _usedNames;

  UniqueNamer([Iterable<String> usedNames = const <String>[]]) :
      _usedNames = usedNames.toSet();

  UniqueNamer.inCompound(CompoundDeclaration compoundDeclaration)
      : _usedNames = {
          ...compoundDeclaration.methods.map((method) => method.name),
          ...compoundDeclaration.properties.map((property) => property.name),
        };

  String makeUnique(String name) {
    if (name.isEmpty) {
      name = 'unamed';
    }

    if (!_usedNames.contains(name)) {
      _usedNames.add(name);
      return name;
    }

    var counter = 0;
    var uniqueName = name;

    do {
      counter++;
      uniqueName = '$name$counter';
    } while (_usedNames.contains(uniqueName));

    _usedNames.add(uniqueName);
    return uniqueName;
  }
}
