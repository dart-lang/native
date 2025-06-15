// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

class Class {
  final String name;
  final bool isAbstract;
  final bool isInterface;
  final String extendedClass;
  final List<String> implementedInterfaces;

  final List<Field> fields;
  final List<Method> methods;
  final List<Constructor> constructors;
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

  @override
  String toString() =>
      '''- ${isInterface ? 'interface ' : ''}${isAbstract ? 'abstract ' : ''}class $name ${extendedClass.isNotEmpty ? 'extends $extendedClass ' : ''}${implementedInterfaces.isNotEmpty ? 'implements ${implementedInterfaces.join(', ')} ' : ''}''';

  void addField(Field field) {
    fields.add(field);
  }
}

class Field {
  final String name;
  final String type;
  final bool isStatic;

  Field(this.name, this.type, {this.isStatic = false});

  @override
  String toString() => '${isStatic ? 'static ' : ''}$type $name';
}

class Method {
  final String name;
  final String returnType;
  final bool isStatic;
  final List<Param> parameters;

  Method(
    this.name,
    this.returnType,
    this.isStatic, {
    this.parameters = const [],
  });
}

class Param {
  final String name;
  final String type;

  Param(this.name, this.type);
}

class Constructor {
  final String name;
  final List<String> parameters;

  Constructor(this.name, {this.parameters = const []});
}

class Getter {
  final String name;
  final String returnType;

  Getter(this.name, this.returnType);
}

class Setter {
  final String name;
  final String parameterType;

  Setter(this.name, this.parameterType);
}
