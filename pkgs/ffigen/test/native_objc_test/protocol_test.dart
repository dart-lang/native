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

    group('ObjC implementation', () {
      test('Method implementation', () {
        final protoImpl = ObjCProtocolImpl.new1();
        final consumer = ProtocolConsumer.new1();

        // Required instance method.
        final result = consumer.callInstanceMethod_(protoImpl);
        expect(result.toString(), 'ObjCProtocolImpl: Hello from ObjC: 3.14');

        // Optional instance method.
        final intResult = consumer.callOptionalMethod_(protoImpl);
        expect(intResult, 579);

        // Required instance method from secondary protocol.
        final otherIntResult = consumer.callOtherMethod_(protoImpl);
        expect(otherIntResult, 10);
      });

      test('Unimplemented method', () {
        final protoImpl = ObjCProtocolImplMissingMethod.new1();
        final consumer = ProtocolConsumer.new1();

        // Optional instance method, not implemented.
        final intResult = consumer.callOptionalMethod_(protoImpl);
        expect(intResult, -999);
      });
    });

    group('Manual DartProxy implementation', () {
      test('Method implementation', () {
        final protoImpl = DartProxy.new1();
        final consumer = ProtocolConsumer.new1();
        final proto = getProtocol('MyProtocol');
        final secondProto = getProtocol('SecondaryProtocol');

        final sel = registerName('instanceMethod:withDouble:');
        final signature = getProtocolMethodSignature(proto, sel,
            isRequired: true, isInstance: true);
        final block = DartInstanceMethodBlock.fromFunction(
            (Pointer<Void> p, NSString s, double x) {
          return 'DartProxy: $s: $x'.toNSString();
        });
        protoImpl.implementMethod_withSignature_andBlock_(
            sel, signature!, block.pointer.cast());

        final optSel = registerName('optionalMethod:');
        final optSignature = getProtocolMethodSignature(proto, optSel,
            isRequired: false, isInstance: true);
        final optBlock =
            DartOptMethodBlock.fromFunction((Pointer<Void> p, SomeStruct s) {
          return s.y - s.x;
        });
        protoImpl.implementMethod_withSignature_andBlock_(
            optSel, optSignature!, optBlock.pointer.cast());

        final otherSel = registerName('otherMethod:b:c:d:');
        final otherSignature = getProtocolMethodSignature(secondProto, otherSel,
            isRequired: true, isInstance: true);
        final otherBlock = DartOtherMethodBlock.fromFunction(
            (Pointer<Void> p, int a, int b, int c, int d) {
          return a * b * c * d;
        });
        protoImpl.implementMethod_withSignature_andBlock_(
            otherSel, otherSignature!, otherBlock.pointer.cast());

        // Required instance method.
        final result = consumer.callInstanceMethod_(protoImpl);
        expect(result.toString(), "DartProxy: Hello from ObjC: 3.14");

        // Optional instance method.
        final intResult = consumer.callOptionalMethod_(protoImpl);
        expect(intResult, 333);

        // Required instance method from secondary protocol.
        final otherIntResult = consumer.callOtherMethod_(protoImpl);
        expect(otherIntResult, 24);
      });

      test('Unimplemented method', () {
        final protoImpl = DartProxy.new1();
        final consumer = ProtocolConsumer.new1();

        // Optional instance method, not implemented.
        final intResult = consumer.callOptionalMethod_(protoImpl);
        expect(intResult, -999);
      });
    });
  });
}
