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

  @override
  String toString() => '''
- ${isInterface ? 'interface ' : ''}${isAbstract ? 'abstract ' : ''}class $name ${extendedClass.isNotEmpty ? 'extends $extendedClass ' : ''}${implementedInterfaces.isNotEmpty ? 'implements ${implementedInterfaces.join(', ')} ' : ''}
  - Constructors:
${constructors.isEmpty ? '' : constructors.map((c) => '    - $c').join('\n')}
  - Fields:
${fields.isEmpty ? '' : fields.map((f) => '    - $f').join('\n')}
  - Methods:
${methods.isEmpty ? '' : methods.map((m) => '    - $m').join('\n')}
  - Getters:
${getters.isEmpty ? '' : getters.map((g) => '    - $g').join('\n')}
  - Setters:
${setters.isEmpty ? '' : setters.map((s) => '    - $s').join('\n')}
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

  @override
  String toString() => '${isStatic ? 'static ' : ''}$type $name';
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

  @override
  String toString() {
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

  @override
  String toString() {
    final constructorName = name.isNotEmpty ? '$className.$name' : className;
    return '${factoryKeyword ?? ''} $constructorName$parameters';
  }
}

class Getter {
  final String name;
  final String returnType;
  final bool isStatic;

  Getter(this.name, this.returnType, this.isStatic);

  @override
  String toString() {
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

  @override
  String toString() {
    final staticPrefix = isStatic ? 'static ' : '';
    return '$staticPrefix$parameterType set $name($parameter)';
  }
}
