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

  String toDartLikeRepresentaion() => '''
${isInterface ? 'interface ' : ''}${isAbstract ? 'abstract ' : ''}class $name ${extendedClass.isNotEmpty ? 'extends $extendedClass ' : ''}${implementedInterfaces.isNotEmpty ? 'implements ${implementedInterfaces.join(', ')} ' : ''}
{
${constructors.map((c) => '${c.toString()};').join('\n')}
${fields.map((f) => '${f.toString()};').join('\n')}
${methods.map((m) => '${m.toString()};').join('\n')}
${getters.map((g) => '${g.toString()};').join('\n')}
${setters.map((s) => '${s.toString()};').join('\n')}
}
''';

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

  String toDartLikeRepresentaion() => '${isStatic ? 'static ' : ''}$type $name';
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

  String toDartLikeRepresentaion() {
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

  String toDartLikeRepresentaion() {
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

  String toDartLikeRepresentaion() {
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

  String toDartLikeRepresentaion() {
    final staticPrefix = isStatic ? 'static ' : '';
    return '$staticPrefix$parameterType set $name($parameter)';
  }
}
