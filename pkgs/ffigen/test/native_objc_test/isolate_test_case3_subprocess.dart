// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'dart:isolate';
import 'isolate_test_bindings.dart';

void case3Helper(SendPort sendPort) async {
  final block = ObjCBlock_ffiVoid_Int32.listener((int x) {
    // Do nothing.
  }, keepIsolateAlive: false);
  sendPort.send(block);
}

void main() async {
  final port = ReceivePort();
  final exitPort = ReceivePort();
  await Isolate.spawn(case3Helper, port.sendPort, onExit: exitPort.sendPort);

  final block = await port.first as ObjCBlock<Void Function(Int32)>;

  // Wait for the helper isolate to exit.
  await exitPort.first;

  // The helper isolate is now completely shut down.
  // Invoking the block now will call the deleted native function pointer
  // under the buggy implementation, resulting in a crash.
  block(123);
}
