// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

class Class {
  final String name;
  final bool isAbstract;
  final bool isInterface;
  final String extendedClass;
  final List<String> implementedInterfaces;

  final List<Constructor> constructors;
  final List<Field> fields;
  final List<Method> methods;
  final List<Getter> getters;
  final List<Setter> setters;

  Class(
    this.name,
    this.isAbstract,
    this.isInterface,
    this.extendedClass,
    this.implementedInterfaces,
  ) : constructors = [],
      fields = [],
      methods = [],
      getters = [],
      setters = [];

  String toDartLikeRepresentation() {
    final classDecleration =
        '${isInterface ? 'interface ' : ''}${isAbstract ? 'abstract ' : ''}class $name ${extendedClass.isNotEmpty ? 'extends $extendedClass ' : ''}${implementedInterfaces.isNotEmpty ? 'implements ${implementedInterfaces.join(', ')} ' : ''}';

    final buffer = StringBuffer();

    buffer.writeln('$classDecleration {');
    for (final constructor in constructors) {
      buffer.writeln('  ${constructor.toDartLikeRepresentation()};');
    }
    for (final field in fields) {
      buffer.writeln('  ${field.toDartLikeRepresentation()};');
    }
    for (final method in methods) {
      buffer.writeln('  ${method.toDartLikeRepresentation()};');
    }
    for (final getter in getters) {
      buffer.writeln('  ${getter.toDartLikeRepresentation()};');
    }
    for (final setter in setters) {
      buffer.writeln('  ${setter.toDartLikeRepresentation()};');
    }
    buffer.writeln('}');
    return buffer.toString();
  }

  void addField(Field field) {
    fields.add(field);
  }

  void addMethod(Method method) {
    methods.add(method);
  }

  void addGetter(Getter getter) {
    getters.add(getter);
  }
}

class Field {
  final String name;
  final String type;
  final bool isStatic;

  Field(this.name, this.type, {this.isStatic = false});

  String toDartLikeRepresentation() =>
      '${isStatic ? 'static ' : ''}$type $name';
}

class Method {
  final String name;
  final String returnType;
  final bool isStatic;
  final String parameters;
  final String typeParameters;
  final String operatorKeyword;

  Method(
    this.name,
    this.returnType,
    this.isStatic,
    this.parameters,
    this.typeParameters, {
    this.operatorKeyword = '',
  });

  String toDartLikeRepresentation() {
    final staticPrefix = isStatic ? 'static ' : '';
    final operatorPrefix =
        operatorKeyword.isNotEmpty ? '$operatorKeyword ' : '';

    return '$staticPrefix$returnType $operatorPrefix$name'
        '$typeParameters$parameters';
  }
}

class Constructor {
  final String className;
  final String name;
  final String parameters;
  final String? factoryKeyword;

  Constructor(this.className, this.name, this.parameters, this.factoryKeyword);

  String toDartLikeRepresentation() {
    final constructorName = name.isNotEmpty ? '$className.$name' : className;
    return '${factoryKeyword != null ? '$factoryKeyword ' : ''}'
        '$constructorName$parameters';
  }
}

class Getter {
  final String name;
  final String returnType;
  final bool isStatic;

  Getter(this.name, this.returnType, this.isStatic);

  String toDartLikeRepresentation() {
    final staticPrefix = isStatic ? 'static ' : '';
    return '$staticPrefix$returnType get $name';
  }
}

class Setter {
  final String name;
  final String parameterType;
  final bool isStatic;
  final String parameter;

  Setter(this.name, this.parameterType, this.isStatic, this.parameter);

  String toDartLikeRepresentation() {
    final staticPrefix = isStatic ? 'static ' : '';
    return '$staticPrefix$parameterType set $name($parameter)';
  }
}

class PackageSummary {
  final String packageName;
  final List<LibraryClassSummary> classesSummaries = [];
  final List<String> topLevelFunctions = [];
  final List<String> topLevelVariables = [];

  PackageSummary({required this.packageName});

  String toDartLikeRepresentation() {
    final buffer = StringBuffer();
    if (packageName.isNotEmpty) {
      buffer.writeln('// From: $packageName');
    }
    for (final function in topLevelFunctions) {
      buffer.writeln('$function;');
    }
    for (final variable in topLevelVariables) {
      buffer.writeln('$variable;');
    }
    buffer.writeln();
    for (final classSummary in classesSummaries) {
      buffer.writeln('// From: $packageName');
      buffer.writeln(classSummary.toDartLikeRepresentation());
      buffer.writeln();
    }
    return buffer.toString();
  }
}

class LibraryClassSummary {
  final String classDeclerationDisplay;
  final List<String> methodsDeclerationDisplay;
  final List<String> fieldsDeclerationDisplay;
  final List<String> gettersDeclerationDisplay;
  final List<String> settersDeclerationDisplay;
  final List<String> constructorsDeclerationDisplay;

  LibraryClassSummary({
    required this.classDeclerationDisplay,
    required this.methodsDeclerationDisplay,
    required this.fieldsDeclerationDisplay,
    required this.gettersDeclerationDisplay,
    required this.settersDeclerationDisplay,
    required this.constructorsDeclerationDisplay,
  });

  String toDartLikeRepresentation() {
    final buffer = StringBuffer();
    buffer.writeln('$classDeclerationDisplay {');
    for (final constructor in constructorsDeclerationDisplay) {
      buffer.writeln('  $constructor;');
    }
    for (final field in fieldsDeclerationDisplay) {
      buffer.writeln('  $field;');
    }
    for (final method in methodsDeclerationDisplay) {
      buffer.writeln('  $method;');
    }
    for (final getter in gettersDeclerationDisplay) {
      buffer.writeln('  $getter;');
    }
    for (final setter in settersDeclerationDisplay) {
      buffer.writeln('  $setter;');
    }
    buffer.writeln('}');
    return buffer.toString();
  }
}
