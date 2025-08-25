// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';
import '../context.dart';
import 'ast.dart';

class MarkImportsVisitation extends Visitation {
  final Context context;

  MarkImportsVisitation(this.context);

  @override
  void visitImportedType(ImportedType node) {
    node.visitChildren(visitor);
    context.libs.markUsed(node.libraryImport);
  }
}
