// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'objective_c_bindings_generated.dart' as objc;
import 'internal.dart' show ObjCBlockBase, ObjCProtocolMethod;

/// Helper class for building Objective C objects that implement protocols.
class ObjCProtocolBuilder {
  final _builder = objc.DartProxyBuilder.new1();

  /// Implement an ObjC protocol [method] using a Dart [function].
  ///
  /// The implemented method must be invoked by ObjC code running on the same
  /// thread as the isolate that called [implementMethod]. Invoking the method
  /// on the wrong thread will result in a crash.
  ///
  /// The recommended way of getting the [method] object is to use ffigen to
  /// generate bindings for the protocol you want to implement. The generated
  /// bindings will include a [ObjCProtocolMethod] for each method of the
  /// protocol.
  void implementMethod(ObjCProtocolMethod method, Function? function) =>
      _implement(method, function, method.createBlock);

  /// Implement an ObjC protocol [method] as a listener using a Dart [function].
  ///
  /// This is based on FFI's NativeCallable.listener, and has the same
  /// capabilities and limitations. This method can be invoked by ObjC from any
  /// thread, but only supports void functions, and is not run synchronously.
  /// See NativeCallable.listener for more details.
  ///
  /// The recommended way of getting the [method] object is to use ffigen to
  /// generate bindings for the protocol you want to implement. The generated
  /// bindings will include a [ObjCProtocolMethod] for each method of the
  /// protocol.
  void implementMethodAsListener(
          ObjCProtocolMethod method, Function? function) =>
      _implement(method, function, method.createListenerBlock);

  /// Builds the object.
  ///
  /// This can be called multiple times to construct multiple object instances
  /// that all implement the same protocol methods using the same functions.
  objc.DartProxy build() => objc.DartProxy.newFromBuilder_(_builder);

  void _implement(ObjCProtocolMethod method, Function? function,
      ObjCBlockBase Function(Function) blockMaker) {
    if (function != null) {
      assert(method.isCorrectFunctionType(function));
      _builder.implementMethod_withSignature_andBlock_(
          method.sel, method.signature, blockMaker(function).pointer.cast());
    }
  }
}
