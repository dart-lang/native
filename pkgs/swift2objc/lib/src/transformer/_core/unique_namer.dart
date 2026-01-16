// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../ast/_core/interfaces/compound_declaration.dart';

class UniqueNamer {
  final Set<String> _usedNames;
  static const _operatorNames = {
    '+': 'plus',
    '-': 'minus',
    '*': 'multiply',
    '/': 'divide',
    '=': 'equal',
    '>': 'greaterThan',
    '<': 'lessThan',
    '!': 'not',
    '&': 'and',
    '|': 'or',
    '^': 'xor',
    '%': 'modulo',
    '?': 'question',
    '.': 'dot',
  };
  UniqueNamer([Iterable<String> usedNames = const <String>[]])
    : _usedNames = usedNames.toSet();

  UniqueNamer.inCompound(CompoundDeclaration compoundDeclaration)
    : _usedNames = {
        ...compoundDeclaration.methods.map((method) => method.name),
        ...compoundDeclaration.properties.map((property) => property.name),
      };

  String makeUnique(String name) {
    var uniqueName = _sanitize(name);

    if (!_usedNames.contains(uniqueName)) {
      _usedNames.add(uniqueName);
      return uniqueName;
    }

    var counter = 0;
    var candidateName = uniqueName;

    do {
      counter++;
      candidateName = '$uniqueName$counter';
    } while (_usedNames.contains(candidateName));

    _usedNames.add(candidateName);
    return candidateName;
  }

  String _sanitize(String name) {
    if (name.isEmpty) return 'unnamed';

    final buffer = StringBuffer();
    for (var i = 0; i < name.length; i++) {
      final char = name[i];

      if (RegExp(r'[a-zA-Z0-9_]').hasMatch(char)) {
        buffer.write(char);
      } else {
        buffer.write(_operatorNames[char] ?? 'op${char.codeUnitAt(0)}');
      }
    }

    var sanitized = buffer.toString();

    if (RegExp(r'^[0-9]').hasMatch(sanitized)) {
      sanitized = 'n$sanitized';
    }

    return sanitized;
  }
}
