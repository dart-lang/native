// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'c_bindings_generated.dart' as c;
import 'internal.dart' show
    FailedToLoadProtocolMethodException, GetProtocolName, ObjCBlockBase;
import 'objective_c_bindings_generated.dart' as objc;
import 'selector.dart';

/// Helper class for building Objective C objects that implement protocols.
class ObjCProtocolBuilder {
  final _builder = objc.DartProxyBuilder.new1();

  /// Add a method implementation to the protocol.
  ///
  /// It is not recommended to call this method directly. Instead, use the
  /// implement methods on [ObjCProtocolMethod] and its subclasses.
  void implementMethod(Pointer<c.ObjCSelector> sel,
          objc.NSMethodSignature signature, ObjCBlockBase block) =>
      _builder.implementMethod_withSignature_andBlock_(
          sel, signature, block.ref.pointer.cast());

  /// Builds the object.
  ///
  /// This can be called multiple times to construct multiple object instances
  /// that all implement the same protocol methods using the same functions.
  objc.DartProxy build() => objc.DartProxy.newFromBuilder_(_builder);
}

/// A method in an ObjC protocol.
///
/// Do not try to construct this class directly. The recommended way of getting
/// a method object is to use ffigen to generate bindings for the protocol you
/// want to implement. The generated bindings will include a
/// [ObjCProtocolMethod] for each method of the protocol.
class ObjCProtocolMethod<T extends Function> {
  final Pointer<c.ObjCProtocol> _proto;
  final Pointer<c.ObjCSelector> _sel;
  final objc.NSMethodSignature? _signature;
  final ObjCBlockBase Function(T) _createBlock;

  /// Only for use by ffigen bindings.
  ObjCProtocolMethod(this._proto, this._sel, this._signature, this._createBlock);

  /// Implement this method on the protocol [builder] using a Dart [function].
  ///
  /// The implemented method must be invoked by ObjC code running on the same
  /// thread as the isolate that called implementMethod. Invoking the method on
  /// the wrong thread will result in a crash.
  void implement(ObjCProtocolBuilder builder, T? function) {
    if (function != null) {
      builder.implementMethod(_sel, _sig, _createBlock(function));
    }
  }

  bool get isAvailable => _signature != null;

  objc.NSMethodSignature get _sig {
    final sig = _signature;
    if (sig != null) return sig;
    throw FailedToLoadProtocolMethodException(_proto.name, _sel.toDartString());
  }
}

/// A method in an ObjC protocol that can be implemented as a listener.
///
/// Do not try to construct this class directly. The recommended way of getting
/// a method object is to use ffigen to generate bindings for the protocol you
/// want to implement. The generated bindings will include a
/// [ObjCProtocolMethod] for each method of the protocol.
class ObjCProtocolListenableMethod<T extends Function>
    extends ObjCProtocolMethod<T> {
  final ObjCBlockBase Function(T) _createListenerBlock;

  /// Only for use by ffigen bindings.
  ObjCProtocolListenableMethod(super._proto, super._sel, super._signature, super._createBlock,
      this._createListenerBlock);

  /// Implement this method on the protocol [builder] as a listener using a Dart
  /// [function].
  ///
  /// This is based on FFI's NativeCallable.listener, and has the same
  /// capabilities and limitations. This method can be invoked by ObjC from any
  /// thread, but only supports void functions, and is not run synchronously.
  /// See NativeCallable.listener for more details.
  void implementAsListener(ObjCProtocolBuilder builder, T? function) {
    if (function != null) {
      builder.implementMethod(_sel, _sig, _createListenerBlock(function));
    }
  }
}
