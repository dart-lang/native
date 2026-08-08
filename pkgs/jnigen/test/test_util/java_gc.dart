// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:jni/jni.dart';

// Can't reliably force GC on Android.
final canRunJavaGC = !Platform.isAndroid;

void runJavaGC() {
  final managementFactory = JClass.forName(
    'java/lang/management/ManagementFactory',
  );
  final bean = managementFactory
      .staticMethodId(
    'getRuntimeMXBean',
    '()Ljava/lang/management/RuntimeMXBean;',
  )
      .call(managementFactory, JObject.type, []);
  final pid =
      bean.jClass.instanceMethodId('getPid', '()J').call(bean, jlong.type, []);
  ProcessResult result;
  do {
    result = Process.runSync('jcmd', [pid.toString(), 'GC.run']);
    sleep(const Duration(milliseconds: 100));
  } while (result.exitCode != 0);
}

final _executeInternalCommand = () {
  final dylib = DynamicLibrary.process();
  if (dylib.providesSymbol('Dart_ExecuteInternalCommand')) {
    return dylib
        .lookup<NativeFunction<Void Function(Pointer<Char>, Pointer<Void>)>>(
          'Dart_ExecuteInternalCommand',
        )
        .asFunction<void Function(Pointer<Char>, Pointer<Void>)>();
  }
  return null;
}();

final canDoGC = _executeInternalCommand != null;

void runDartGC() {
  if (_executeInternalCommand == null) return;
  final gcNow = 'gc-now'.toNativeUtf8();
  _executeInternalCommand!(gcNow.cast(), nullptr);
  calloc.free(gcNow);
}

Future<void> runBothGC() async {
  runDartGC();
  await Future<void>.delayed(Duration.zero);
  runDartGC();
  runJavaGC();
}

/// A wrapper around Java's `java.lang.ref.WeakReference` for testing GC
/// collection.
class JWeakReference {
  static final _class = JClass.forName('java/lang/ref/WeakReference');
  static final _ctor = _class.constructorId('(Ljava/lang/Object;)V');
  static final _getMethod =
      _class.instanceMethodId('get', '()Ljava/lang/Object;');

  final JObject _weakRef;

  JWeakReference(JObject object) : _weakRef = _ctor.call(_class, [object]);

  /// Returns `true` if the target object has been collected by the Java GC.
  bool get isCollected {
    final res = _getMethod.callNullable(_weakRef, JObject.type, []);
    // ignore: invalid_use_of_internal_member
    return res == null || res.reference.pointer == nullptr;
  }

  void release() {
    _weakRef.release();
  }
}
