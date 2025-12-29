// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'graph.dart';

final class ValidationError extends Error {
  final String message;

  ValidationError(this.message);

  @override
  String toString() => 'Validation error: $message';
}

final class Validator extends Visitor {
  String _usedNameClusters(Map<String, List<String>> usedNames) {
    final usedNameClusters = StringBuffer();
    for (final MapEntry(key: name, value: identifiers) in usedNames.entries) {
      if (identifiers.length > 1) {
        usedNameClusters.write('\n\n"$name": \n- ');
        usedNameClusters.writeAll(identifiers, '\n- ');
      }
    }
    return usedNameClusters.toString();
  }

  @override
  void visit(Bindings bindings) {
    for (final file in bindings.files) {
      final usedNames = <String, List<String>>{};
      for (final cls in file.classes) {
        if (cls.name == null) {
          throw ValidationError('No name has been provided for $cls.');
        }
        (usedNames[cls.name!] ??= []).add(cls.identifier);
      }
      final usedNameClusters = _usedNameClusters(usedNames);
      final hasValidNaming = usedNameClusters.isEmpty;
      if (!hasValidNaming) {
        throw ValidationError('''
The following members are named the same in file "${file.path}":$usedNameClusters

To fix the problem, choose different names for the classes.
''');
      }
    }
  }

  @override
  void visitClass(Class cls) {
    if (!cls.isNameAllowed(cls.name!)) {
      throw ValidationError(
          'The class "$cls" cannot have the name "${cls.name}".');
    }
    if (cls.isTopLevel && cls.kind != DeclKind.packageKind) {
      // Validate whether this class can be top-level.
      final includedNonStaticProperties = cls.properties
          .where((property) => !property.isExcluded && !property.isStatic);
      final includedNonStaticMethods =
          cls.methods.where((method) => !method.isExcluded && !method.isStatic);
      if (includedNonStaticProperties.isNotEmpty ||
          includedNonStaticMethods.isNotEmpty) {
        final instanceMembers = [
          ...includedNonStaticMethods,
          ...includedNonStaticProperties
        ].map((member) => '- $member').join('\n');
        throw ValidationError('''
Class "$cls" cannot be converted to a top-level container as it has non-excluded
instance members:

$instanceMembers

To fix this problem, either set isTopLevel to false, or exclude all of the
instance members of this class.
''');
      }
    }
    // Validate the namings of included members.
    final usedNames = <String, List<String>>{};
    for (final property in cls.properties) {
      if (property.name == null) {
        throw ValidationError(
            'No name has been provided for property $property of class '
            '${property.enclosingClass}.');
      }
      (usedNames[property.name!] ??= []).add(property.identifier);
    }
    for (final method in cls.methods) {
      if (method.name == null) {
        throw ValidationError(
            'No name has been provided for method $method of class '
            '${method.enclosingClass}.');
      }
      (usedNames[method.name!] ??= []).add(method.identifier);
    }
    final usedNameClusters = _usedNameClusters(usedNames);
    final hasValidNaming = usedNameClusters.isEmpty;
    if (!hasValidNaming) {
      throw ValidationError('''
The following members are named the same in class "$cls":$usedNameClusters

To fix the problem, choose different names for the members.
''');
    }
    super.visitClass(cls);
  }

  @override
  void visitProperty(Property property) {
    if (!property.isNameAllowed(property.name!)) {
      throw ValidationError('''
The property "$property" of class "${property.enclosingClass}" cannot have the
name "${property.name}".
''');
    }
  }

  @override
  void visitMethod(Method method) {
    if (!method.isNameAllowed(method.name!)) {
      throw ValidationError('''
The method "$method" of class "${method.enclosingClass}" cannot have the
name "${method.name}".
''');
    }
    final usedNames = <String>{};
    for (final parameter in method.parameters) {
      if (parameter.name == null) {
        throw ValidationError(
            'No name has been provided for parameter $parameter of method '
            '${parameter.enclosingMethod} of class '
            '${parameter.enclosingMethod.enclosingClass}.');
      }
      if (usedNames.contains(parameter.name)) {
        throw ValidationError('''
The parameter names of method "$method" of class "${method.enclosingClass}"
clash with one another.

To fix the problem, choose different names for the parameters.
''');
      }
    }
    super.visitMethod(method);
  }

  @override
  void visitMethodParameter(MethodParameter methodParameter) {
    if (!methodParameter.isNameAllowed(methodParameter.name!)) {
      final method = methodParameter.enclosingMethod;
      final enclosingClass = method.enclosingClass;
      throw ValidationError('''
The parameter at index $methodParameter of method "$method" of class
"$enclosingClass" cannot have the name "${methodParameter.name}".
''');
    }
  }
}
