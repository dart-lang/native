// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'dart:isolate';

import 'package:meta/meta.dart' show internal;

import '../jni.dart';
import 'accessors.dart';
import 'jni.dart';
import 'types.dart';

/// A builder that builds proxy objects that implement one or more interfaces.
///
/// Example:
/// ```dart
/// final implementer = JImplemeneter();
/// Foo.implementIn(implementer, fooImpl);
/// Bar.implementIn(implementer, barImpl);
/// final foobar = implementer.build(Foo.type); // Or `Bar.type`.
/// ```
class JImplementer extends JObject {
  JImplementer.fromReference(super.reference) : super.fromReference();

  static final _class =
      JClass.forName(r'com/github/dart_lang/jni/PortProxyBuilder');

  static final _newId = _class.constructorId(r'(J)V');

  static final _new = ProtectedJniExtensions.lookup<
          NativeFunction<
              JniResult Function(Pointer<Void>, JMethodIDPtr,
                  VarArgs<(Int64,)>)>>('globalEnv_NewObject')
      .asFunction<JniResult Function(Pointer<Void>, JMethodIDPtr, int)>();

  factory JImplementer() {
    ProtectedJniExtensions.ensureInitialized();
    return JImplementer.fromReference(_new(
            _class.reference.pointer,
            _newId as JMethodIDPtr,
            ProtectedJniExtensions.getCurrentIsolateId())
        .reference);
  }

  static final _addImplementationId = _class.instanceMethodId(
    r'addImplementation',
    r'(Ljava/lang/String;JJLjava/util/List;)V',
  );

  static final _addImplementation = ProtectedJniExtensions.lookup<
              NativeFunction<
                  JThrowablePtr Function(Pointer<Void>, JMethodIDPtr,
                      VarArgs<(Pointer<Void>, Int64, Int64, Pointer<Void>)>)>>(
          'globalEnv_CallVoidMethod')
      .asFunction<
          JThrowablePtr Function(Pointer<Void>, JMethodIDPtr, Pointer<Void>,
              int, int, Pointer<Void>)>();

  /// Should not be used directly.
  ///
  /// Use `implementIn` from the generated interface instead.
  @internal
  void add(
    String binaryName,
    RawReceivePort port,
    Pointer<NativeFunction<JObjectPtr Function(Int64, JObjectPtr, JObjectPtr)>>
        pointer,
    List<String> asyncMethods,
  ) {
    using((arena) {
      final binaryNameRef =
          (binaryName.toJString()..releasedBy(arena)).reference;
      _addImplementation(
        reference.pointer,
        _addImplementationId as JMethodIDPtr,
        binaryNameRef.pointer,
        port.sendPort.nativePort,
        pointer.address,
        (asyncMethods
                .map((m) => m.toJString()..releasedBy(arena))
                .toJList(JString.type)
              ..releasedBy(arena))
            .reference
            .pointer,
      ).check();
    });
  }

  static final _buildId = _class.instanceMethodId(
    r'build',
    r'()Ljava/lang/Object;',
  );

  static final _build = ProtectedJniExtensions.lookup<
          NativeFunction<
              JniResult Function(
                Pointer<Void>,
                JMethodIDPtr,
              )>>('globalEnv_CallObjectMethod')
      .asFunction<
          JniResult Function(
            Pointer<Void>,
            JMethodIDPtr,
          )>();

  /// Builds an proxy object with the specified [type] that implements all the
  /// added interfaces with the given implementations.
  ///
  /// Releases this implementer.
  T implement<T extends JObject>(JObjType<T> type) {
    return type.fromReference(implementReference());
  }

  /// Used in the JNIgen generated code.
  ///
  /// It is unnecessary to construct the type object when the code is generated.
  @internal
  JReference implementReference() {
    final ref = _build(reference.pointer, _buildId as JMethodIDPtr).reference;
    release();
    return ref;
  }
}
