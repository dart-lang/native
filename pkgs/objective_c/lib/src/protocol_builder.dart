// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'dart:isolate';
import 'dart:math';

import 'package:ffi/ffi.dart';

import 'c_bindings_generated.dart' as c;
import 'internal.dart'
    show
        FailedToLoadProtocolMethodException,
        GetProtocolName,
        ObjCBlockBase,
        getClass,
        msgSendPointer,
        registerName;
import 'objective_c_bindings_generated.dart' as objc;
import 'selector.dart';

/// Helper class for building Objective C objects that implement protocols.
class ObjCProtocolBuilder {
  final _builder = objc.DartProtocolBuilder.new1();
  final Pointer<c.ObjCObject> _class;
  var _built = false;

  ObjCProtocolBuilder({String? debugName})
      : _class = _createProtocolClass(debugName);

  /// Add a method implementation to the protocol.
  ///
  /// It is not recommended to call this method directly. Instead, use the
  /// implement methods on [ObjCProtocolMethod] and its subclasses.
  ///
  /// Note: You cannot call this method after you have called [build].
  void implementMethod(Pointer<c.ObjCSelector> sel, Pointer<Char> signature,
      Pointer<Void> trampoline, ObjCBlockBase block) {
    if (_built) {
      throw StateError('Protocol is already built');
    }
    c.addMethod(_class, sel, trampoline, signature);
    _builder.implementMethod_withBlock_(sel, block.ref.pointer.cast());
  }

  /// Builds the object.
  ///
  /// This can be called multiple times to construct multiple object instances
  /// that all implement the same protocol methods using the same functions.
  objc.NSObject build({bool keepIsolateAlive = true}) {
    if (!_built) {
      c.registerClassPair(_class);
      _built = true;
    }
    final obj = objc.DartProtocol.castFromPointer(
        _msgSendAlloc(_class, _selAlloc),
        retain: false,
        release: true);

    var disposePort = c.ILLEGAL_PORT;
    if (keepIsolateAlive) {
      late final RawReceivePort keepAlivePort;
      keepAlivePort = RawReceivePort((_) => keepAlivePort.close());
      disposePort = keepAlivePort.sendPort.nativePort;
    }
    return obj.initDOBJCDartProtocolFromDartProtocolBuilder_withDisposePort_(
        _builder, disposePort);
  }

  static final _msgSendAlloc = msgSendPointer
      .cast<
          NativeFunction<
              Pointer<c.ObjCObject> Function(
                  Pointer<c.ObjCObject>, Pointer<c.ObjCSelector>)>>()
      .asFunction<
          Pointer<c.ObjCObject> Function(
              Pointer<c.ObjCObject>, Pointer<c.ObjCSelector>)>();
  static final _selAlloc = registerName('alloc');

  static final _protocolClass = getClass('DOBJCDartProtocol');
  static final _rand = Random();
  static Pointer<c.ObjCObject> _createProtocolClass(String? debugName) {
    debugName ??= 'DOBJCDartProtocol';
    final name = '${debugName}_${_rand.nextInt(1 << 32)}'.toNativeUtf8();
    final cls = c.allocateClassPair(_protocolClass, name.cast(), 0);
    calloc.free(name);
    return cls;
  }
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
  final Pointer<Void> _trampoline;
  final Pointer<Char>? _signature;
  final ObjCBlockBase Function(T) _createBlock;

  /// Only for use by ffigen bindings.
  ObjCProtocolMethod(this._proto, this._sel, this._trampoline, this._signature,
      this._createBlock);

  /// Implement this method on the protocol [builder] using a Dart [function].
  ///
  /// The implemented method must be invoked by ObjC code running on the same
  /// thread as the isolate that called implementMethod. Invoking the method on
  /// the wrong thread will result in a crash.
  ///
  /// Note: You cannot call this method after you have called `builder.build`.
  void implement(ObjCProtocolBuilder builder, T? function) {
    if (function != null) {
      implementWithBlock(builder, _createBlock(function));
    }
  }

  /// Implement this method on the protocol [builder] using an ObjC [block].
  ///
  /// **IMPORTANT**: The [block] must have the same signature as the method,
  /// but with an extra `void*` argument as the first parameter, before all the
  /// method parameters. Most users should use one of the other `implement`
  /// methods, which handles this signature change automatically.
  ///
  /// Note: You cannot call this method after you have called `builder.build`.
  void implementWithBlock(ObjCProtocolBuilder builder, ObjCBlockBase block) =>
      builder.implementMethod(_sel, _sig, _trampoline, block);

  bool get isAvailable => _signature != null;

  Pointer<Char> get _sig {
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
  final ObjCBlockBase Function(T) _createBlockingBlock;

  /// Only for use by ffigen bindings.
  ObjCProtocolListenableMethod(
      super._proto,
      super._sel,
      super._trampoline,
      super._signature,
      super._createBlock,
      this._createListenerBlock,
      this._createBlockingBlock);

  /// Implement this method on the protocol [builder] as a listener using a Dart
  /// [function].
  ///
  /// This is based on FFI's NativeCallable.listener, and has the same
  /// capabilities and limitations. This method can be invoked by ObjC from any
  /// thread, but only supports void functions, and is not run synchronously.
  /// See NativeCallable.listener for more details.
  ///
  /// Note: You cannot call this method after you have called `builder.build`.
  void implementAsListener(ObjCProtocolBuilder builder, T? function) {
    if (function != null) {
      implementWithBlock(builder, _createListenerBlock(function));
    }
  }

  /// Implement this method on the protocol [builder] as a blocking listener
  /// using a Dart [function].
  ///
  /// This callback can be invoked from any native thread, and will block the
  /// caller until the callback is handled by the Dart isolate that implemented
  /// the method. Async functions are not supported.
  ///
  /// Note: You cannot call this method after you have called `builder.build`.
  void implementAsBlocking(ObjCProtocolBuilder builder, T? function) {
    if (function != null) {
      implementWithBlock(builder, _createBlockingBlock(function));
    }
  }
}
