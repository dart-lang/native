// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:objective_c/objective_c.dart';
import 'package:objective_c/src/internal.dart'
    as internal_for_testing
    show blockHasRegisteredClosure;
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../test_utils.dart';
import 'block_test_bindings.dart';
import 'util.dart';

typedef IntBlock = ObjCBlock_Int32_Int32;
typedef VoidBlock = ObjCBlock_ffiVoid;
typedef ListenerBlock = ObjCBlock_ffiVoid_IntBlock;
typedef FloatBlock = ObjCBlock_ffiFloat_ffiFloat;
typedef DoubleBlock = ObjCBlock_ffiDouble_ffiDouble;
typedef Vec4Block = ObjCBlock_Vec4_Vec4;
typedef SelectorBlock = ObjCBlock_ffiVoid_objcObjCSelector;
typedef ObjectBlock = ObjCBlock_DummyObject_DummyObject;
typedef NullableObjectBlock = ObjCBlock_DummyObject_DummyObject$1;
typedef NullableStringBlock = ObjCBlock_NSString_NSString;
typedef ObjectListenerBlock = ObjCBlock_ffiVoid_DummyObject;
typedef NullableListenerBlock = ObjCBlock_ffiVoid_DummyObject$1;
typedef StructListenerBlock = ObjCBlock_ffiVoid_Vec2_Vec4_NSObject;
typedef NSStringListenerBlock = ObjCBlock_ffiVoid_NSString;
typedef NoTrampolineListenerBlock = ObjCBlock_ffiVoid_Int32_Vec4_ffiChar;
typedef BlockBlock = ObjCBlock_IntBlock_IntBlock;
typedef IntPtrBlock = ObjCBlock_ffiVoid_Int32$1;
typedef ResultBlock = ObjCBlock_ffiVoid_Int32;

bool get hasIsolateOwnershipApi =>
    DynamicLibrary.process().providesSymbol('Dart_SetCurrentThreadOwnsIsolate');
void setCurrentThreadOwnsIsolate() =>
    DynamicLibrary.process().lookupFunction<Void Function(), void Function()>(
      'Dart_SetCurrentThreadOwnsIsolate',
    )();

