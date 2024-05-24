// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'c_bindings_generated.dart' as c;
import 'objective_c_bindings_generated.dart' as objc;
import 'internal.dart' show ObjCBlockBase, ObjCProtocolMethod;

/// Helper class for building Objective C objects that implement protocols.
class ObjCProtocolBuilder {
  final _builder = objc.DartProxyBuilder.new1();

  /// Implement a protocol [method] using a [block].
  ///
  /// The recommended way of getting the [method] object is to use ffigen to
  /// generate bindings for the protocol you want to implement. The generated
  /// bindings will include a [ObjCProtocolMethod] for each method of the
  /// protocol.
  void implementMethod(ObjCProtocolMethod method, ObjCBlockBase? block) {
    if (block != null) {
      assert(method.isCorrectBlockType(block));
      _builder.implementMethod_withSignature_andBlock_(
          method.sel, method.signature, block.pointer.cast());
    }
  }

  /// Builds the object.
  ///
  /// This can be called multiple times to construct multiple object instances
  /// that all implement the same protocol methods using the same blocks.
  objc.DartProxy build() => objc.DartProxy.newFromBuilder_(_builder);
}
