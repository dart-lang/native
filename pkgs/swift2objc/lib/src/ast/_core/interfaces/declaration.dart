// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../../config.dart';
import '../../ast_node.dart';
import '../../declarations/built_in/built_in_declaration.dart';
import '../shared/referred_type.dart';
import 'availability.dart';

/// A common interface for all Swift entities declarations.
abstract interface class Declaration implements AstNode, Availability {
  abstract final String id;
  abstract final String name;
  abstract final InputConfig? source;
  abstract final int? lineNumber;
}

extension AsDeclaredType<T extends Declaration> on T {
  DeclaredType<T> get asDeclaredType => DeclaredType(id: id, declaration: this);
}

extension DeclarationIsBuiltIn on Declaration {
  bool get isBuiltIn =>
      this is BuiltInDeclaration || source == builtInInputConfig;
}
