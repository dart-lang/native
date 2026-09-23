// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// dart format width=74

// ignore_for_file: avoid_print, unused_local_variable

import 'package:jni/jni.dart';

dynamic Api;
dynamic MyCustomException;

// snippet-start
void doSomethingInJava() {
  try {
    Api.doSomething();
  } on JThrowable catch (throwable, stackTrace) {
    print('Message: ${throwable.message}');
    print('Java stack trace:\n${throwable.javaStackTrace}');
    print('Dart stack trace:\n$stackTrace');

    if (throwable.isA(MyCustomException.type)) {
      final customEx = throwable.as(MyCustomException.type);
      print('Caught MyCustomException!');
      print('Error Code: ${customEx.errorCode}');
    } else {
      print('Caught unknown Java exception: $throwable');
    }
  }
}
// snippet-end
