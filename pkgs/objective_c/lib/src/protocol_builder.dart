// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'c_bindings_generated.dart' as c;
import 'objective_c_bindings_generated.dart' as objc;
import 'internal.dart' show ObjCBlockBase, ObjCProtocolMethod;

// TODO: Docs.
class ObjCProtocolBuilder {
  final _builder = objc.DartProxyBuilder();

  void implementMethod(ObjCProtocolMethod method, ObjCBlockBase block) {
    assert(method._isCorrectBlockType(block));
    _builder.implementMethod_withSignature_andBlock_(
        method._sel, method._sig, block.pointer.cast());
  }

  objc.DartProxy build() => objc.DartProxy.newFromBuilder_(_builder);
}
