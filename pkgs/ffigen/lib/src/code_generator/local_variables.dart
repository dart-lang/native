// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'scope.dart';

/// Manages local variable declarations for a method or block of code.
class LocalVariables {
  final Scope scope;
  final List<String> _declarations = [];

  LocalVariables(this.scope);

  /// Adds a new local variable with the given [value] and returns its name.
  ///
  /// [nameHint] is used to generate a unique private name.
  String addVariable({required String value, String nameHint = 'temp'}) {
    final name = scope.addPrivate('_\$$nameHint');
    _declarations.add('final $name = $value;');
    return name;
  }

  /// Returns whether any local variables have been declared.
  bool get isNotEmpty => _declarations.isNotEmpty;

  /// Generates the declarations of all local variables.
  String generateDeclarations() {
    return _declarations.join('\n');
  }
}
