// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart' show internal;

import 'jni.dart';
import 'jobject.dart';
import 'types.dart';

@internal
final coroutineSingletonsClass = JClass.forName(
  'kotlin/coroutines/intrinsics/CoroutineSingletons',
);

@internal
final result$FailureClass = JClass.forName(r'kotlin/Result$Failure');

@internal
final failureExceptionField = result$FailureClass.instanceFieldId(
  'exception',
  'Ljava/lang/Throwable;',
);

@internal
final result$Class = JClass.forName(r'kotlin/Result');

@internal
final resultValueField = result$Class.instanceFieldId(
  'value',
  'Ljava/lang/Object;',
);

final _coroutineIntrinsicsClass = JClass.forName(
  'kotlin/coroutines/intrinsics/IntrinsicsKt',
);
final _coroutineSuspended = _coroutineIntrinsicsClass.staticMethodId(
  'getCOROUTINE_SUSPENDED',
  '()Ljava/lang/Object;',
)(_coroutineIntrinsicsClass, const $JObject$Type$(), []);

@internal
class KotlinContinuation extends JObject {
  KotlinContinuation.fromReference(super.reference) : super.fromReference();

  static final _class = JClass.forName(r'kotlin/coroutines/Continuation');

  static final _resumeWithId = _class.instanceMethodId(
    r'resumeWith',
    r'(Ljava/lang/Object;)V',
  );
  void resumeWith(JObject? result) {
    _resumeWithId(this, const jvoidType(), [result]);
  }

  static final _result$FailureConstructor = result$FailureClass.constructorId(
    r'(Ljava/lang/Throwable;)V',
  );
  void resumeWithException(Object dartException, StackTrace stackTrace) {
    resumeWith(
      _result$FailureConstructor(result$FailureClass, JObject.type, [
        ProtectedJniExtensions.newDartException('$dartException\n$stackTrace'),
      ]),
    );
  }

  JObject resumeWithFuture(Future<JObject?> future) {
    future.then(resumeWith, onError: resumeWithException);
    return _coroutineSuspended;
  }
}
