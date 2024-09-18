// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: unused_local_variable

// Objective C support is only available on mac.
@TestOn('mac-os')

import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:objective_c/objective_c.dart';
import 'package:objective_c/src/internal.dart' as internal_for_testing
    show blockHasRegisteredClosure;
import 'package:test/test.dart';

import '../test_utils.dart';
import 'block_bindings.dart';
import 'util.dart';

typedef IntBlock = ObjCBlock_Int32_Int32;
typedef VoidBlock = ObjCBlock_ffiVoid;
typedef ListenerBlock = ObjCBlock_ffiVoid_IntBlock;
typedef FloatBlock = ObjCBlock_ffiFloat_ffiFloat;
typedef DoubleBlock = ObjCBlock_ffiDouble_ffiDouble;
typedef Vec4Block = ObjCBlock_Vec4_Vec4;
typedef ObjectBlock = ObjCBlock_DummyObject_DummyObject;
typedef NullableObjectBlock = ObjCBlock_DummyObject_DummyObject1;
typedef NullableStringBlock = ObjCBlock_NSString_NSString;
typedef ObjectListenerBlock = ObjCBlock_ffiVoid_DummyObject;
typedef NullableListenerBlock = ObjCBlock_ffiVoid_DummyObject1;
typedef StructListenerBlock = ObjCBlock_ffiVoid_Vec2_Vec4_NSObject;
typedef NSStringListenerBlock = ObjCBlock_ffiVoid_NSString;
typedef NoTrampolineListenerBlock = ObjCBlock_ffiVoid_Int32_Vec4_ffiChar;
typedef BlockBlock = ObjCBlock_IntBlock_IntBlock;

