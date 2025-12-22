// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../config/config.dart';
import '../logging/logging.dart';
import 'graph.dart';

final class DefaultRenamer extends Visitor {
  final Config config;

  DefaultRenamer(this.config);

  final _nodeToUsedNames = <Object, Set<String>>{};
  final _validDartIdentifierCharacters = RegExp(r'[a-zA-Z0-9_$]');

  String _preprocess(String name) {
    // Replaces the `_` prefix with `$_` to prevent hiding public members.
    String makePublic(String name) =>
        name.startsWith('_') ? '\$_${name.substring(1)}' : name;

    // Replaces each dollar sign with two dollar signs in [name].
    // For example `$foo$$bar$` -> `$$foo$$$$bar$$`.
    String doubleDollarSigns(String name) => name.replaceAll(r'$', r'$$');

    // Replaces each disallowed characters with an underscore.
    String removeDisallowedChars(String name) {
      final newName = StringBuffer();
      for (var i = 0; i < name.length; ++i) {
        final char = name[i];
        if (_validDartIdentifierCharacters.hasMatch(char)) {
          newName.write(char);
        } else {
          newName.write('_');
        }
      }
      return newName.toString();
    }

    return makePublic(doubleDollarSigns(removeDisallowedChars(name)));
  }

  final _countRegexp = RegExp(r'^(.*)\$(\d+)?$');

  Set<String> _usedNamesIn(Object node) {
    return _nodeToUsedNames[node] ??= {};
  }

  // FIXME: return string, get a bool function for isNameAllowed.
  void _renameConflict(dynamic renamable, Object parent) {
    final usedNames = _usedNamesIn(parent);
    // ignore: avoid_dynamic_calls - Using dynamic as `_Renamable` is private.
    var name = renamable.name as String;
    // ignore: avoid_dynamic_calls
    if (!(renamable.isNameAllowed(name) as bool)) {
      // Try appending a dollar sign if the name is a Dart keyword or a
      // disallowed identifier.
      name = '$name\$';
    }
    final regexMatch = _countRegexp.firstMatch(name);
    final String namePart;
    int countPart;
    if (regexMatch != null) {
      namePart = regexMatch[1]!;
      countPart = int.parse(regexMatch[2] ?? '0');
    } else {
      namePart = name;
      countPart = 0;
    }
    while (usedNames.contains(name)) {
      countPart += 1;
      name = '$namePart\$$countPart';
    }
    // ignore: avoid_dynamic_calls
    renamable.name = name;
    usedNames.add(name);
  }

  @override
  void visitClass(Class cls) {
    if (cls.stableName case final stableName?) {
      cls.name = stableName;
      log.finest('Used the stable name "$stableName" for class "$cls".');
      _usedNamesIn(cls.enclosingFile).add(cls.name!);
    } else {
      cls.name = _preprocess(cls.originalName);
      if (cls.enclosingClass != null) {
        cls.name = '${cls.enclosingClass!.name}\$${cls.name}';
      }
      _renameConflict(cls, cls.enclosingFile);
    }
    for (final property in cls.properties) {
      if (property.name != null) {
        _usedNamesIn(cls).add(property.name!);
      } else if (property.stableName case final stableName?) {
        property.name = stableName;
        log.finest(
            'Used the stable name "$stableName" for property "$property" of '
            'class "${property.enclosingClass}".');
        _usedNamesIn(cls).add(property.name!);
      }
    }
    for (final method in cls.methods) {
      if (method.name != null) {
        _usedNamesIn(cls).add(method.name!);
      } else if (method.stableName case final stableName?) {
        method.name = stableName;
        log.finest('Used the stable name "$stableName" for method "$method" of '
            'class "${method.enclosingClass}".');
        _usedNamesIn(cls).add(method.name!);
      }
    }
    super.visitClass(cls);
  }

  @override
  void visitProperty(Property property) {
    final parent = property.enclosingClass.isTopLevel
        ? property.enclosingClass.enclosingFile
        : property.enclosingClass;
    if (property.name != null) {
      return;
    }
    property.name = _preprocess(property.originalName);
    _renameConflict(property, parent);
  }

  @override
  void visitMethod(Method method) {
    final parent = method.enclosingClass.isTopLevel
        ? method.enclosingClass.enclosingFile
        : method.enclosingClass;
    if (method.name != null) {
      return super.visitMethod(method);
    }
    method.name = _preprocess(method.originalName);
    _renameConflict(method, parent);
    final b = method.enclosingClass.identifier ==
        'com.github.dart_lang.jnigen.inheritance.DerivedInterface';
    if (b) log.warning('method $method is named ${method.name}');
    super.visitMethod(method);
  }

  @override
  void visitMethodParameter(MethodParameter methodParameter) {
    if (methodParameter.stableName case final stableName?) {
      methodParameter.name = stableName;
      log.finest('Used the stable name "$stableName" for method parameter '
          'at index ${methodParameter.identifier} of method '
          '"${methodParameter.enclosingMethod}" of '
          'class "${methodParameter.enclosingMethod.enclosingClass}"');
      _usedNamesIn(methodParameter.enclosingMethod).add(methodParameter.name!);
    } else {
      methodParameter.name = _preprocess(methodParameter.originalName);
      _renameConflict(methodParameter, methodParameter.enclosingMethod);
    }
  }
}
