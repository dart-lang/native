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
      test('Basics', () {
        final protoImpl = ObjCProtocolImpl.new1();
        final consumer = ProtocolConsumer.new1();

        final result = consumer.getProtoString_(protoImpl);
        expect(result.toString(), 'ObjCProtocolImpl: Hello from ObjC: 3.14');

        final intResult = consumer.callOptionalMethod_(protoImpl);
        expect(intResult, 579);
      });

      test('Unimplemented method', () {
        final protoImpl = ObjCProtocolImplMissingMethod.new1();
        final consumer = ProtocolConsumer.new1();

        final intResult = consumer.callOptionalMethod_(protoImpl);
        expect(intResult, -999);
      });
    });

    group('Manual DartProxy implementation', () {
      test('Basics', () {
        final protoImpl = DartProxy.new1();
        final consumer = ProtocolConsumer.new1();
        final proto = getProtocol('MyProtocol');

        final sel = registerName('buildString:withDouble:');
        final signature = getProtocolMethodSignature(proto, sel,
            isRequired: true, isInstance: true);
        final block = DartBuildStringBlock.fromFunction(
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

        final result = consumer.getProtoString_(protoImpl);
        expect(result.toString(), "DartProxy: Hello from ObjC: 3.14");

        final intResult = consumer.callOptionalMethod_(protoImpl);
        expect(intResult, 333);
      });

      test('Unimplemented method', () {
        final protoImpl = DartProxy.new1();
        final consumer = ProtocolConsumer.new1();

        final intResult = consumer.callOptionalMethod_(protoImpl);
        expect(intResult, -999);
      });
    });
  });
}
