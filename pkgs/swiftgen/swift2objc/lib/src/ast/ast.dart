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
