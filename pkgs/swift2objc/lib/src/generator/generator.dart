// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../ast/_core/interfaces/declaration.dart';
import '../ast/declarations/compounds/class_declaration.dart';
import 'generators/class_generator.dart';

String generate(
  List<Declaration> declarations, {
  List<String> importedModuleNames = const [],
  String? preamble,
}) => [
  preamble,
  '',
  for (final moduleName in importedModuleNames) 'import $moduleName',
  '',
  ...declarations.map((decl) => generateDeclaration(decl).join('\n')),
  '',
].nonNulls.join('\n');

List<String> generateDeclaration(Declaration declaration) {
  return switch (declaration) {
    ClassDeclaration() => generateClass(declaration),
    _ => throw UnimplementedError(
      "$declaration generation isn't implemented yet",
    ),
  };
}
