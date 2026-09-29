// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// dart format width=74

// ignore_for_file: avoid_print, unused_local_variable

abstract mixin class $Runnable {
  void run();
  bool get run$async => false;
}

// snippet-start#printer_listener
final class Printer with $Runnable {
  final String text;

  Printer(this.text);

  @override
  void run() {
    print(text);
  }

  @override
  bool get run$async => true; // This makes the run method non-blocking.
}
// snippet-end#printer_listener
