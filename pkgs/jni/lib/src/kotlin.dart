// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:meta/meta.dart' show internal;

import 'jni.dart';
import 'jobject.dart';
import 'lang/jstring.dart';
import 'jreference.dart';
import 'jvalues.dart';
import 'third_party/generated_bindings.dart';
import 'types.dart';

@internal
final coroutineSingletonsClass =
    JClass.forName('kotlin/coroutines/intrinsics/CoroutineSingletons');

@internal
final result$FailureClass = JClass.forName(r'kotlin/Result$Failure');

@internal
final failureExceptionField =
    result$FailureClass.instanceFieldId('exception', 'Ljava/lang/Throwable;');

final _coroutineSuspended = coroutineSingletonsClass.staticFieldId(
    'COROUTINE_SUSPENDED', 'Lkotlin/coroutines/intrinsics/CoroutineSingletons')
    .get(coroutineSingletonsClass, const $JObject$Type$());

@internal
class KotlinContinuation extends JObject {
  KotlinContinuation.fromReference(
    super.reference,
  ) : super.fromReference();

  static final _class = JClass.forName(r'kotlin/coroutines/Continuation');

  static final _resumeWithId =
      _class.instanceMethodId(r'resumeWith', r'(Ljava/lang/Object;)V');
  void resumeWith(JObject result) {
    _resumeWithId(this, const jvoidType(), [result]);
  }

  JObject resumeWithFuture(Future<JObject> future) {
    future.then((JObject result) {
        final r = _Result(result);
        print(r);
        resumeWith(r);
      }, onError: (error) {
        // TODO
      });
    return _coroutineSuspended;
  }
}

class _Result extends JObject {
  _Result.fromReference(
    super.reference,
  ) : super.fromReference();

  static final _class = JClass.forName(r'kotlin/Result');

  static final _id_new$ = _class.constructorId(
    r'(Ljava/lang/Object;)V',
  );

  static final _new$ = ProtectedJniExtensions.lookup<
              NativeFunction<
                  JniResult Function(
                      Pointer<Void>,
                      JMethodIDPtr,
                      VarArgs<(Pointer<Void>,)>)>>(
          'globalEnv_NewObject')
      .asFunction<
          JniResult Function(Pointer<Void>,
              JMethodIDPtr, Pointer<Void>)>();

  factory _Result(JObject object) {
    return _Result.fromReference(_id_new$(_class, referenceType, [object]));
  }
}
