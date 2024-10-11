// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';

import 'ast.dart';

class ListBindingsTransformation extends Transformation {
  final bindings = <Binding>[];

  @override
  NoLookUpBinding transformNoLookUpBinding(NoLookUpBinding node) {
    if (!node.isObjCImport) {
      node.transformChildren(transformer);
      bindings.add(node);
    }
    return node;
  }

  @override
  Binding transformBinding(Binding node) {
    bindings.add(node);
    return node;
  }
}
