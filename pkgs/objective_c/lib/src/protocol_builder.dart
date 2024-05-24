// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'c_bindings_generated.dart' as c;
import 'objective_c_bindings_generated.dart' as objc;
import 'internal.dart' show ObjCBlockBase, ObjCProtocolMethod;

// TODO: Docs.
class ObjCProtocolBuilder {
  final _builder = objc.DartProxyBuilder.new1();

  void implementMethod(ObjCProtocolMethod method, ObjCBlockBase? block) {
    if (block != null) {
      assert(method.isCorrectBlockType(block));
      _builder.implementMethod_withSignature_andBlock_(
          method.sel, method.signature, block.pointer.cast());
    }
  }

  objc.DartProxy build() => objc.DartProxy.newFromBuilder_(_builder);
}
