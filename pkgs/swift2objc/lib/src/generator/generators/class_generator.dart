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

String _generateClassHeader(ClassDeclaration declaration) {
  final header = StringBuffer();

  if (declaration.hasObjCAnnotation) {
    header.write('@objc ');
  }

  header.write('public class ${declaration.name}');

  final superClassAndProtocols = [
    declaration.superClass?.declaration.name,
    ...declaration.conformedProtocols
        .map((protocol) => protocol.declaration.name),
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
  final initializers = [
    declaration.wrapperInitializer,
    ...declaration.initializers,
  ].nonNulls;
  return [for (final init in initializers) ..._generateInitializer(init)];
}

List<String> _generateInitializer(InitializerDeclaration initializer) {
  final header = StringBuffer();

  if (initializer.hasObjCAnnotation) {
    header.write('@objc ');
  }

  if (initializer.isOverriding) {
    header.write('override ');
  }

  header.write('init');

  if (initializer.isFailable) {
    header.write('?');
  }

  header.write('(${generateParameters(initializer.params)})');

  if (initializer.throws) {
    header.write(' throws');
  }

  return [
    '$header {',
    ...initializer.statements.indent(),
    '}\n',
  ];
}

List<String> _generateClassMethods(ClassDeclaration declaration) =>
    [for (final method in declaration.methods) ..._generateClassMethod(method)];

List<String> _generateClassMethod(MethodDeclaration method) {
  final header = StringBuffer();

  if (method.hasObjCAnnotation) {
    header.write('@objc ');
  }

  if (method.isStatic) {
    header.write('static ');
  }

  if (method.isOverriding) {
    header.write('override ');
  }

  header.write(
    'public func ${method.name}(${generateParameters(method.params)})',
  );

  if (method.throws) {
    header.write(' throws');
  }

  if (!method.returnType.sameAs(voidType)) {
    header.write(' -> ${method.returnType.swiftType}');
  }

  return [
    '$header {',
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

  header.write('public var ${property.name}: ${property.type.swiftType} {');

  final getterLines = [
    'get {',
    ...(property.getter?.statements.indent() ?? <String>[]),
    '}'
  ];

  final setterLines = [
    'set {',
    ...(property.setter?.statements.indent() ?? <String>[]),
    '}'
  ];

  return [
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
