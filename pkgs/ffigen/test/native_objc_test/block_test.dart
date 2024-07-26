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

void main() {
  group('Blocks', () {
    setUpAll(() {
      // TODO(https://github.com/dart-lang/native/issues/1068): Remove this.
      DynamicLibrary.open('../objective_c/test/objective_c.dylib');
      final dylib = File('test/native_objc_test/block_test.dylib');
      verifySetupFile(dylib);
      DynamicLibrary.open(dylib.absolute.path);

      generateBindingsForCoverage('block');
    });

    test('BlockTester is working', () {
      // This doesn't test any Block functionality, just that the BlockTester
      // itself is working correctly.
      final blockTester = BlockTester.makeFromMultiplier_(10);
      expect(blockTester.call_(123), 1230);
      final intBlock = blockTester.getBlock();
      final blockTester2 = BlockTester.makeFromBlock_(intBlock);
      blockTester2.pokeBlock();
      expect(blockTester2.call_(456), 4560);
    });

    test('Block from function pointer', () {
      final block =
          DartIntBlock.fromFunctionPointer(Pointer.fromFunction(_add100, 999));
      final blockTester = BlockTester.makeFromBlock_(block);
      blockTester.pokeBlock();
      expect(blockTester.call_(123), 223);
      expect(block(123), 223);
    });

    int Function(int) makeAdder(int addTo) {
      return (int x) => addTo + x;
    }

    test('Block from function', () {
      final block = DartIntBlock.fromFunction(makeAdder(4000));
      final blockTester = BlockTester.makeFromBlock_(block);
      blockTester.pokeBlock();
      expect(blockTester.call_(123), 4123);
      expect(block(123), 4123);
    });

    test('Listener block same thread', () async {
      final hasRun = Completer<void>();
      int value = 0;
      final block = DartVoidBlock.listener(() {
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
      final block = DartVoidBlock.listener(() {
        value = 123;
        hasRun.complete();
      });

      final thread = BlockTester.callOnNewThread_(block);
      thread.start();

      await hasRun.future;
      expect(value, 123);
    });

    test('Float block', () {
      final block = DartFloatBlock.fromFunction((double x) {
        return x + 4.56;
      });
      expect(block(1.23), closeTo(5.79, 1e-6));
      expect(BlockTester.callFloatBlock_(block), closeTo(5.79, 1e-6));
    });

    test('Double block', () {
      final block = DartDoubleBlock.fromFunction((double x) {
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
        final block = DartVec4Block.fromFunction((Vec4 v) {
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
      final block = DartObjectBlock.fromFunction((DummyObject x) {
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
      expect(result2.pointer, isNot(nullptr));
      expect(isCalled, isTrue);
    });

    test('Nullable object block', () {
      bool isCalled = false;
      final block = DartNullableObjectBlock.fromFunction((DummyObject? x) {
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

    test('Object listener block', () async {
      final hasRun = Completer<void>();
      final block = DartObjectListenerBlock.listener((DummyObject x) {
        expect(x, isNotNull);
        hasRun.complete();
      });

      BlockTester.callObjectListener_(block);
      await hasRun.future;
    });

    test('Nullable listener block', () async {
      final hasRun = Completer<void>();
      final block = DartNullableListenerBlock.listener((DummyObject? x) {
        expect(x, isNull);
        hasRun.complete();
      });

      BlockTester.callNullableListener_(block);
      await hasRun.future;
    });

    test('Struct listener block', () async {
      final hasRun = Completer<void>();
      final block = DartStructListenerBlock.listener(
          (Vec2 vec2, Vec4 vec4, NSObject dummy) {
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
      final block = DartNSStringListenerBlock.listener((NSString s) {
        expect(s.toString(), "Foo 123");
        hasRun.complete();
      });

      BlockTester.callNSStringListener_x_(block, 123);
      await hasRun.future;
    });

    test('No trampoline listener block', () async {
      final hasRun = Completer<void>();
      final block = DartNoTrampolineListenerBlock.listener(
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
      final blockBlock = DartBlockBlock.fromFunction((DartIntBlock intBlock) {
        return DartIntBlock.fromFunction((int x) {
          return 3 * intBlock(x);
        });
      });

      final intBlock = DartIntBlock.fromFunction((int x) {
        return 5 * x;
      });
      final result1 = blockBlock(intBlock);
      expect(result1(1), 15);

      final result2 = BlockTester.newBlock_withMult_(blockBlock, 2);
      expect(result2(1), 6);
    });

    test('Native block block', () {
      final blockBlock = BlockTester.newBlockBlock_(7);

      final intBlock = DartIntBlock.fromFunction((int x) {
        return 5 * x;
      });
      final result1 = blockBlock(intBlock);
      expect(result1(1), 35);

      final result2 = BlockTester.newBlock_withMult_(blockBlock, 2);
      expect(result2(1), 14);
    });

    Pointer<ObjCBlock> funcPointerBlockRefCountTest() {
      final block =
          DartIntBlock.fromFunctionPointer(Pointer.fromFunction(_add100, 999));
      expect(
          internal_for_testing.blockHasRegisteredClosure(block.pointer), false);
      expect(blockRetainCount(block.pointer), 1);
      return block.pointer;
    }

    test('Function pointer block ref counting', () {
      final rawBlock = funcPointerBlockRefCountTest();
      doGC();
      expect(blockRetainCount(rawBlock), 0);
    });

    Pointer<ObjCBlock> funcBlockRefCountTest() {
      final block = DartIntBlock.fromFunction(makeAdder(4000));
      expect(
          internal_for_testing.blockHasRegisteredClosure(block.pointer), true);
      expect(blockRetainCount(block.pointer), 1);
      return block.pointer;
    }

    test('Function block ref counting', () async {
      final rawBlock = funcBlockRefCountTest();
      doGC();
      await Future<void>.delayed(Duration.zero); // Let dispose message arrive.
      expect(blockRetainCount(rawBlock), 0);
      expect(internal_for_testing.blockHasRegisteredClosure(rawBlock.cast()),
          false);
    });

    Pointer<ObjCBlock> blockManualRetainRefCountTest() {
      final block = DartIntBlock.fromFunction(makeAdder(4000));
      expect(
          internal_for_testing.blockHasRegisteredClosure(block.pointer), true);
      expect(blockRetainCount(block.pointer), 1);
      final rawBlock = block.retainAndReturnPointer();
      expect(blockRetainCount(rawBlock), 2);
      return rawBlock;
    }

    int blockManualRetainRefCountTest2(Pointer<ObjCBlock> rawBlock) {
      final block = DartIntBlock.castFromPointer(rawBlock.cast(),
          retain: false, release: true);
      return blockRetainCount(block.pointer);
    }

    test('Block ref counting with manual retain and release', () async {
      final rawBlock = blockManualRetainRefCountTest();
      doGC();
      expect(blockRetainCount(rawBlock), 1);
      expect(blockManualRetainRefCountTest2(rawBlock), 1);
      doGC();
      await Future<void>.delayed(Duration.zero); // Let dispose message arrive.
      expect(blockRetainCount(rawBlock), 0);
      expect(internal_for_testing.blockHasRegisteredClosure(rawBlock.cast()),
          false);
    });

    (Pointer<ObjCBlock>, Pointer<ObjCBlock>, Pointer<ObjCBlock>)
        blockBlockDartCallRefCountTest() {
      final inputBlock = DartIntBlock.fromFunction((int x) {
        return 5 * x;
      });
      final blockBlock = DartBlockBlock.fromFunction((DartIntBlock intBlock) {
        return DartIntBlock.fromFunction((int x) {
          return 3 * intBlock(x);
        });
      });
      final outputBlock = blockBlock(inputBlock);
      expect(outputBlock(1), 15);
      doGC();

      // One reference held by inputBlock object, another bound to the
      // outputBlock lambda.
      expect(blockRetainCount(inputBlock.pointer), 2);
      expect(
          internal_for_testing
              .blockHasRegisteredClosure(inputBlock.pointer.cast()),
          true);

      expect(blockRetainCount(blockBlock.pointer), 1);
      expect(
          internal_for_testing
              .blockHasRegisteredClosure(blockBlock.pointer.cast()),
          true);
      expect(blockRetainCount(outputBlock.pointer), 1);
      expect(
          internal_for_testing
              .blockHasRegisteredClosure(outputBlock.pointer.cast()),
          true);
      return (inputBlock.pointer, blockBlock.pointer, outputBlock.pointer);
    }

    test('Calling a block block from Dart has correct ref counting', () async {
      final (inputBlock, blockBlock, outputBlock) =
          blockBlockDartCallRefCountTest();
      doGC();
      await Future<void>.delayed(Duration.zero); // Let dispose message arrive.
      doGC();
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

    (Pointer<ObjCBlock>, Pointer<ObjCBlock>, Pointer<ObjCBlock>)
        blockBlockObjCCallRefCountTest() {
      late Pointer<ObjCBlock> inputBlock;
      final blockBlock = DartBlockBlock.fromFunction((DartIntBlock intBlock) {
        inputBlock = intBlock.pointer;
        return DartIntBlock.fromFunction((int x) {
          return 3 * intBlock(x);
        });
      });
      final outputBlock = BlockTester.newBlock_withMult_(blockBlock, 2);
      expect(outputBlock(1), 6);
      doGC();

      expect(blockRetainCount(inputBlock), 1);
      expect(internal_for_testing.blockHasRegisteredClosure(inputBlock.cast()),
          false);
      expect(blockRetainCount(blockBlock.pointer), 1);
      expect(
          internal_for_testing
              .blockHasRegisteredClosure(blockBlock.pointer.cast()),
          true);
      expect(blockRetainCount(outputBlock.pointer), 1);
      expect(
          internal_for_testing
              .blockHasRegisteredClosure(outputBlock.pointer.cast()),
          true);
      return (inputBlock, blockBlock.pointer, outputBlock.pointer);
    }

    test('Calling a block block from ObjC has correct ref counting', () async {
      final (inputBlock, blockBlock, outputBlock) =
          blockBlockObjCCallRefCountTest();
      doGC();
      await Future<void>.delayed(Duration.zero); // Let dispose message arrive.
      doGC();
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

    (Pointer<ObjCBlock>, Pointer<ObjCBlock>, Pointer<ObjCBlock>)
        nativeBlockBlockDartCallRefCountTest() {
      final inputBlock = DartIntBlock.fromFunction((int x) {
        return 5 * x;
      });
      final blockBlock = BlockTester.newBlockBlock_(7);
      final outputBlock = blockBlock(inputBlock);
      expect(outputBlock(1), 35);
      doGC();

      // One reference held by inputBlock object, another held internally by the
      // ObjC implementation of the blockBlock.
      expect(blockRetainCount(inputBlock.pointer), 2);

      expect(blockRetainCount(blockBlock.pointer), 1);
      expect(blockRetainCount(outputBlock.pointer), 1);
      return (inputBlock.pointer, blockBlock.pointer, outputBlock.pointer);
    }

    test('Calling a native block block from Dart has correct ref counting', () {
      final (inputBlock, blockBlock, outputBlock) =
          nativeBlockBlockDartCallRefCountTest();
      doGC();
      expect(blockRetainCount(inputBlock), 0);
      expect(blockRetainCount(blockBlock), 0);
      expect(blockRetainCount(outputBlock), 0);
    });

    (Pointer<ObjCBlock>, Pointer<ObjCBlock>)
        nativeBlockBlockObjCCallRefCountTest() {
      final blockBlock = BlockTester.newBlockBlock_(7);
      final outputBlock = BlockTester.newBlock_withMult_(blockBlock, 2);
      expect(outputBlock(1), 14);
      doGC();

      expect(blockRetainCount(blockBlock.pointer), 1);
      expect(blockRetainCount(outputBlock.pointer), 1);
      return (blockBlock.pointer, outputBlock.pointer);
    }

    test('Calling a native block block from ObjC has correct ref counting', () {
      final (blockBlock, outputBlock) = nativeBlockBlockObjCCallRefCountTest();
      doGC();
      expect(blockRetainCount(blockBlock), 0);
      expect(blockRetainCount(outputBlock), 0);
    });

    (Pointer<Int32>, Pointer<Int32>) objectBlockRefCountTest(Allocator alloc) {
      final inputCounter = alloc<Int32>();
      final outputCounter = alloc<Int32>();
      inputCounter.value = 0;
      outputCounter.value = 0;

      final block = DartObjectBlock.fromFunction((DummyObject x) {
        return DummyObject.newWithCounter_(outputCounter);
      });

      final inputObj = DummyObject.newWithCounter_(inputCounter);
      final outputObj = block(inputObj);
      expect(inputCounter.value, 1);
      expect(outputCounter.value, 1);

      return (inputCounter, outputCounter);
    }

    test('Objects received and returned by blocks have correct ref counts', () {
      using((Arena arena) {
        final (inputCounter, outputCounter) = objectBlockRefCountTest(arena);
        doGC();
        expect(inputCounter.value, 0);
        expect(outputCounter.value, 0);
      });
    });

    (Pointer<Int32>, Pointer<Int32>) objectNativeBlockRefCountTest(
        Allocator alloc) {
      final inputCounter = alloc<Int32>();
      final outputCounter = alloc<Int32>();
      inputCounter.value = 0;
      outputCounter.value = 0;

      final block = DartObjectBlock.fromFunction((DummyObject x) {
        x.setCounter_(inputCounter);
        return DummyObject.newWithCounter_(outputCounter);
      });

      final outputObj = BlockTester.callObjectBlock_(block);
      expect(inputCounter.value, 1);
      expect(outputCounter.value, 1);

      return (inputCounter, outputCounter);
    }

    test(
        'Objects received and returned by native blocks have correct ref counts',
        () {
      using((Arena arena) async {
        final (inputCounter, outputCounter) =
            objectNativeBlockRefCountTest(arena);
        doGC();
        await Future<void>.delayed(Duration.zero); // Let dispose message arrive
        doGC();

        expect(inputCounter.value, 0);
        expect(outputCounter.value, 0);
      });
    });

    Future<(Pointer<ObjCBlock>, Pointer<ObjCBlock>)>
        listenerBlockArgumentRetentionTest() async {
      final hasRun = Completer<void>();
      late DartIntBlock inputBlock;
      final blockBlock = DartListenerBlock.listener((DartIntBlock intBlock) {
        expect(blockRetainCount(intBlock.pointer), 1);
        inputBlock = intBlock;
        hasRun.complete();
      });

      final thread = BlockTester.callWithBlockOnNewThread_(blockBlock);
      thread.start();

      await hasRun.future;
      expect(inputBlock(123), 12300);
      doGC();

      expect(blockRetainCount(inputBlock.pointer), 1);
      expect(blockRetainCount(blockBlock.pointer), 1);
      return (inputBlock.pointer, blockBlock.pointer);
    }

    test('Listener block arguments are not prematurely destroyed', () async {
      // https://github.com/dart-lang/native/issues/835
      final (inputBlock, blockBlock) =
          await listenerBlockArgumentRetentionTest();
      doGC();
      await Future<void>.delayed(Duration.zero); // Let dispose message arrive.
      doGC();

      expect(blockRetainCount(inputBlock), 0);
      expect(blockRetainCount(blockBlock), 0);
    });

    test('Block fields have sensible values', () {
      final block = DartIntBlock.fromFunction(makeAdder(4000));
      final blockPtr = block.pointer;
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
  });
}

int _add100(int x) {
  return x + 100;
}
