// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:core';

import 'package:swift2objc/src/ast/_core/interfaces/enum_declaration.dart';
import 'package:swift2objc/src/ast/declarations/compounds/class_declaration.dart';
import 'package:swift2objc/src/ast/declarations/compounds/struct_declaration.dart';
import 'package:swift2objc/src/ast/declarations/globals/globals.dart';

class Ast {
  final List<ClassDeclaration> classes;
  final List<StructDeclaration> structs;
  final List<EnumDeclaration> enums;
  final Globals globals;

  Ast({
    required this.classes,
    required this.structs,
    required this.enums,
    required this.globals,
  });
}