void main() {
  late final BlockTestObjCLibrary lib;

  group('Blocks', () {
    setUpAll(() {
      // TODO(https://github.com/dart-lang/native/issues/1068): Remove this.
      DynamicLibrary.open('../objective_c/test/objective_c.dylib');
      final dylib = File('test/native_objc_test/block_test.dylib');
      verifySetupFile(dylib);
      lib = BlockTestObjCLibrary(DynamicLibrary.open(dylib.absolute.path));

      generateBindingsForCoverage('block');
    });

    test('BlockTester is working', () {
      // This doesn't test any Block functionality, just that the BlockTester
      // itself is working correctly.
      final blockTester = BlockTester.newFromMultiplier_(10);
      expect(blockTester.call_(123), 1230);
      final intBlock = blockTester.getBlock();
      final blockTester2 = BlockTester.newFromBlock_(intBlock);
      blockTester2.pokeBlock();
      expect(blockTester2.call_(456), 4560);
    });

    test('Block from function pointer', () {
      final block =
          IntBlock.fromFunctionPointer(Pointer.fromFunction(_add100, 999));
      final blockTester = BlockTester.newFromBlock_(block);
      blockTester.pokeBlock();
      expect(blockTester.call_(123), 223);
      expect(block(123), 223);
    });

    int Function(int) makeAdder(int addTo) {
      return (int x) => addTo + x;
    }

    test('Block from function', () {
      final block = IntBlock.fromFunction(makeAdder(4000));
      final blockTester = BlockTester.newFromBlock_(block);
      blockTester.pokeBlock();
      expect(blockTester.call_(123), 4123);
      expect(block(123), 4123);
    });

    test('Listener block same thread', () async {
      final hasRun = Completer<void>();
      int value = 0;
      final block = VoidBlock.listener(() {
        value = 123;
        hasRun.complete();
      });

      BlockTester.callOnSameThread_(block);

      await hasRun.future;
      expect(value, 123);
    });

    test('Listener block new thread', () async {
      final hasRun = Completer<void>();
      int value = 0;
      final block = VoidBlock.listener(() {
        value = 123;
        hasRun.complete();
      });

      final thread = BlockTester.callOnNewThread_(block);
      thread.start();

      await hasRun.future;
      expect(value, 123);
    });

    test('Float block', () {
      final block = FloatBlock.fromFunction((double x) {
        return x + 4.56;
      });
      expect(block(1.23), closeTo(5.79, 1e-6));
      expect(BlockTester.callFloatBlock_(block), closeTo(5.79, 1e-6));
    });

    test('Double block', () {
      final block = DoubleBlock.fromFunction((double x) {
        return x + 4.56;
      });
      expect(block(1.23), closeTo(5.79, 1e-6));
      expect(BlockTester.callDoubleBlock_(block), closeTo(5.79, 1e-6));
    });

    test('Struct block', () {
      using((Arena arena) {
        final inputPtr = arena<Vec4>();
        final input = inputPtr.ref;
        input.x = 1.2;
        input.y = 3.4;
        input.z = 5.6;
        input.w = 7.8;

        final tempPtr = arena<Vec4>();
        final temp = tempPtr.ref;
        final block = Vec4Block.fromFunction((Vec4 v) {
          // Twiddle the Vec4 components.
          temp.x = v.y;
          temp.y = v.z;
          temp.z = v.w;
          temp.w = v.x;
          return temp;
        });

        final result1 = block(input);
        expect(result1.x, 3.4);
        expect(result1.y, 5.6);
        expect(result1.z, 7.8);
        expect(result1.w, 1.2);

        final result2Ptr = arena<Vec4>();
        final result2 = result2Ptr.ref;
        BlockTester.callVec4Block_(result2Ptr, block);
        expect(result2.x, 3.4);
        expect(result2.y, 5.6);
        expect(result2.z, 7.8);
        expect(result2.w, 1.2);
      });
    });

    test('Object block', () {
      bool isCalled = false;
      final block = ObjectBlock.fromFunction((DummyObject x) {
        isCalled = true;
        return x;
      });

      final obj = DummyObject.new1();
      final result1 = block(obj);
      expect(result1, obj);
      expect(isCalled, isTrue);

      isCalled = false;
      final result2 = BlockTester.callObjectBlock_(block);
      expect(result2, isNot(obj));
      expect(result2.ref.pointer, isNot(nullptr));
      expect(isCalled, isTrue);
    });

    test('Nullable object block', () {
      bool isCalled = false;
      final block = NullableObjectBlock.fromFunction((DummyObject? x) {
        isCalled = true;
        return x;
      });

      final obj = DummyObject.new1();
      final result1 = block(obj);
      expect(result1, obj);
      expect(isCalled, isTrue);

      isCalled = false;
      final result2 = block(null);
      expect(result2, isNull);
      expect(isCalled, isTrue);

      isCalled = false;
      final result3 = BlockTester.callNullableObjectBlock_(block);
      expect(result3, isNull);
      expect(isCalled, isTrue);
    });

    test('Nullable string block', () {
      // Regression test for https://github.com/dart-lang/native/issues/1537.
      final block = NullableStringBlock.fromFunction(
          (NSString? x) => '$x Cat'.toNSString());

      final result1 = block('Dog'.toNSString());
      expect(result1.toString(), 'Dog Cat');

      final result2 = block(null);
      expect(result2.toString(), 'null Cat');

      final result3 = BlockTester.callNullableStringBlock_(block);
      expect(result3.toString(), 'Lizard Cat');
    });

    test('Object listener block', () async {
      final hasRun = Completer<void>();
      final block = ObjectListenerBlock.listener((DummyObject x) {
        expect(x, isNotNull);
        hasRun.complete();
      });

      BlockTester.callObjectListener_(block);
      await hasRun.future;
    });

    test('Nullable listener block', () async {
      final hasRun = Completer<void>();
      final block = NullableListenerBlock.listener((DummyObject? x) {
        expect(x, isNull);
        hasRun.complete();
      });

      BlockTester.callNullableListener_(block);
      await hasRun.future;
    });

    test('Struct listener block', () async {
      final hasRun = Completer<void>();
      final block =
          StructListenerBlock.listener((Vec2 vec2, Vec4 vec4, NSObject dummy) {
        expect(vec2.x, 100);
        expect(vec2.y, 200);

        expect(vec4.x, 1.2);
        expect(vec4.y, 3.4);
        expect(vec4.z, 5.6);
        expect(vec4.w, 7.8);

        expect(dummy, isNotNull);

        hasRun.complete();
      });

      BlockTester.callStructListener_(block);
      await hasRun.future;
    });

    test('NSString listener block', () async {
      final hasRun = Completer<void>();
      final block = NSStringListenerBlock.listener((NSString s) {
        expect(s.toString(), "Foo 123");
        hasRun.complete();
      });

      BlockTester.callNSStringListener_x_(block, 123);
      await hasRun.future;
    });

    test('No trampoline listener block', () async {
      final hasRun = Completer<void>();
      final block = NoTrampolineListenerBlock.listener(
          (int x, Vec4 vec4, Pointer<Char> charPtr) {
        expect(x, 123);

        expect(vec4.x, 1.2);
        expect(vec4.y, 3.4);
        expect(vec4.z, 5.6);
        expect(vec4.w, 7.8);

        expect(charPtr.cast<Utf8>().toDartString(), "Hello World");

        hasRun.complete();
      });

      BlockTester.callNoTrampolineListener_(block);
      await hasRun.future;
    });

    test('Block block', () {
      final blockBlock =
          BlockBlock.fromFunction((ObjCBlock<Int32 Function(Int32)> intBlock) {
        return IntBlock.fromFunction((int x) {
          return 3 * intBlock(x);
        });
      });

      final intBlock = IntBlock.fromFunction((int x) {
        return 5 * x;
      });
      final result1 = blockBlock(intBlock);
      expect(result1(1), 15);

      final result2 = BlockTester.newBlock_withMult_(blockBlock, 2);
      expect(result2(1), 6);
    });

    test('Native block block', () {
      final blockBlock = BlockTester.newBlockBlock_(7);

      final intBlock = IntBlock.fromFunction((int x) {
        return 5 * x;
      });
      final result1 = blockBlock(intBlock);
      expect(result1(1), 35);

      final result2 = BlockTester.newBlock_withMult_(blockBlock, 2);
      expect(result2(1), 14);
    });

    Pointer<ObjCBlockImpl> funcPointerBlockRefCountTest() {
      final block =
          IntBlock.fromFunctionPointer(Pointer.fromFunction(_add100, 999));
      expect(internal_for_testing.blockHasRegisteredClosure(block.ref.pointer),
          false);
      expect(blockRetainCount(block.ref.pointer), 1);
      return block.ref.pointer;
    }

    test('Function pointer block ref counting', () async {
      final rawBlock = funcPointerBlockRefCountTest();
      await doGC();
      expect(blockRetainCount(rawBlock), 0);
    });

    Pointer<ObjCBlockImpl> funcBlockRefCountTest() {
      final block = IntBlock.fromFunction(makeAdder(4000));
      expect(internal_for_testing.blockHasRegisteredClosure(block.ref.pointer),
          true);
      expect(blockRetainCount(block.ref.pointer), 1);
      return block.ref.pointer;
    }

    test('Function block ref counting', () async {
      final rawBlock = funcBlockRefCountTest();
      await doGC();
      await Future<void>.delayed(Duration.zero); // Let dispose message arrive.
      expect(blockRetainCount(rawBlock), 0);
      expect(internal_for_testing.blockHasRegisteredClosure(rawBlock.cast()),
          false);
    });

    Pointer<ObjCBlockImpl> blockManualRetainRefCountTest() {
      final block = IntBlock.fromFunction(makeAdder(4000));
      expect(internal_for_testing.blockHasRegisteredClosure(block.ref.pointer),
          true);
      expect(blockRetainCount(block.ref.pointer), 1);
      final rawBlock = block.ref.retainAndReturnPointer();
      expect(blockRetainCount(rawBlock), 2);
      return rawBlock;
    }

    int blockManualRetainRefCountTest2(Pointer<ObjCBlockImpl> rawBlock) {
      final block = IntBlock.castFromPointer(rawBlock.cast(),
          retain: false, release: true);
      return blockRetainCount(block.ref.pointer);
    }

    test('Block ref counting with manual retain and release', () async {
      final rawBlock = blockManualRetainRefCountTest();
      await doGC();
      expect(blockRetainCount(rawBlock), 1);
      expect(blockManualRetainRefCountTest2(rawBlock), 1);
      await doGC();
      await Future<void>.delayed(Duration.zero); // Let dispose message arrive.
      expect(blockRetainCount(rawBlock), 0);
      expect(internal_for_testing.blockHasRegisteredClosure(rawBlock.cast()),
          false);
    });

    Future<
        (
          Pointer<ObjCBlockImpl>,
          Pointer<ObjCBlockImpl>,
          Pointer<ObjCBlockImpl>
        )> blockBlockDartCallRefCountTest() async {
      final pool = lib.objc_autoreleasePoolPush();
      final inputBlock = IntBlock.fromFunction((int x) {
        return 5 * x;
      });
      final blockBlock =
          BlockBlock.fromFunction((ObjCBlock<Int32 Function(Int32)> intBlock) {
        return IntBlock.fromFunction((int x) {
          return 3 * intBlock(x);
        });
      });
      final outputBlock = blockBlock(inputBlock);
      expect(outputBlock(1), 15);
      lib.objc_autoreleasePoolPop(pool);
      await doGC();

      // One reference held by inputBlock object, another bound to the
      // outputBlock lambda.
      expect(blockRetainCount(inputBlock.ref.pointer), 2);
      expect(
          internal_for_testing
              .blockHasRegisteredClosure(inputBlock.ref.pointer.cast()),
          true);

      expect(blockRetainCount(blockBlock.ref.pointer), 1);
      expect(
          internal_for_testing
              .blockHasRegisteredClosure(blockBlock.ref.pointer.cast()),
          true);
      expect(blockRetainCount(outputBlock.ref.pointer), 1);
      expect(
          internal_for_testing
              .blockHasRegisteredClosure(outputBlock.ref.pointer.cast()),
          true);
      return (
        inputBlock.ref.pointer,
        blockBlock.ref.pointer,
        outputBlock.ref.pointer
      );
    }

    test('Calling a block block from Dart has correct ref counting', () async {
      final (inputBlock, blockBlock, outputBlock) =
          await blockBlockDartCallRefCountTest();
      await doGC();
      await Future<void>.delayed(Duration.zero); // Let dispose message arrive.
      await doGC();
      await Future<void>.delayed(Duration.zero); // Let dispose message arrive.

      expect(blockRetainCount(inputBlock), 0);
      expect(internal_for_testing.blockHasRegisteredClosure(inputBlock.cast()),
          false);
      expect(blockRetainCount(blockBlock), 0);
      expect(internal_for_testing.blockHasRegisteredClosure(blockBlock.cast()),
          false);
      expect(blockRetainCount(outputBlock), 0);
      expect(internal_for_testing.blockHasRegisteredClosure(outputBlock.cast()),
          false);
    });

    Future<
        (
          Pointer<ObjCBlockImpl>,
          Pointer<ObjCBlockImpl>,
          Pointer<ObjCBlockImpl>
        )> blockBlockObjCCallRefCountTest() async {
      final pool = lib.objc_autoreleasePoolPush();
      late Pointer<ObjCBlockImpl> inputBlock;
      final blockBlock =
          BlockBlock.fromFunction((ObjCBlock<Int32 Function(Int32)> intBlock) {
        inputBlock = intBlock.ref.pointer;
        return IntBlock.fromFunction((int x) {
          return 3 * intBlock(x);
        });
      });
      final outputBlock = BlockTester.newBlock_withMult_(blockBlock, 2);
      expect(outputBlock(1), 6);
      lib.objc_autoreleasePoolPop(pool);
      await doGC();

      expect(blockRetainCount(inputBlock), 1);
      expect(internal_for_testing.blockHasRegisteredClosure(inputBlock.cast()),
          false);
      expect(blockRetainCount(blockBlock.ref.pointer), 1);
      expect(
          internal_for_testing
              .blockHasRegisteredClosure(blockBlock.ref.pointer.cast()),
          true);
      expect(blockRetainCount(outputBlock.ref.pointer), 1);
      expect(
          internal_for_testing
              .blockHasRegisteredClosure(outputBlock.ref.pointer.cast()),
          true);
      return (inputBlock, blockBlock.ref.pointer, outputBlock.ref.pointer);
    }

    test('Calling a block block from ObjC has correct ref counting', () async {
      final (inputBlock, blockBlock, outputBlock) =
          await blockBlockObjCCallRefCountTest();
      await doGC();
      await Future<void>.delayed(Duration.zero); // Let dispose message arrive.
      await doGC();
      await Future<void>.delayed(Duration.zero); // Let dispose message arrive.

      expect(blockRetainCount(inputBlock), 0);
      expect(internal_for_testing.blockHasRegisteredClosure(inputBlock.cast()),
          false);
      expect(blockRetainCount(blockBlock), 0);
      expect(internal_for_testing.blockHasRegisteredClosure(blockBlock.cast()),
          false);
      expect(blockRetainCount(outputBlock), 0);
      expect(internal_for_testing.blockHasRegisteredClosure(outputBlock.cast()),
          false);
    });

    Future<(Pointer<ObjCBlockImpl>, Pointer<ObjCBlockImpl>, Pointer<ObjCBlockImpl>)>
        nativeBlockBlockDartCallRefCountTest() async {
      final pool = lib.objc_autoreleasePoolPush();
      final inputBlock = IntBlock.fromFunction((int x) {
        return 5 * x;
      });
      final blockBlock = BlockTester.newBlockBlock_(7);
      final outputBlock = blockBlock(inputBlock);
      expect(outputBlock(1), 35);
      lib.objc_autoreleasePoolPop(pool);
      await doGC();

      // One reference held by inputBlock object, another held internally by the
      // ObjC implementation of the blockBlock.
      expect(blockRetainCount(inputBlock.ref.pointer), 2);

      expect(blockRetainCount(blockBlock.ref.pointer), 1);
      expect(blockRetainCount(outputBlock.ref.pointer), 1);
      return (
        inputBlock.ref.pointer,
        blockBlock.ref.pointer,
        outputBlock.ref.pointer
      );
    }

    test('Calling a native block block from Dart has correct ref counting',
        () async {
      final (inputBlock, blockBlock, outputBlock) =
          await nativeBlockBlockDartCallRefCountTest();
      await doGC();
      expect(blockRetainCount(inputBlock), 0);
      expect(blockRetainCount(blockBlock), 0);
      expect(blockRetainCount(outputBlock), 0);
    });

    Future<(Pointer<ObjCBlockImpl>, Pointer<ObjCBlockImpl>)>
        nativeBlockBlockObjCCallRefCountTest() async {
      final blockBlock = BlockTester.newBlockBlock_(7);
      final outputBlock = BlockTester.newBlock_withMult_(blockBlock, 2);
      expect(outputBlock(1), 14);
      await doGC();

      expect(blockRetainCount(blockBlock.ref.pointer), 1);
      expect(blockRetainCount(outputBlock.ref.pointer), 1);
      return (blockBlock.ref.pointer, outputBlock.ref.pointer);
    }

    test('Calling a native block block from ObjC has correct ref counting',
        () async {
      final (blockBlock, outputBlock) = await nativeBlockBlockObjCCallRefCountTest();
      await doGC();
      expect(blockRetainCount(blockBlock), 0);
      expect(blockRetainCount(outputBlock), 0);
    });

    (Pointer<Int32>, Pointer<Int32>) objectBlockRefCountTest(Allocator alloc) {
      final pool = lib.objc_autoreleasePoolPush();
      final inputCounter = alloc<Int32>();
      final outputCounter = alloc<Int32>();
      inputCounter.value = 0;
      outputCounter.value = 0;

      final block = ObjectBlock.fromFunction((DummyObject x) {
        return DummyObject.newWithCounter_(outputCounter);
      });

      final inputObj = DummyObject.newWithCounter_(inputCounter);
      final outputObj = block(inputObj);
      expect(inputCounter.value, 1);
      expect(outputCounter.value, 1);

      lib.objc_autoreleasePoolPop(pool);
      return (inputCounter, outputCounter);
    }

    test('Objects received and returned by blocks have correct ref counts', () {
      using((Arena arena) async {
        final (inputCounter, outputCounter) = objectBlockRefCountTest(arena);
        await doGC();
        expect(inputCounter.value, 0);
        expect(outputCounter.value, 0);
      });
    });

    (Pointer<Int32>, Pointer<Int32>) objectNativeBlockRefCountTest(
        Allocator alloc) {
      final pool = lib.objc_autoreleasePoolPush();
      final inputCounter = alloc<Int32>();
      final outputCounter = alloc<Int32>();
      inputCounter.value = 0;
      outputCounter.value = 0;

      final block = ObjectBlock.fromFunction((DummyObject x) {
        x.setCounter_(inputCounter);
        return DummyObject.newWithCounter_(outputCounter);
      });

      final outputObj = BlockTester.callObjectBlock_(block);
      expect(inputCounter.value, 1);
      expect(outputCounter.value, 1);

      lib.objc_autoreleasePoolPop(pool);
      return (inputCounter, outputCounter);
    }

    test(
        'Objects received and returned by native blocks have correct ref counts',
        () {
      using((Arena arena) async {
        final (inputCounter, outputCounter) =
            objectNativeBlockRefCountTest(arena);
        await doGC();
        await Future<void>.delayed(Duration.zero); // Let dispose message arrive
        await doGC();

        expect(inputCounter.value, 0);
        expect(outputCounter.value, 0);
      });
    });

    Future<(Pointer<ObjCBlockImpl>, Pointer<ObjCBlockImpl>)>
        listenerBlockArgumentRetentionTest() async {
      final hasRun = Completer<void>();
      late ObjCBlock<Int32 Function(Int32)> inputBlock;
      final blockBlock =
          ListenerBlock.listener((ObjCBlock<Int32 Function(Int32)> intBlock) {
        expect(blockRetainCount(intBlock.ref.pointer), 1);
        inputBlock = intBlock;
        hasRun.complete();
      });

      final thread = BlockTester.callWithBlockOnNewThread_(blockBlock);
      thread.start();

      await hasRun.future;
      expect(inputBlock(123), 12300);
      thread.ref.release();
      await doGC();

      expect(blockRetainCount(inputBlock.ref.pointer), 1);
      expect(blockRetainCount(blockBlock.ref.pointer), 1);
      return (inputBlock.ref.pointer, blockBlock.ref.pointer);
    }

    test('Listener block arguments are not prematurely destroyed', () async {
      // https://github.com/dart-lang/native/issues/835
      final (inputBlock, blockBlock) =
          await listenerBlockArgumentRetentionTest();
      await doGC();
      await Future<void>.delayed(Duration.zero); // Let dispose message arrive.
      await doGC();

      expect(blockRetainCount(inputBlock), 0);
      expect(blockRetainCount(blockBlock), 0);
    });

    test('Block fields have sensible values', () {
      final block = IntBlock.fromFunction(makeAdder(4000));
      final blockPtr = block.ref.pointer;
      expect(blockPtr.ref.isa, isNot(0));
      expect(blockPtr.ref.flags, isNot(0)); // Set by Block_copy.
      expect(blockPtr.ref.reserved, 0);
      expect(blockPtr.ref.invoke, isNot(0));
      expect(blockPtr.ref.target, isNot(0));
      final descPtr = blockPtr.ref.descriptor;
      expect(descPtr.ref.reserved, 0);
      expect(descPtr.ref.size, isNot(0));
      expect(descPtr.ref.copy_helper, nullptr);
      expect(descPtr.ref.dispose_helper, isNot(nullptr));
      expect(descPtr.ref.signature, nullptr);
    });

    test('Block trampoline args converted to id', () {
      final objCBindings =
          File('test/native_objc_test/block_bindings.m').readAsStringSync();

      // Objects are converted to id.
      expect(objCBindings, isNot(contains('NSObject')));
      expect(objCBindings, isNot(contains('NSString')));
      expect(objCBindings, contains('id'));

      // Blocks are also converted to id. Note: (^) is part of a block type.
      expect(objCBindings, isNot(contains('(^)')));

      // Other types, like structs, are still there.
      expect(objCBindings, contains('Vec2'));
      expect(objCBindings, contains('Vec4'));
    });
  });
}

int _add100(int x) {
  return x + 100;
}
