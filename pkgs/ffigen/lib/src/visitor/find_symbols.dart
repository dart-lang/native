// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../context.dart';
import 'ast.dart';

class FindSymbolsVisitation extends Visitation {
  final Context context;
  Namespace currentNamespace;

  FindSymbolsVisitation(this.context) : currentNamespace = context.rootNamespace;

  void with(Namespace newNamespace, Function() fn) {
    final oldNamespace = currentNamespace;
    currentNamespace = newNamespace;
    fn();
    currentNamespace = oldNamespace;
  }

  void add(Symbol symbol) => currentNamespace.add(symbol);

  @override
  void visitBinding(Binding node) {
    add(node.symbol);
    node.visitChildren(visitor);
  }
}
