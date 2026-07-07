// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'dart:io';

import 'package:jni/_internal.dart';
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
