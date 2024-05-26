// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'declaration.dart';
import 'referred_type.dart';

class CompoundDeclaration extends Declaration {
  List<CompoundPropertyDeclaration> properties;
  List<CompoundMethodDeclaration> methods;
  List<GenericType> genericParams;

  CompoundDeclaration({
    required super.id,
    required super.name,
    required this.properties,
    required this.methods,
    required this.genericParams,
  });
}

class CompoundPropertyDeclaration extends Declaration {
  bool hasSetter;
  ReferredType type;

  CompoundPropertyDeclaration({
    required super.id,
    required super.name,
    required this.type,
    required this.hasSetter,
  });
}

class CompoundMethodDeclaration extends Declaration {
  bool hasObjcAttribute;
  List<CompoundMethodParam> params;
  List<GenericType> genericParams;
  ReferredType returnType;

  CompoundMethodDeclaration({
    required super.id,
    required super.name,
    required this.hasObjcAttribute,
    required this.params,
    required this.genericParams,
    required this.returnType,
  });
}

class CompoundMethodParam {
  String name;
  String? internalName;
  ReferredType type;

  CompoundMethodParam({
    required this.name,
    required this.internalName,
    required this.type,
  });
}
