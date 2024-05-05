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

// The generated block names are stable but verbose, so typedef them.
typedef IntBlock = ObjCBlock_Int32_Int32;
typedef FloatBlock = ObjCBlock_ffiFloat_ffiFloat;
typedef DoubleBlock = ObjCBlock_ffiDouble_ffiDouble;
typedef Vec4Block = ObjCBlock_Vec4_Vec4;
typedef VoidBlock = ObjCBlock_ffiVoid;
typedef ObjectBlock = ObjCBlock_DummyObject_DummyObject;
typedef NullableObjectBlock = ObjCBlock_DummyObject_DummyObject1;
typedef BlockBlock = ObjCBlock_Int32Int32_Int32Int32;

void main() {
  group('Blocks', () {
    setUpAll(() {
      logWarnings();
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
          IntBlock.fromFunctionPointer(Pointer.fromFunction(_add100, 999));
      final blockTester = BlockTester.makeFromBlock_(block);
      blockTester.pokeBlock();
      expect(blockTester.call_(123), 223);
      expect(block(123), 223);
    });

    int Function(int) makeAdder(int addTo) {
      return (int x) => addTo + x;
    }

    test('Block from function', () {
      final block = IntBlock.fromFunction(makeAdder(4000));
      final blockTester = BlockTester.makeFromBlock_(block);
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
      expect(result2.pointer, isNot(nullptr));
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

    test('Block block', () {
      final blockBlock = BlockBlock.fromFunction((IntBlock intBlock) {
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

    Pointer<ObjCBlock> funcPointerBlockRefCountTest() {
      final block =
          IntBlock.fromFunctionPointer(Pointer.fromFunction(_add100, 999));
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
      final block = IntBlock.fromFunction(makeAdder(4000));
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
      final block = IntBlock.fromFunction(makeAdder(4000));
      expect(
          internal_for_testing.blockHasRegisteredClosure(block.pointer), true);
      expect(blockRetainCount(block.pointer), 1);
      final rawBlock = block.retainAndReturnPointer();
      expect(blockRetainCount(rawBlock), 2);
      return rawBlock;
    }

    int blockManualRetainRefCountTest2(Pointer<ObjCBlock> rawBlock) {
      final block = IntBlock.castFromPointer(rawBlock.cast(),
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
      final inputBlock = IntBlock.fromFunction((int x) {
        return 5 * x;
      });
      final blockBlock = BlockBlock.fromFunction((IntBlock intBlock) {
        return IntBlock.fromFunction((int x) {
          return 3 * intBlock(x);
        });
      });
      final outputBlock = blockBlock(inputBlock);
      expect(outputBlock(1), 15);
      doGC();

      // One reference held by inputBlock object, another bound to the
      // outputBlock lambda.
      expect(blockRetainCount(inputBlock.pointer), 2);

      expect(blockRetainCount(blockBlock.pointer), 1);
      expect(blockRetainCount(outputBlock.pointer), 1);
      return (inputBlock.pointer, blockBlock.pointer, outputBlock.pointer);
    }

    test('Calling a block block from Dart has correct ref counting', () {
      final (inputBlock, blockBlock, outputBlock) =
          blockBlockDartCallRefCountTest();
      doGC();

      // This leaks because block functions aren't cleaned up at the moment.
      // TODO(https://github.com/dart-lang/ffigen/issues/428): Fix this leak.
      expect(blockRetainCount(inputBlock), 1);

      expect(blockRetainCount(blockBlock), 0);
      expect(blockRetainCount(outputBlock), 0);
    });

    (Pointer<ObjCBlock>, Pointer<ObjCBlock>, Pointer<ObjCBlock>)
        blockBlockObjCCallRefCountTest() {
      late Pointer<ObjCBlock> inputBlock;
      final blockBlock = BlockBlock.fromFunction((IntBlock intBlock) {
        inputBlock = intBlock.pointer;
        return IntBlock.fromFunction((int x) {
          return 3 * intBlock(x);
        });
      });
      final outputBlock = BlockTester.newBlock_withMult_(blockBlock, 2);
      expect(outputBlock(1), 6);
      doGC();

      expect(blockRetainCount(inputBlock), 2);
      expect(blockRetainCount(blockBlock.pointer), 1);
      expect(blockRetainCount(outputBlock.pointer), 1);
      return (inputBlock, blockBlock.pointer, outputBlock.pointer);
    }

    test('Calling a block block from ObjC has correct ref counting', () {
      final (inputBlock, blockBlock, outputBlock) =
          blockBlockObjCCallRefCountTest();
      doGC();

      // This leaks because block functions aren't cleaned up at the moment.
      // TODO(https://github.com/dart-lang/ffigen/issues/428): Fix this leak.
      expect(blockRetainCount(inputBlock), 2);

      expect(blockRetainCount(blockBlock), 0);
      expect(blockRetainCount(outputBlock), 0);
    });

    (Pointer<ObjCBlock>, Pointer<ObjCBlock>, Pointer<ObjCBlock>)
        nativeBlockBlockDartCallRefCountTest() {
      final inputBlock = IntBlock.fromFunction((int x) {
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

      final block = ObjectBlock.fromFunction((DummyObject x) {
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

      final block = ObjectBlock.fromFunction((DummyObject x) {
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
      using((Arena arena) {
        final (inputCounter, outputCounter) =
            objectNativeBlockRefCountTest(arena);
        doGC();

        // This leaks because block functions aren't cleaned up at the moment.
        // TODO(https://github.com/dart-lang/ffigen/issues/428): Fix this leak.
        expect(inputCounter.value, 1);

        expect(outputCounter.value, 0);
      });
    });

    test('Block fields have sensible values', () {
      final block = IntBlock.fromFunction(makeAdder(4000));
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
