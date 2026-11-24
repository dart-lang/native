// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:jni/jni.dart';
import 'package:jni/src/build_util/build_util.dart';

typedef TestCaseCallback = void Function();
typedef TestRunnerCallback = void
    Function(String description, TestCaseCallback test, {Object? skip});

final currentDir = Directory.current.uri;
final dllSuffix =
    Platform.isWindows ? 'dll' : (Platform.isMacOS ? 'dylib' : 'so');
final dllPrefix = Platform.isWindows ? '' : 'lib';
final dllPath =
    currentDir.resolve('build/jni_libs/${dllPrefix}dartjni.$dllSuffix');
final srcPath = currentDir.resolve('src/');

/// Fail if dartjni dll is stale.
void checkDylibIsUpToDate() {
  final dllFile = File.fromUri(dllPath);
  if (needsBuild(File.fromUri(dllPath), Directory.fromUri(srcPath))) {
    final cause = dllFile.existsSync()
        ? 'not up-to-date with source modifications'
        : 'not built';
    var message = '\nFatal: dartjni.$dllSuffix is $cause. Please run '
        '`dart run jni:setup` and try again.';
    if (stderr.supportsAnsiEscapes) {
      message = ansiRed + message + ansiDefault;
    }
    stderr.writeln(message);
    exit(1);
  }
}

void spawnJvm() {
  Jni.spawnIfNotExists(
      dylibDir: 'build/jni_libs', jvmOptions: ['-Xmx128m', '-Xcheck:jni']);
}

bool get assertsEnabled {
  var enabled = false;
  assert(() {
    enabled = true;
    return true;
  }());
  return enabled;
}

final _executeInternalCommand = DynamicLibrary.process().lookupFunction<
    Void Function(Pointer<Char>, Pointer<Void>),
    void Function(Pointer<Char>, Pointer<Void>)>('Dart_ExecuteInternalCommand');

/// Triggers a synchronous Dart GC.
///
/// Only supported when `!Platform.isAndroid`.
void doGC() {
  assert(!Platform.isAndroid);
  final gcNow = 'gc-now'.toNativeUtf8();
  _executeInternalCommand(gcNow.cast(), nullptr);
  calloc.free(gcNow);
}

/// Triggers Dart GC and yields so finalizers have a chance to run.
///
/// Only supported when `!Platform.isAndroid`.
Future<void> doGCAndWaitForFinalizers() async {
  doGC();
  await Future<void>.delayed(Duration.zero);
  doGC();
}

final _weakRefClass = JClass.forName('java/lang/ref/WeakReference');
final _weakRefCtor = _weakRefClass.constructorId('(Ljava/lang/Object;)V');
final _weakRefGet =
    _weakRefClass.instanceMethodId('get', '()Ljava/lang/Object;');
final _systemClass = JClass.forName('java/lang/System');
final _systemGc = _systemClass.staticMethodId('gc', '()V');

/// Creates a Java `WeakReference` to [target], registered for release with
/// [arena].
JObject makeWeakRef(JObject target, Arena arena) =>
    _weakRefCtor(_weakRefClass, [target])..releasedBy(arena);

/// Triggers Java GC (without triggering Dart GC) and returns whether the
/// referent of [weakRef] has been collected.
bool isJavaObjectCollected(JObject weakRef) {
  // System.gc() is only a hint to the JVM, and some collectors or runtimes
  // may require multiple cycles to clear WeakReferences.
  for (var i = 0; i < 5; i++) {
    _systemGc(_systemClass, jvoid.type, []);
    final referent = _weakRefGet.callNullable(weakRef, JObject.type, []);
    if (referent == null) {
      return true;
    }
    referent.release();
  }
  return false;
}
