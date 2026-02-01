// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../ast/_core/shared/referred_type.dart';
import '../../ast/declarations/built_in/built_in_declaration.dart';
import '../../ast/declarations/compounds/class_declaration.dart';
import '../../ast/declarations/compounds/members/initializer_declaration.dart';
import '../../ast/declarations/compounds/members/method_declaration.dart';
import '../../ast/declarations/compounds/members/property_declaration.dart';
import '../_core/utils.dart';
import '../generator.dart';

List<String> generateClass(ClassDeclaration declaration) {
  return [
    if (declaration.isStub) ..._generateStubComment(declaration),
    ...generateAvailability(declaration),
    '${_generateClassHeader(declaration)} {',
    ...[
      _generateClassWrappedInstance(declaration),
      ..._generateClassProperties(declaration),
      ..._generateInitializers(declaration),
      ..._generateClassMethods(declaration),
      ..._generateNestedDeclarations(declaration),
    ].nonNulls.indent(),
    '}\n',
  ];
}

List<String> _generateStubComment(ClassDeclaration declaration) {
  final wrappedType = declaration.wrappedInstance!.type.swiftType;
  return [
    '// This wrapper is a stub. To generate the full wrapper, add $wrappedType',
    "// to your config's include function.",
  ];
}

String _generateClassHeader(ClassDeclaration declaration) {
  final header = StringBuffer();

  if (declaration.hasObjCAnnotation) {
    header.write('@objc ');
  }

  header.write('public class ${declaration.name}');

  final superClassAndProtocols = [
    declaration.superClass?.declaration.name,
    ...declaration.conformedProtocols.map(
      (protocol) => protocol.declaration.name,
    ),
  ].nonNulls;

  if (superClassAndProtocols.isNotEmpty) {
    header.write(': ${superClassAndProtocols.join(", ")}');
  }

  return header.toString();
}

String? _generateClassWrappedInstance(ClassDeclaration declaration) {
  final property = declaration.wrappedInstance;

  if (property == null) return null;

  assert(
    property.type is! GenericType,
    "Wrapped instance can't have a generic type",
  );

  return 'var ${property.name}: ${property.type.swiftType}\n';
}

List<String> _generateInitializers(ClassDeclaration declaration) {
  return [
    ..._generateInitializer(declaration.wrapperInitializer, isPublic: false),
    for (final init in declaration.initializers)
      ..._generateInitializer(init, isPublic: true),
  ];
}

List<String> _generateInitializer(
  InitializerDeclaration? initializer, {
  required bool isPublic,
}) {
  if (initializer == null) return [];
  final header = [
    if (initializer.hasObjCAnnotation) '@objc ',
    if (initializer.isOverriding) 'override ',
    if (isPublic) 'public ',
    'init',
    if (initializer.isFailable) '?',
    '(${generateParameters(initializer.params)}) ',
    '${generateAnnotations(initializer)}{',
  ].join('');

  return [
    ...generateAvailability(initializer),
    header,
    ...initializer.statements.indent(),
    '}\n',
  ];
}

List<String> _generateClassMethods(ClassDeclaration declaration) => [
  for (final method in declaration.methods) ..._generateClassMethod(method),
];

List<String> _generateClassMethod(MethodDeclaration method) {
  final header = StringBuffer();

  if (method.hasObjCAnnotation && !method.isOperator) {
    header.write('@objc ');
  }

  if (method.isStatic) {
    header.write('static ');
  }

  if (method.isOverriding) {
    header.write('override ');
  }

  header.write(
    'public func ${method.name}'
    '(${generateParameters(method.params, isOperator: method.isOperator)}) ',
  );

  header.write(generateAnnotations(method));

  if (!method.returnType.sameAs(voidType)) {
    header.write('-> ${method.returnType.swiftType} ');
  }

  return [
    ...generateAvailability(method),
    '$header{',
    ...method.statements.indent(),
    '}\n',
  ];
}

List<String> _generateClassProperties(ClassDeclaration declaration) => [
  for (final property in declaration.properties)
    ..._generateClassProperty(property),
];

List<String> _generateClassProperty(PropertyDeclaration property) {
  final header = StringBuffer();

  if (property.hasObjCAnnotation) {
    header.write('@objc ');
  }

  if (property.isStatic) {
    header.write('static ');
  }
  final prefixes = [if (property.unowned) 'unowned', if (property.weak) 'weak'];

  var prefix = prefixes.isEmpty ? '' : '${prefixes.join(' ')} ';
  var propSwiftType = property.type.swiftType;

  header.write('public ${prefix}var ${property.name}: $propSwiftType {');

  final getterLines = [
    'get ${generateAnnotations(property)}{',
    ...(property.getter?.statements.indent() ?? <String>[]),
    '}',
  ];

  final setterLines = [
    'set {',
    ...(property.setter?.statements.indent() ?? <String>[]),
    '}',
  ];

  return [
    ...generateAvailability(property),
    header.toString(),
    ...getterLines.indent(),
    if (property.hasSetter) ...setterLines.indent(),
    '}\n',
  ];
}

List<String> _generateNestedDeclarations(ClassDeclaration declaration) => [
  for (final nested in declaration.nestedDeclarations)
    ...generateDeclaration(nested),
];
