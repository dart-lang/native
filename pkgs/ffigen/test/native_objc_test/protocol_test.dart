// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')

import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:objective_c/objective_c.dart';
import 'package:test/test.dart';

import '../test_utils.dart';
import 'protocol_bindings.dart';
import 'util.dart';

typedef InstanceMethodBlock = ObjCBlock_NSString_ffiVoid_NSString_ffiDouble;
typedef OptionalMethodBlock = ObjCBlock_Int32_ffiVoid_SomeStruct;
typedef VoidMethodBlock = ObjCBlock_ffiVoid_ffiVoid_Int32;
typedef OtherMethodBlock = ObjCBlock_Int32_ffiVoid_Int32_Int32_Int32_Int32;

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
        final protocolImpl = ObjCProtocolImpl.new1();
        final consumer = ProtocolConsumer.new1();

        // Required instance method.
        final result = consumer.callInstanceMethod_(protocolImpl);
        expect(result.toString(), 'ObjCProtocolImpl: Hello from ObjC: 3.14');

        // Optional instance method.
        final intResult = consumer.callOptionalMethod_(protocolImpl);
        expect(intResult, 579);

        // Required instance method from secondary protocol.
        final otherIntResult = consumer.callOtherMethod_(protocolImpl);
        expect(otherIntResult, 10);
      });

      test('Unimplemented method', () {
        final protocolImpl = ObjCProtocolImplMissingMethod.new1();
        final consumer = ProtocolConsumer.new1();

        // Optional instance method, not implemented.
        final intResult = consumer.callOptionalMethod_(protocolImpl);
        expect(intResult, -999);
      });
    });

    group('Dart implementation using helpers', () {
      test('Method implementation', () {
        final consumer = ProtocolConsumer.new1();

        final myProtocol = MyProtocol.implement(
          instanceMethod_withDouble_: (NSString s, double x) {
            return 'MyProtocol: $s: $x'.toNSString();
          },
          optionalMethod_: (SomeStruct s) {
            return s.y - s.x;
          },
        );

        // Required instance method.
        final result = consumer.callInstanceMethod_(myProtocol);
        expect(result.toString(), 'MyProtocol: Hello from ObjC: 3.14');

        // Optional instance method.
        final intResult = consumer.callOptionalMethod_(myProtocol);
        expect(intResult, 333);
      });

      test('Multiple protocol implementation', () {
        final consumer = ProtocolConsumer.new1();

        final protocolBuilder = ObjCProtocolBuilder();
        MyProtocol.addToBuilder(protocolBuilder,
            instanceMethod_withDouble_: (NSString s, double x) {
          return 'ProtocolBuilder: $s: $x'.toNSString();
        });
        SecondaryProtocol.addToBuilder(protocolBuilder,
            otherMethod_b_c_d_: (int a, int b, int c, int d) {
          return a * b * c * d;
        });
        final protocolImpl = protocolBuilder.build();

        // Required instance method.
        final result = consumer.callInstanceMethod_(protocolImpl);
        expect(result.toString(), 'ProtocolBuilder: Hello from ObjC: 3.14');

        // Required instance method from secondary protocol.
        final otherIntResult = consumer.callOtherMethod_(protocolImpl);
        expect(otherIntResult, 24);
      });

      test('Multiple protocol implementation using method fields', () {
        final consumer = ProtocolConsumer.new1();

        final protocolBuilder = ObjCProtocolBuilder();
        MyProtocol.instanceMethod_withDouble_.implement(protocolBuilder,
            (NSString s, double x) {
          return 'ProtocolBuilder: $s: $x'.toNSString();
        });
        SecondaryProtocol.otherMethod_b_c_d_.implement(protocolBuilder,
            (int a, int b, int c, int d) {
          return a * b * c * d;
        });
        final protocolImpl = protocolBuilder.build();

        // Required instance method.
        final result = consumer.callInstanceMethod_(protocolImpl);
        expect(result.toString(), 'ProtocolBuilder: Hello from ObjC: 3.14');

        // Required instance method from secondary protocol.
        final otherIntResult = consumer.callOtherMethod_(protocolImpl);
        expect(otherIntResult, 24);
      });

      test('Unimplemented method', () {
        final consumer = ProtocolConsumer.new1();

        final myProtocol = MyProtocol.implement(
          instanceMethod_withDouble_: (NSString s, double x) {
            throw UnimplementedError();
          },
        );

        // Optional instance method, not implemented.
        final intResult = consumer.callOptionalMethod_(myProtocol);
        expect(intResult, -999);
      });

      test('Method implementation as listener', () async {
        final consumer = ProtocolConsumer.new1();

        final listenerCompleter = Completer<int>();
        final myProtocol = MyProtocol.implementAsListener(
          instanceMethod_withDouble_: (NSString s, double x) {
            return 'MyProtocol: $s: $x'.toNSString();
          },
          optionalMethod_: (SomeStruct s) {
            return s.y - s.x;
          },
          voidMethod_: (int x) {
            listenerCompleter.complete(x);
          },
        );

        // Required instance method.
        final result = consumer.callInstanceMethod_(myProtocol);
        expect(result.toString(), 'MyProtocol: Hello from ObjC: 3.14');

        // Optional instance method.
        final intResult = consumer.callOptionalMethod_(myProtocol);
        expect(intResult, 333);

        // Listener method.
        consumer.callMethodOnRandomThread_(myProtocol);
        expect(await listenerCompleter.future, 123);
      });

      test('Multiple protocol implementation as listener', () async {
        final consumer = ProtocolConsumer.new1();

        final listenerCompleter = Completer<int>();
        final protocolBuilder = ObjCProtocolBuilder();
        MyProtocol.addToBuilderAsListener(protocolBuilder,
          instanceMethod_withDouble_: (NSString s, double x) {
            return 'ProtocolBuilder: $s: $x'.toNSString();
          },
          voidMethod_: (int x) {
            listenerCompleter.complete(x);
          },);
        SecondaryProtocol.addToBuilder(protocolBuilder,
            otherMethod_b_c_d_: (int a, int b, int c, int d) {
          return a * b * c * d;
        });
        final protocolImpl = protocolBuilder.build();

        // Required instance method.
        final result = consumer.callInstanceMethod_(protocolImpl);
        expect(result.toString(), 'ProtocolBuilder: Hello from ObjC: 3.14');

        // Required instance method from secondary protocol.
        final otherIntResult = consumer.callOtherMethod_(protocolImpl);
        expect(otherIntResult, 24);

        // Listener method.
        consumer.callMethodOnRandomThread_(protocolImpl);
        expect(await listenerCompleter.future, 123);
      });
    });

    group('Manual DartProxy implementation', () {
      test('Method implementation', () {
        final proxyBuilder = DartProxyBuilder.new1();
        final consumer = ProtocolConsumer.new1();
        final protocol = getProtocol('MyProtocol');
        final secondProtocol = getProtocol('SecondaryProtocol');

        final sel = registerName('instanceMethod:withDouble:');
        final signature = getProtocolMethodSignature(protocol, sel,
            isRequired: true, isInstanceMethod: true);
        final block = InstanceMethodBlock.fromFunction(
            (Pointer<Void> p, NSString s, double x) {
          return 'DartProxy: $s: $x'.toNSString();
        });
        proxyBuilder.implementMethod_withSignature_andBlock_(
            sel, signature, block.pointer.cast());

        final optSel = registerName('optionalMethod:');
        final optSignature = getProtocolMethodSignature(protocol, optSel,
            isRequired: false, isInstanceMethod: true);
        final optBlock =
            OptionalMethodBlock.fromFunction((Pointer<Void> p, SomeStruct s) {
          return s.y - s.x;
        });
        proxyBuilder.implementMethod_withSignature_andBlock_(
            optSel, optSignature, optBlock.pointer.cast());

        final otherSel = registerName('otherMethod:b:c:d:');
        final otherSignature = getProtocolMethodSignature(
            secondProtocol, otherSel,
            isRequired: true, isInstanceMethod: true);
        final otherBlock = OtherMethodBlock.fromFunction(
            (Pointer<Void> p, int a, int b, int c, int d) {
          return a * b * c * d;
        });
        proxyBuilder.implementMethod_withSignature_andBlock_(
            otherSel, otherSignature, otherBlock.pointer.cast());

        final proxy = DartProxy.newFromBuilder_(proxyBuilder);

        // Required instance method.
        final result = consumer.callInstanceMethod_(proxy);
        expect(result.toString(), "DartProxy: Hello from ObjC: 3.14");

        // Optional instance method.
        final intResult = consumer.callOptionalMethod_(proxy);
        expect(intResult, 333);

        // Required instance method from secondary protocol.
        final otherIntResult = consumer.callOtherMethod_(proxy);
        expect(otherIntResult, 24);
      });

      test('Unimplemented method', () {
        final proxyBuilder = DartProxyBuilder.new1();
        final consumer = ProtocolConsumer.new1();
        final proxy = DartProxy.newFromBuilder_(proxyBuilder);

        // Optional instance method, not implemented.
        final intResult = consumer.callOptionalMethod_(proxy);
        expect(intResult, -999);
      });

      test('Threading stress test', () async {
        final consumer = ProtocolConsumer.new1();
        final completer = Completer<void>();
        int count = 0;

        final protocolBuilder = ObjCProtocolBuilder();
        MyProtocol.voidMethod_.implementAsListener(protocolBuilder, (int x) {
          expect(x, 123);
          ++count;
          if (count == 1000) completer.complete();
        });

        final proxy = protocolBuilder.build();

        for (int i = 0; i < 1000; ++i) {
          consumer.callMethodOnRandomThread_(proxy);
        }
        await completer.future;
        expect(count, 1000);
      });

      (DartProxy, Pointer<ObjCBlock>) blockRefCountTestInner() {
        final proxyBuilder = DartProxyBuilder.new1();
        final protocol = getProtocol('MyProtocol');

        final sel = registerName('instanceMethod:withDouble:');
        final signature = getProtocolMethodSignature(protocol, sel,
            isRequired: true, isInstanceMethod: true);
        final block = InstanceMethodBlock.fromFunction(
            (Pointer<Void> p, NSString s, double x) => 'Hello'.toNSString());
        proxyBuilder.implementMethod_withSignature_andBlock_(
            sel, signature, block.pointer.cast());

        final proxy = DartProxy.newFromBuilder_(proxyBuilder);

        final proxyPtr = proxy.pointer;
        final blockPtr = block.pointer;

        // There are 2 references to the block. One owned by the Dart wrapper
        // object, and the other owned by the proxy. The method signature is
        // also an ObjC object, so the same is true for it.
        doGC();
        expect(objectRetainCount(proxyPtr), 1);
        expect(blockRetainCount(blockPtr), 2);

        return (proxy, blockPtr);
      }

      (Pointer<ObjCObject>, Pointer<ObjCBlock>) blockRefCountTest() {
        final (proxy, blockPtr) = blockRefCountTestInner();
        final proxyPtr = proxy.pointer;

        // The Dart side block pointer has gone out of scope, but the proxy
        // still owns a reference to it. Same for the signature.
        doGC();
        expect(objectRetainCount(proxyPtr), 1);
        expect(blockRetainCount(blockPtr), 1);

        return (proxyPtr, blockPtr);
      }

      test('Block ref counting', () {
        final (proxyPtr, blockPtr) = blockRefCountTest();

        // The proxy object has gone out of scope, so it should be cleaned up.
        // So should the block and the signature.
        doGC();
        expect(objectRetainCount(proxyPtr), 0);
        expect(blockRetainCount(blockPtr), 0);
      });
    });
  });
}
