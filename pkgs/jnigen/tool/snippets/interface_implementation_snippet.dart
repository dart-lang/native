// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// dart format width=74

// ignore_for_file: avoid_print, unused_local_variable

import 'package:jni/jni.dart';

abstract mixin class $Runnable {
  factory $Runnable({required void Function() run, bool? run$async}) =
      _RunnableImpl;
  void run();
  bool get run$async => false;
}

class _RunnableImpl with $Runnable {
  final void Function() _run;
  @override
  final bool run$async;
  _RunnableImpl({required void Function() run, bool? run$async})
      : _run = run,
        run$async = run$async ?? false;
  @override
  void run() => _run();
}

dynamic Runnable;
dynamic Closable;
dynamic $Closable;
dynamic object;

void runnableLambdaExample() {
  // snippet-start#runnable_lambda
  final runnable = Runnable.implement($Runnable(run: () => print('hello')));
  // snippet-end#runnable_lambda
}

void runnableListenerExample() {
  // snippet-start#runnable_listener
  final runnable = Runnable.implement($Runnable(
    run: () => print('hello'),
    run$async: true, // This makes the run method non-blocking.
  ));
  // snippet-end#runnable_listener
}

void multipleInterfacesExample() {
  // snippet-start#multiple_interfaces
  final implementer = JImplementer();
  Runnable.implementIn(implementer, $Runnable(run: () => print('run')));
  Closable.implementIn(implementer, $Closable(close: () => print('close')));
  final object = implementer.implement(Runnable.type); // or Closable.type.
  // snippet-end#multiple_interfaces

  // snippet-start#cast_closable
  final closable = object.as(Closable.type);
  // snippet-end#cast_closable
}

void threadingExample() {
  // snippet-start#runnable_from_dart
  final runnableFromDart = Runnable.implement(
    $Runnable(run: () => print('hello')),
  );
  // snippet-end#runnable_from_dart
}

void threadingAsyncExample() {
  // snippet-start#runnable_from_dart_async
  final runnableFromDart = Runnable.implement($Runnable(
    run: () => print('hello'),
    run$async: true,
  ));
  // snippet-end#runnable_from_dart_async
}

// snippet-start#printer_subclass
final class Printer with $Runnable {
  final String text;

  Printer(this.text);

  @override
  void run() {
    print(text);
  }
}
// snippet-end#printer_subclass
