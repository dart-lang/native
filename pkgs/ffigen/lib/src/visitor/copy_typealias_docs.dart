// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';
import 'ast.dart';

/// Copies documentation from same-name type aliases to their target bindings.
class CopyTypealiasDocsVisitation extends Visitation {
  @override
  void visitTypealias(Typealias node) {
    final target = node.type;
    if (target is BindingType &&
        target.originalName == node.originalName &&
        target.dartDoc == null) {
      target.dartDoc = node.dartDoc;
    }
    node.visitChildren(visitor);
  }
}
