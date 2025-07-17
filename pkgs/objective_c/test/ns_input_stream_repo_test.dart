// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
library;

import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:objective_c/objective_c.dart'
    hide autoreleasePoolPop, autoreleasePoolPush;
import 'package:objective_c/src/objective_c_bindings_generated.dart'
    show DartInputStreamAdapter;
import 'package:test/test.dart';

import 'util.dart';

Future<(int, Uint8List, bool, NSStreamStatus, NSError?)> read(
  NSInputStream stream,
  int size,
) => Isolate.run(() {
  final buffer = calloc<Uint8>(size);
  final readSize = stream.read(buffer, maxLength: size);
  final data = Uint8List.fromList(
    buffer.asTypedList(readSize == -1 ? 0 : readSize),
  );
  calloc.free(buffer);
  return (
    readSize,
    data,
    stream.hasBytesAvailable,
    stream.streamStatus,
    stream.streamError,
  );
});

void main() {
  group('NSInputStream', () {
    setUpAll(() {
      // TODO(https://github.com/dart-lang/native/issues/1068): Remove this.
      DynamicLibrary.open(testDylib);
    });
    test('nothing', () async {
      final r = ReceivePort();
      Isolate.spawn(
        (_) async {
          final x = const Stream<List<int>>.empty().toNSInputStream();
          //          final pool = autoreleasePoolPush();
          // final x = DartInputStreamAdapter.inputStreamWithPort(123);
          //          autoreleasePoolPop(pool);
          print('Just about to release!');
          print('The pointer for x is: ${x.ref.pointer}');
          x.ref.release();
          print('x.ref.isReleased: ${x.ref.isReleased}');
          //            x.open();
          //            x.close();
        },
        Void,
        onExit: r.sendPort,
      );
      // Will never exit unless the `x.close` is called../
      print('exited: ${await r.first}');
      await Future.delayed(const Duration(seconds: 2));
      print('After delay');
    });
  });
}
