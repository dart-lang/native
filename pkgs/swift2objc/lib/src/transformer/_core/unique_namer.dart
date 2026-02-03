// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../ast/_core/interfaces/compound_declaration.dart';

class UniqueNamer {
  final Set<String> _usedNames;
  final Map<String, String> operatorNames = {
    '+': 'add',
    '-': 'subtract',
    '*': 'multiply',
    '/': 'divide',
    '%': 'modulo',

    '==': 'equals',
    '!=': 'notEquals',
    '===': 'strictEquals',
    '!==': 'strictNotEquals',

    '<': 'lessThan',
    '<=': 'lessThanOrEquals',
    '>': 'greaterThan',
    '>=': 'greaterThanOrEquals',

    '!': 'not',
    '&&': 'logicalAnd',
    '||': 'logicalOr',

    '&': 'and',
    '|': 'or',
    '^': 'xor',
    '~': 'bitwiseNot',

    '<<': 'shiftLeft',
    '>>': 'shiftRight',

    '=': 'assign',
    '+=': 'addAssign',
    '-=': 'subtractAssign',
    '*=': 'multiplyAssign',
    '/=': 'divideAssign',
    '%=': 'moduloAssign',
    '&=': 'andAssign',
    '|=': 'orAssign',
    '^=': 'xorAssign',
    '<<=': 'shiftLeftAssign',
    '>>=': 'shiftRightAssign',

    '++': 'increment',
    '--': 'decrement',

    '??': 'nilCoalescing',
    '?': 'question',

    '...': 'closedRange',
    '..<': 'halfOpenRange',

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
    final uniqueName = _sanitize(name);

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

    if (operatorNames.containsKey(name)) {
      return operatorNames[name]!;
    }

    return RegExp(r'\W').hasMatch(name) ? 'operator${name.hashCode}' : name;
  }
}
