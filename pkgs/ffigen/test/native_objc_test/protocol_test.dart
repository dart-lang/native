// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')

import 'dart:ffi';
import 'dart:io';

import 'package:objective_c/objective_c.dart';
import 'package:test/test.dart';

import '../test_utils.dart';
import 'protocol_bindings.dart';
import 'util.dart';

void main() {
  group('protocol', () {
    setUpAll(() {
      logWarnings();
      // TODO(https://github.com/dart-lang/native/issues/1068): Remove this.
      DynamicLibrary.open('../objective_c/test/objective_c.dylib');
      final dylib = File('test/native_objc_test/protocol_test.dylib');
      verifySetupFile(dylib);
      DynamicLibrary.open(dylib.absolute.path);
      generateBindingsForCoverage('protocol');
    });

    test('ObjC implementation', () {
      final protoImpl = ObjCProtocolImpl.new1();
      final consumer = ProtocolConsumer.new1();
      final result = consumer.getProtoString_(protoImpl);
      expect(result.toString(), 'ObjCProtocolImpl: Hello from ObjC: 3.14');
    });

    test('Manual DartProxy implementation', () {
      final protoImpl = DartProxy.new1();
      final sel = registerName('buildString:withDouble:');
      final proto = getProtocol('MyProtocol');
      final signature = getProtocolMethodSignature(proto, sel, true, true);

      final block = DartBuildStringBlock.fromFunction(
          (Pointer<Void> p, NSString s, double x) {
        return 'DartProxy: $s: $x'.toNSString();
      });
      protoImpl.implementMethod_withSignature_andBlock_(
          sel, signature!, block.pointer.cast());
      final consumer = ProtocolConsumer.new1();
      final result = consumer.getProtoString_(protoImpl);
      expect(result.toString(), "DartProxy: Hello from ObjC: 3.14");
    });
  });
}