void main() {
  group('Blocks', () {
    setUpAll(() {
      BlockTester.setup(NativeApi.initializeApiDLData);
    });

    test('BlockTester is working', () {
      // This doesn't test any Block functionality, just that the BlockTester
      // itself is working correctly.
      final blockTester = BlockTester.newFromMultiplier(10);
      expect(blockTester.call(123), 1230);
      final intBlock = blockTester.getBlock();
      final blockTester2 = BlockTester.newFromBlock(intBlock);
      blockTester2.pokeBlock();
      expect(blockTester2.call(456), 4560);
    });

    test('Block from function pointer', () {
      final block = IntBlock.fromFunctionPointer(
        Pointer.fromFunction(_add100, 999),
      );
      final blockTester = BlockTester.newFromBlock(block);
      blockTester.pokeBlock();
      expect(blockTester.call(123), 223);
      expect(block(123), 223);
    });

    int Function(int) makeAdder(int addTo) {
      return (int x) => addTo + x;
    }

    test('Block from function', () {
      final block = IntBlock.fromFunction(makeAdder(4000));
      final blockTester = BlockTester.newFromBlock(block);
      blockTester.pokeBlock();
      expect(blockTester.call(123), 4123);
      expect(block(123), 4123);
    });

    test('Listener block same thread', () async {
      final hasRun = Completer<void>();
      int value = 0;
      final block = VoidBlock.listener(() {
        value = 123;
        hasRun.complete();
      });

      BlockTester.callOnSameThread(block);

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

      final thread = BlockTester.callOnNewThread(block);
      thread.start();

      await hasRun.future;
      expect(value, 123);
    });

    void waitSync(Duration d) {
      final t = Stopwatch();
      t.start();
      while (t.elapsed < d) {
        // Waiting...
      }
    }

    test('Blocking block same thread', () {
      int value = 0;
      final block = VoidBlock.blocking(() {
        waitSync(Duration(milliseconds: 100));
        value = 123;
      });
      BlockTester.callOnSameThread(block);
      expect(value, 123);
    });

    test('Blocking block new thread', () async {
      final block = IntPtrBlock.blocking((Pointer<Int32> result) {
        waitSync(Duration(milliseconds: 100));
        result.value = 123456;
      });
      final resultCompleter = Completer<int>();
      final resultBlock = ResultBlock.listener((int result) {
        resultCompleter.complete(result);
      });
      BlockTester.blockingBlockTest(block, resultBlock: resultBlock);
      expect(await resultCompleter.future, 123456);
    });

    test('Blocking block same thread throws', () {
      int value = 0;
      final block = VoidBlock.blocking(() {
        value = 123;
        throw "Hello";
      });
      BlockTester.callOnSameThread(block);
      expect(value, 123);
    });

    test('Blocking block new thread throws', () async {
      final block = IntPtrBlock.blocking((Pointer<Int32> result) {
        result.value = 123456;
        throw "Hello";
      });
      final resultCompleter = Completer<int>();
      final resultBlock = ResultBlock.listener((int result) {
        resultCompleter.complete(result);
      });
      BlockTester.blockingBlockTest(block, resultBlock: resultBlock);
      expect(await resultCompleter.future, 123456);
    });

    test('Blocking block manual invocation', () {
      int value = 0;
      final block = VoidBlock.blocking(() {
        waitSync(Duration(milliseconds: 100));
        value = 123;
      });
      block();
      expect(value, 123);
    });

    test('Float block', () {
      final block = FloatBlock.fromFunction((double x) {
        return x + 4.56;
      });
      expect(block(1.23), closeTo(5.79, 1e-6));
      expect(BlockTester.callFloatBlock(block), closeTo(5.79, 1e-6));
    });

    test('Double block', () {
      final block = DoubleBlock.fromFunction((double x) {
        return x + 4.56;
      });
      expect(block(1.23), closeTo(5.79, 1e-6));
      expect(BlockTester.callDoubleBlock(block), closeTo(5.79, 1e-6));
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

        final result2 = BlockTester.callVec4Block(block);
        expect(result2.x, 3.4);
        expect(result2.y, 5.6);
        expect(result2.z, 7.8);
        expect(result2.w, 1.2);
      });
    });

    test('Selector block', () {
      late String sel;
      final block = SelectorBlock.fromFunction((Pointer<ObjCSelector> x) {
        sel = x.toDartString();
      });

      block('Hello'.toSelector());
      expect(sel, 'Hello');

      BlockTester.callSelectorBlock(block);
      expect(sel, 'Select');
    });

    test('Object block', () {
      bool isCalled = false;
      final block = ObjectBlock.fromFunction((DummyObject x) {
        isCalled = true;
        return x;
      });

      final obj = DummyObject();
      final result1 = block(obj);
      expect(result1, obj);
      expect(isCalled, isTrue);

      isCalled = false;
      final result2 = BlockTester.callObjectBlock(block);
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

      final obj = DummyObject();
      final result1 = block(obj);
      expect(result1, obj);
      expect(isCalled, isTrue);

      isCalled = false;
      final result2 = block(null);
      expect(result2, isNull);
      expect(isCalled, isTrue);

      isCalled = false;
      final result3 = BlockTester.callNullableObjectBlock(block);
      expect(result3, isNull);
      expect(isCalled, isTrue);
    });

    test('Nullable string block', () {
      // Regression test for https://github.com/dart-lang/native/issues/1537.
      final block = NullableStringBlock.fromFunction(
        (NSString? x) => '${x?.toDartString()} Cat'.toNSString(),
      );

      final result1 = block('Dog'.toNSString());
      expect(result1?.toDartString(), 'Dog Cat');

      final result2 = block(null);
      expect(result2?.toDartString(), 'null Cat');

      final result3 = BlockTester.callNullableStringBlock(block);
      expect(result3?.toDartString(), 'Lizard Cat');
    });

    test('Object listener block', () async {
      final hasRun = Completer<void>();
      final block = ObjectListenerBlock.listener((DummyObject x) {
        expect(x, isNotNull);
        hasRun.complete();
      });

      BlockTester.callObjectListener(block);
      await hasRun.future;
    });

    test('Nullable listener block', () async {
      final hasRun = Completer<void>();
      final block = NullableListenerBlock.listener((DummyObject? x) {
        expect(x, isNull);
        hasRun.complete();
      });

      BlockTester.callNullableListener(block);
      await hasRun.future;
    });

    test('Struct listener block', () async {
      final hasRun = Completer<void>();
      final block = StructListenerBlock.listener((
        Vec2 vec2,
        Vec4 vec4,
        NSObject dummy,
      ) {
        expect(vec2.x, 100);
        expect(vec2.y, 200);

        expect(vec4.x, 1.2);
        expect(vec4.y, 3.4);
        expect(vec4.z, 5.6);
        expect(vec4.w, 7.8);

        expect(dummy, isNotNull);

        hasRun.complete();
      });

      BlockTester.callStructListener(block);
      await hasRun.future;
    });

    test('NSString listener block', () async {
      final hasRun = Completer<void>();
      final block = NSStringListenerBlock.listener((NSString s) {
        expect(s.toDartString(), "Foo 123");
        hasRun.complete();
      });

      BlockTester.callNSStringListener(block, x: 123);
      await hasRun.future;
    });

    test('No trampoline listener block', () async {
      final hasRun = Completer<void>();
      final block = NoTrampolineListenerBlock.listener((
        int x,
        Vec4 vec4,
        Pointer<Char> charPtr,
      ) {
        expect(x, 123);

        expect(vec4.x, 1.2);
        expect(vec4.y, 3.4);
        expect(vec4.z, 5.6);
        expect(vec4.w, 7.8);

        expect(charPtr.cast<Utf8>().toDartString(), "Hello World");

        hasRun.complete();
      });

      BlockTester.callNoTrampolineListener(block);
      await hasRun.future;
    });

    test('Block block', () {
      final blockBlock = BlockBlock.fromFunction((
        ObjCBlock<Int32 Function(Int32)> intBlock,
      ) {
        return IntBlock.fromFunction((int x) {
          return 3 * intBlock(x);
        });
      });

      final intBlock = IntBlock.fromFunction((int x) {
        return 5 * x;
      });
      final result1 = blockBlock(intBlock);
      expect(result1(1), 15);

      final result2 = BlockTester.newBlock(blockBlock, withMult: 2);
      expect(result2(1), 6);
    });

    test('Native block block', () {
      final blockBlock = BlockTester.newBlockBlock(7);

      final intBlock = IntBlock.fromFunction((int x) {
        return 5 * x;
      });
      final result1 = blockBlock(intBlock);
      expect(result1(1), 35);

      final result2 = BlockTester.newBlock(blockBlock, withMult: 2);
      expect(result2(1), 14);
    });

    @pragma('vm:never-inline')
    void funcPointerBlockRefCountTest(ReferenceTracker tracker) {
      final block = IntBlock.fromFunctionPointer(
        Pointer.fromFunction(_add100, 999),
      );
      expect(
        internal_for_testing.blockHasRegisteredClosure(block.ref.pointer),
        false,
      );
      tracker.trackBlock(block);
      expect(tracker.isAlive, true);
    }

    test('Function pointer block ref counting', () {
      using((Arena arena) {
        final tracker = ReferenceTracker(arena);
        funcPointerBlockRefCountTest(tracker);
        doGC();
        expect(tracker.isAlive, false);
      });
    }, skip: !canDoGC);

    @pragma('vm:never-inline')
    void funcBlockRefCountTest(ReferenceTracker tracker) {
      final block = IntBlock.fromFunction(makeAdder(4000));
      expect(
        internal_for_testing.blockHasRegisteredClosure(block.ref.pointer),
        true,
      );
      tracker.trackBlock(block);
      expect(tracker.isAlive, true);
    }

    test('Function block ref counting', () async {
      await using((arena) async {
        final tracker = ReferenceTracker(arena);
        funcBlockRefCountTest(tracker);
        doGC();
        await Future<void>.delayed(Duration.zero);
        doGC();
        expect(tracker.isAlive, false);
        expect(
          internal_for_testing.blockHasRegisteredClosure(tracker.host.cast()),
          false,
        );
      });
    }, skip: !canDoGC);

    @pragma('vm:never-inline')
    Pointer<ObjCBlockImpl> blockManualRetainRefCountTest(
      ReferenceTracker tracker,
    ) {
      final block = IntBlock.fromFunction(makeAdder(4000));
      expect(
        internal_for_testing.blockHasRegisteredClosure(block.ref.pointer),
        true,
      );
      tracker.trackBlock(block);
      expect(tracker.isAlive, true);
      return block.ref.retainAndReturnPointer();
    }

    @pragma('vm:never-inline')
    void blockManualRetainRefCountTest2(Pointer<ObjCBlockImpl> rawBlock) {
      final block = IntBlock.fromPointer(
        rawBlock.cast(),
        retain: false,
        release: true,
      );
    }

    test('Block ref counting with manual retain and release', () async {
      await using((arena) async {
        final tracker = ReferenceTracker(arena);
        final rawBlock = blockManualRetainRefCountTest(tracker);
        doGC();
        expect(tracker.isAlive, true);

        blockManualRetainRefCountTest2(rawBlock);
        doGC();
        await Future<void>.delayed(Duration.zero);
        doGC();
        expect(tracker.isAlive, false);
        expect(internal_for_testing.blockHasRegisteredClosure(rawBlock), false);
      });
    }, skip: !canDoGC);

    @pragma('vm:never-inline')
    (ReferenceTracker, ReferenceTracker, ReferenceTracker)
    blockBlockDartCallRefCountTest(Arena arena) {
      final pool = objc_autoreleasePoolPush();
      final inputBlock = IntBlock.fromFunction((int x) {
        return 5 * x;
      });
      final inputBlockTracker = ReferenceTracker(arena);
      inputBlockTracker.trackBlock(inputBlock);

      final blockBlock = BlockBlock.fromFunction((
        ObjCBlock<Int32 Function(Int32)> intBlock,
      ) {
        return IntBlock.fromFunction((int x) {
          return 3 * intBlock(x);
        });
      });
      final blockBlockTracker = ReferenceTracker(arena);
      blockBlockTracker.trackBlock(blockBlock);

      final outputBlock = blockBlock(inputBlock);
      final outputBlockTracker = ReferenceTracker(arena);
      outputBlockTracker.trackBlock(outputBlock);

      expect(outputBlock(1), 15);
      objc_autoreleasePoolPop(pool);
      doGC();

      expect(inputBlockTracker.isAlive, true);
      expect(blockBlockTracker.isAlive, true);
      expect(outputBlockTracker.isAlive, true);

      expect(
        internal_for_testing.blockHasRegisteredClosure(
          inputBlockTracker.host.cast(),
        ),
        true,
      );
      expect(
        internal_for_testing.blockHasRegisteredClosure(
          blockBlockTracker.host.cast(),
        ),
        true,
      );
      expect(
        internal_for_testing.blockHasRegisteredClosure(
          outputBlockTracker.host.cast(),
        ),
        true,
      );

      expect(inputBlock, isNotNull);
      expect(blockBlock, isNotNull);
      expect(outputBlock, isNotNull);

      return (inputBlockTracker, blockBlockTracker, outputBlockTracker);
    }

    test('Calling a block block from Dart has correct ref counting', () async {
      await using((arena) async {
        final (inputBlockTracker, blockBlockTracker, outputBlockTracker) =
            blockBlockDartCallRefCountTest(arena);
        doGC();
        await Future<void>.delayed(Duration.zero);
        doGC();

        expect(inputBlockTracker.isAlive, false);
        expect(blockBlockTracker.isAlive, false);
        expect(outputBlockTracker.isAlive, false);
        expect(
          internal_for_testing.blockHasRegisteredClosure(
            inputBlockTracker.host.cast(),
          ),
          false,
        );
        expect(
          internal_for_testing.blockHasRegisteredClosure(
            blockBlockTracker.host.cast(),
          ),
          false,
        );
        expect(
          internal_for_testing.blockHasRegisteredClosure(
            outputBlockTracker.host.cast(),
          ),
          false,
        );
      });
    }, skip: !canDoGC);

    @pragma('vm:never-inline')
    (ReferenceTracker, ReferenceTracker, ReferenceTracker)
    blockBlockObjCCallRefCountTest(Arena arena) {
      final pool = objc_autoreleasePoolPush();
      final intBlockTracker = ReferenceTracker(arena);

      final blockBlock = BlockBlock.fromFunction((
        ObjCBlock<Int32 Function(Int32)> intBlock,
      ) {
        intBlockTracker.trackBlock(intBlock);
        expect(
          internal_for_testing.blockHasRegisteredClosure(
            intBlockTracker.host.cast(),
          ),
          false,
        );
        return IntBlock.fromFunction((int x) {
          return 3 * intBlock(x);
        });
      });
      final blockBlockTracker = ReferenceTracker(arena);
      blockBlockTracker.trackBlock(blockBlock);

      final outputBlock = BlockTester.newBlock(blockBlock, withMult: 2);
      final outputBlockTracker = ReferenceTracker(arena);
      outputBlockTracker.trackBlock(outputBlock);

      expect(outputBlock(1), 6);
      objc_autoreleasePoolPop(pool);
      doGC();

      expect(intBlockTracker.isAlive, true);
      expect(blockBlockTracker.isAlive, true);
      expect(outputBlockTracker.isAlive, true);

      expect(
        internal_for_testing.blockHasRegisteredClosure(
          intBlockTracker.host.cast(),
        ),
        false,
      );
      expect(
        internal_for_testing.blockHasRegisteredClosure(
          blockBlockTracker.host.cast(),
        ),
        true,
      );
      expect(
        internal_for_testing.blockHasRegisteredClosure(
          outputBlockTracker.host.cast(),
        ),
        true,
      );

      expect(blockBlock, isNotNull);
      expect(outputBlock, isNotNull);

      return (intBlockTracker, blockBlockTracker, outputBlockTracker);
    }

    test('Calling a block block from ObjC has correct ref counting', () async {
      await using((arena) async {
        final (intBlockTracker, blockBlockTracker, outputBlockTracker) =
            blockBlockObjCCallRefCountTest(arena);
        doGC();
        await Future<void>.delayed(Duration.zero);
        doGC();
        await Future<void>.delayed(Duration.zero);

        expect(intBlockTracker.isAlive, false);
        expect(blockBlockTracker.isAlive, false);
        expect(outputBlockTracker.isAlive, false);
        expect(
          internal_for_testing.blockHasRegisteredClosure(
            intBlockTracker.host.cast(),
          ),
          false,
        );
        expect(
          internal_for_testing.blockHasRegisteredClosure(
            blockBlockTracker.host.cast(),
          ),
          false,
        );
        expect(
          internal_for_testing.blockHasRegisteredClosure(
            outputBlockTracker.host.cast(),
          ),
          false,
        );
      });
    }, skip: !canDoGC);

    @pragma('vm:never-inline')
    (ReferenceTracker, ReferenceTracker, ReferenceTracker)
    nativeBlockBlockDartCallRefCountTest(Arena arena) {
      final pool = objc_autoreleasePoolPush();
      final inputBlock = IntBlock.fromFunction((int x) {
        return 5 * x;
      });
      final inputBlockTracker = ReferenceTracker(arena);
      inputBlockTracker.trackBlock(inputBlock);

      final blockBlock = BlockTester.newBlockBlock(7);
      final blockBlockTracker = ReferenceTracker(arena);
      blockBlockTracker.trackBlock(blockBlock);

      final outputBlock = blockBlock(inputBlock);
      final outputBlockTracker = ReferenceTracker(arena);
      outputBlockTracker.trackBlock(outputBlock);

      expect(outputBlock(1), 35);
      objc_autoreleasePoolPop(pool);
      doGC();

      expect(inputBlockTracker.isAlive, true);
      expect(blockBlockTracker.isAlive, true);
      expect(outputBlockTracker.isAlive, true);

      expect(inputBlock, isNotNull);
      expect(blockBlock, isNotNull);
      expect(outputBlock, isNotNull);

      return (inputBlockTracker, blockBlockTracker, outputBlockTracker);
    }

    test('Calling a native block block from Dart has correct ref counting', () {
      using((Arena arena) {
        final (inputBlockTracker, blockBlockTracker, outputBlockTracker) =
            nativeBlockBlockDartCallRefCountTest(arena);
        doGC();
        expect(inputBlockTracker.isAlive, false);
        expect(blockBlockTracker.isAlive, false);
        expect(outputBlockTracker.isAlive, false);
      });
    }, skip: !canDoGC);

    @pragma('vm:never-inline')
    (ReferenceTracker, ReferenceTracker) nativeBlockBlockObjCCallRefCountTest(
      Arena arena,
    ) {
      final blockBlock = BlockTester.newBlockBlock(7);
      final blockBlockTracker = ReferenceTracker(arena);
      blockBlockTracker.trackBlock(blockBlock);

      final outputBlock = BlockTester.newBlock(blockBlock, withMult: 2);
      final outputBlockTracker = ReferenceTracker(arena);
      outputBlockTracker.trackBlock(outputBlock);

      expect(outputBlock(1), 14);
      doGC();

      expect(blockBlockTracker.isAlive, true);
      expect(outputBlockTracker.isAlive, true);

      expect(blockBlock, isNotNull);
      expect(outputBlock, isNotNull);

      return (blockBlockTracker, outputBlockTracker);
    }

    test('Calling a native block block from ObjC has correct ref counting', () {
      using((Arena arena) {
        final (blockBlockTracker, outputBlockTracker) =
            nativeBlockBlockObjCCallRefCountTest(arena);
        doGC();
        expect(blockBlockTracker.isAlive, false);
        expect(outputBlockTracker.isAlive, false);
      });
    }, skip: !canDoGC);

    @pragma('vm:never-inline')
    (Pointer<Int32>, Pointer<Int32>) objectBlockRefCountTest(Allocator alloc) {
      final pool = objc_autoreleasePoolPush();
      final inputCounter = alloc<Int32>();
      final outputCounter = alloc<Int32>();
      inputCounter.value = 0;
      outputCounter.value = 0;

      final block = ObjectBlock.fromFunction((DummyObject x) {
        return DummyObject.newWithCounter(outputCounter);
      });

      final inputObj = DummyObject.newWithCounter(inputCounter);
      final outputObj = block(inputObj);
      expect(inputCounter.value, 1);
      expect(outputCounter.value, 1);

      objc_autoreleasePoolPop(pool);
      return (inputCounter, outputCounter);
    }

    test('Objects received and returned by blocks have correct ref counts', () {
      using((Arena arena) {
        final (inputCounter, outputCounter) = objectBlockRefCountTest(arena);
        doGC();
        expect(inputCounter.value, 0);
        expect(outputCounter.value, 0);
      });
    }, skip: !canDoGC);

    @pragma('vm:never-inline')
    (Pointer<Int32>, Pointer<Int32>) objectNativeBlockRefCountTest(
      Allocator alloc,
    ) {
      final pool = objc_autoreleasePoolPush();
      final inputCounter = alloc<Int32>();
      final outputCounter = alloc<Int32>();
      inputCounter.value = 0;
      outputCounter.value = 0;

      final block = ObjectBlock.fromFunction((DummyObject x) {
        x.setCounter(inputCounter);
        return DummyObject.newWithCounter(outputCounter);
      });

      final outputObj = BlockTester.callObjectBlock(block);
      expect(inputCounter.value, 1);
      expect(outputCounter.value, 1);

      objc_autoreleasePoolPop(pool);
      return (inputCounter, outputCounter);
    }

    test(
      'Objects received and returned by native blocks have correct ref counts',
      () {
        using((Arena arena) async {
          final (inputCounter, outputCounter) = objectNativeBlockRefCountTest(
            arena,
          );
          doGC();
          await Future<void>.delayed(
            Duration.zero,
          ); // Let dispose message arrive
          doGC();

          expect(inputCounter.value, 0);
          expect(outputCounter.value, 0);
        });
      },
      skip: !canDoGC,
    );

    @pragma('vm:never-inline')
    Future<(ReferenceTracker, ReferenceTracker)>
    listenerBlockArgumentRetentionTest(Arena arena) async {
      final hasRun = Completer<void>();
      late ObjCBlock<Int32 Function(Int32)> inputBlock;
      final intBlockTracker = ReferenceTracker(arena);

      final blockBlock = ListenerBlock.listener((
        ObjCBlock<Int32 Function(Int32)> intBlock,
      ) {
        intBlockTracker.trackBlock(intBlock);
        expect(intBlockTracker.isAlive, true);
        inputBlock = intBlock;
        hasRun.complete();
      });
      final blockBlockTracker = ReferenceTracker(arena);
      blockBlockTracker.trackBlock(blockBlock);

      final thread = BlockTester.callWithBlockOnNewThread(blockBlock);
      thread.start();

      await hasRun.future;
      expect(inputBlock(123), 12300);
      thread.ref.release();
      doGC();

      expect(intBlockTracker.isAlive, true);
      expect(blockBlockTracker.isAlive, true);

      expect(blockBlock, isNotNull);
      expect(inputBlock, isNotNull);

      return (intBlockTracker, blockBlockTracker);
    }

    test('Listener block arguments are not prematurely destroyed', () async {
      // https://github.com/dart-lang/native/issues/835
      await using((arena) async {
        final (intBlockTracker, blockBlockTracker) =
            await listenerBlockArgumentRetentionTest(arena);
        doGC();
        await Future<void>.delayed(Duration.zero);
        doGC();
        expect(intBlockTracker.isAlive, false);
        expect(blockBlockTracker.isAlive, false);
      });
    }, skip: !canDoGC);

    test('Blocking block ref counting same thread', () async {
      await using((arena) async {
        final blockTracker = ReferenceTracker(arena);
        final dummyObjectTracker = ReferenceTracker(arena);
        final objTracker = ReferenceTracker(arena);

        DummyObject? dummyObject = DummyObject();
        dummyObjectTracker.track(dummyObject);

        DartObjectListenerBlock? block = ObjectListenerBlock.blocking((
          DummyObject obj,
        ) {
          objTracker.track(obj);
          expect(objTracker.isAlive, true);

          // Object bound in block's lambda.
          expect(dummyObject, isNotNull);
          expect(dummyObjectTracker.isAlive, true);
        });
        blockTracker.trackBlock(block!);

        final tester = BlockTester.newFromListener(block);
        doGC();
        expect(blockTracker.isAlive, true);
        expect(dummyObjectTracker.isAlive, true);
        expect(objTracker.isAlive, false);

        dummyObject = null;
        block = null;
        tester.invokeAndReleaseListener(null);
        doGC();
        await Future<void>.delayed(Duration.zero);
        doGC();
        expect(blockTracker.isAlive, false);
        expect(dummyObjectTracker.isAlive, false);
        expect(objTracker.isAlive, false);
      });
    }, skip: !canDoGC);

    test('Blocking block ref counting new thread', () async {
      await using((arena) async {
        final blockTracker = ReferenceTracker(arena);
        final dummyObjectTracker = ReferenceTracker(arena);
        final objTracker = ReferenceTracker(arena);

        final completer = Completer<void>();
        DummyObject? dummyObject = DummyObject();
        dummyObjectTracker.track(dummyObject);

        DartObjectListenerBlock? block = ObjectListenerBlock.blocking((
          DummyObject obj,
        ) {
          objTracker.track(obj);
          expect(objTracker.isAlive, true);

          // Object bound in block's lambda.
          expect(dummyObject, isNotNull);
          expect(dummyObjectTracker.isAlive, true);
          completer.complete();
        });
        blockTracker.trackBlock(block!);

        final tester = BlockTester.newFromListener(block);
        doGC();
        expect(blockTracker.isAlive, true);
        expect(dummyObjectTracker.isAlive, true);
        expect(objTracker.isAlive, false);

        tester.invokeAndReleaseListenerOnNewThread();
        await completer.future;

        dummyObject = null;
        block = null;
        doGC();
        await Future<void>.delayed(Duration.zero);
        doGC();
        expect(blockTracker.isAlive, false);
        expect(dummyObjectTracker.isAlive, false);
        expect(objTracker.isAlive, false);
      });
    }, skip: !canDoGC);

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
      final objCBindings = File(
        path.join(
          packagePathForTests,
          'test',
          'native_objc_test',
          'block_test_bindings.m',
        ),
      ).readAsStringSync();

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

    @pragma('vm:never-inline')
    Future<(BlockTester, ReferenceTracker, ReferenceTracker)> regress1571Inner(
      Completer<void> completer,
      Arena arena,
    ) async {
      final dummyObjectTracker = ReferenceTracker(arena);
      final blockTracker = ReferenceTracker(arena);
      final objTracker = ReferenceTracker(arena);

      final dummyObject = DummyObject();
      dummyObjectTracker.track(dummyObject);

      DartObjectListenerBlock? block = ObjectListenerBlock.listener((
        DummyObject obj,
      ) {
        objTracker.track(obj);
        expect(objTracker.isAlive, true);
        completer.complete();
        expect(dummyObject, isNotNull);
        expect(dummyObjectTracker.isAlive, true);
      });
      blockTracker.trackBlock(block!);

      final tester = BlockTester.newFromListener(block);
      await flutterDoGC();
      expect(dummyObjectTracker.isAlive, true);
      expect(blockTracker.isAlive, true);
      expect(objTracker.isAlive, false);

      return (tester, dummyObjectTracker, blockTracker);
    }

    test(
      'Regression test for https://github.com/dart-lang/native/issues/1571',
      () async {
        // Pass a listener block to an ObjC API that retains a reference to the
        // block, and release the Dart-side reference. Then, on a different
        // thread, invoke the block and immediately release the ObjC-side
        // reference. Before the fix, the dtor message could arrive before the
        // invoke message. This was a flaky error, so try a few times.
        await using((arena) async {
          for (int i = 0; i < 10; ++i) {
            final completer = Completer<void>();
            final (tester, dummyObjectTracker, blockTracker) =
                await regress1571Inner(completer, arena);

            await flutterDoGC();
            expect(dummyObjectTracker.isAlive, true);
            expect(blockTracker.isAlive, true);

            tester.invokeAndReleaseListenerOnNewThread();
            await completer.future;

            await flutterDoGC();
            expect(dummyObjectTracker.isAlive, false);
            expect(blockTracker.isAlive, false);
          }
        });
      },
    );

    test('Block.fromFunction, keepIsolateAlive', () async {
      final isolateSendPort = Completer<SendPort>();
      final blocksCreated = Completer<void>();
      final blkKeepAliveDestroyed = Completer<void>();
      final receivePort = RawReceivePort((msg) {
        if (msg is SendPort) {
          isolateSendPort.complete(msg);
        } else if (msg == 'Blocks created') {
          blocksCreated.complete();
        } else if (msg == 'blkKeepAlive destroyed') {
          blkKeepAliveDestroyed.complete();
        }
      });

      final isExited = Completer<void>();
      late final RawReceivePort exitPort;
      exitPort = RawReceivePort((_) {
        isExited.complete();
        exitPort.close();
      });

      final isolate = Isolate.spawn(
        (sendPort) {
          final blkKeepAlive = VoidBlock.fromFunction(
            () {},
            keepIsolateAlive: true,
          );
          final blkDontKeepAlive = VoidBlock.fromFunction(
            () {},
            keepIsolateAlive: false,
          );
          sendPort.send('Blocks created');

          final isolatePort = RawReceivePort((msg) {
            if (msg == 'Destroy blkKeepAlive') {
              blkKeepAlive.ref.release();
              sendPort.send('blkKeepAlive destroyed');
            }
          })..keepIsolateAlive = false;

          sendPort.send(isolatePort.sendPort);
        },
        receivePort.sendPort,
        onExit: exitPort.sendPort,
      );

      await blocksCreated.future;

      doGC();
      await Future<void>.delayed(Duration.zero); // Let dispose message arrive.
      doGC();
      await Future<void>.delayed(Duration.zero); // Let exit message arrive.

      // Both blocks are still alive.
      expect(isExited.isCompleted, isFalse);

      (await isolateSendPort.future).send('Destroy blkKeepAlive');
      await blkKeepAliveDestroyed.future;

      doGC();
      await Future<void>.delayed(Duration.zero); // Let dispose message arrive.
      doGC();
      await Future<void>.delayed(Duration.zero); // Let exit message arrive.

      // Only blkDontKeepAlive is alive.
      await isExited;

      receivePort.close();
    }, skip: !canDoGC);

    test('Block.listener, keepIsolateAlive', () async {
      final isolateSendPort = Completer<SendPort>();
      final blocksCreated = Completer<void>();
      final blkKeepAliveDestroyed = Completer<void>();
      final receivePort = RawReceivePort((msg) {
        if (msg is SendPort) {
          isolateSendPort.complete(msg);
        } else if (msg == 'Blocks created') {
          blocksCreated.complete();
        } else if (msg == 'blkKeepAlive destroyed') {
          blkKeepAliveDestroyed.complete();
        }
      });

      final isExited = Completer<void>();
      late final RawReceivePort exitPort;
      exitPort = RawReceivePort((_) {
        isExited.complete();
        exitPort.close();
      });

      final isolate = Isolate.spawn(
        (sendPort) {
          final blkKeepAlive = VoidBlock.listener(
            () {},
            keepIsolateAlive: true,
          );
          final blkDontKeepAlive = VoidBlock.listener(
            () {},
            keepIsolateAlive: false,
          );
          sendPort.send('Blocks created');

          final isolatePort = RawReceivePort((msg) {
            if (msg == 'Destroy blkKeepAlive') {
              blkKeepAlive.ref.release();
              sendPort.send('blkKeepAlive destroyed');
            }
          })..keepIsolateAlive = false;

          sendPort.send(isolatePort.sendPort);
        },
        receivePort.sendPort,
        onExit: exitPort.sendPort,
      );

      await blocksCreated.future;

      doGC();
      await Future<void>.delayed(Duration.zero); // Let dispose message arrive.
      doGC();
      await Future<void>.delayed(Duration.zero); // Let exit message arrive.

      // Both blocks are still alive.
      expect(isExited.isCompleted, isFalse);

      (await isolateSendPort.future).send('Destroy blkKeepAlive');
      await blkKeepAliveDestroyed.future;

      doGC();
      await Future<void>.delayed(Duration.zero); // Let dispose message arrive.
      doGC();
      await Future<void>.delayed(Duration.zero); // Let exit message arrive.

      // Only blkDontKeepAlive is alive.
      await isExited;

      receivePort.close();
    }, skip: !canDoGC);

    test('Block.blocking, keepIsolateAlive', () async {
      final isolateSendPort = Completer<SendPort>();
      final blocksCreated = Completer<void>();
      final blkKeepAliveDestroyed = Completer<void>();
      final receivePort = RawReceivePort((msg) {
        if (msg is SendPort) {
          isolateSendPort.complete(msg);
        } else if (msg == 'Blocks created') {
          blocksCreated.complete();
        } else if (msg == 'blkKeepAlive destroyed') {
          blkKeepAliveDestroyed.complete();
        }
      });

      final isExited = Completer<void>();
      late final RawReceivePort exitPort;
      exitPort = RawReceivePort((_) {
        isExited.complete();
        exitPort.close();
      });

      final isolate = Isolate.spawn(
        (sendPort) {
          final blkKeepAlive = VoidBlock.blocking(
            () {},
            keepIsolateAlive: true,
          );
          final blkDontKeepAlive = VoidBlock.blocking(
            () {},
            keepIsolateAlive: false,
          );
          sendPort.send('Blocks created');

          final isolatePort = RawReceivePort((msg) {
            if (msg == 'Destroy blkKeepAlive') {
              blkKeepAlive.ref.release();
              sendPort.send('blkKeepAlive destroyed');
            }
          })..keepIsolateAlive = false;

          sendPort.send(isolatePort.sendPort);
        },
        receivePort.sendPort,
        onExit: exitPort.sendPort,
      );

      await blocksCreated.future;

      doGC();
      await Future<void>.delayed(Duration.zero); // Let dispose message arrive.
      doGC();
      await Future<void>.delayed(Duration.zero); // Let exit message arrive.

      // Both blocks are still alive.
      expect(isExited.isCompleted, isFalse);

      (await isolateSendPort.future).send('Destroy blkKeepAlive');
      await blkKeepAliveDestroyed.future;

      doGC();
      await Future<void>.delayed(Duration.zero); // Let dispose message arrive.
      doGC();
      await Future<void>.delayed(Duration.zero); // Let exit message arrive.

      // Only blkDontKeepAlive is alive.
      await isExited;

      receivePort.close();
    }, skip: !canDoGC);

    test('Blocking block deadlock', () async {
      // Regression test for https://github.com/dart-lang/native/issues/1967
      // Run the test on a new isolate so we can safely claim ownership of it.
      final value = await Isolate.run(() {
        setCurrentThreadOwnsIsolate();

        var innerValue = 0;
        final block = VoidBlock.blocking(() {
          innerValue = 123;
        });
        BlockTester.callOnSameThreadOutsideIsolate(block);
        return innerValue;
      });
      expect(value, 123);
    }, skip: !hasIsolateOwnershipApi);
  });
}

int _add100(int x) {
  return x + 100;
}
