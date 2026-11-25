// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:ffi' as ffi;
import 'dart:typed_data';

import 'package:legacy_test_runner/legacy_bindings.g.dart';
import 'package:objective_c/objective_c.dart' as objc;
import 'package:test/test.dart';

void main() {
  setUpAll(() {
    // Touch a @Native symbol so the VM loads the dylib and registers its
    // Objective-C classes and protocols before objc.getClass/getProtocol calls.
    expect(kLegacyMagicNumber, 42);
  });

  group('Classes & Lifecycle', () {
    test('alloc/init, custom initializer, factory, and subclassing', () {
      final defaultObj = LegacyBase.alloc().init();
      expect(defaultObj.value, 0);
      expect(defaultObj.readOnlyId, greaterThan(0));

      final customObj = LegacyBase.alloc().initWithValue(17);
      expect(customObj.value, 17);
      expect(customObj.readOnlyId, greaterThan(defaultObj.readOnlyId));

      final factoryObj = LegacyBase.createWithValue(99);
      expect(factoryObj.value, 99);

      final child = LegacyChild.alloc().initWithValue$1(
        5,
        tag: 'sub'.toNSString(),
      );
      expect(child.value, 5);
      expect(child.childTag.toDartString(), 'sub');

      // Subclassing + isA / as casting
      expect(LegacyBase.isA(child), isTrue);
      expect(LegacyChild.isA(child), isTrue);
      expect(LegacyChild.isA(defaultObj), isFalse);

      final objc.NSObject asNSObject = child;
      expect(LegacyChild.isA(asNSObject), isTrue);
      final downcast = LegacyChild.as(asNSObject);
      expect(downcast.childTag.toDartString(), 'sub');
    });
  });

  group('Methods & Properties', () {
    test('instance/class methods, nullables, and properties', () {
      final obj = LegacyBase.createWithValue(10);
      expect(obj.addA(3, toB: 4), 17);
      expect(LegacyBase.multiplyA(6, byB: 7), 42);

      // Nullable parameter and return
      expect(obj.echoNullable(null), isNull);
      expect(obj.echoNullable('hello'.toNSString())?.toDartString(), 'hello');

      // Readwrite properties
      obj.value = 25;
      expect(obj.value, 25);

      expect(obj.label, isNull);
      obj.label = 'tagged'.toNSString();
      expect(obj.label?.toDartString(), 'tagged');
      obj.label = null;
      expect(obj.label, isNull);

      // Class property
      LegacyBase.setSharedCounter(123);
      expect(LegacyBase.getSharedCounter(), 123);
      LegacyBase.setSharedCounter(0);
      expect(LegacyBase.getSharedCounter(), 0);
    });
  });

  group('Categories', () {
    test('category on custom class and on NSString', () {
      final obj = LegacyBase.createWithValue(21);
      expect(obj.doubledValue(), 42);

      final reversed = 'dart-objc'.toNSString().legacyReversed();
      expect(reversed.toDartString(), 'cjbo-trad');
    });
  });

  group('Protocols', () {
    test('conforming ObjC class', () {
      final objcDelegate = LegacyObjCDelegate.alloc().initWithMultiplier(3);
      expect(LegacyDelegate.conformsTo(objcDelegate), isTrue);
      expect(
        LegacyBase.invokeComputeOnDelegate(objcDelegate, withInput: 7),
        21,
      );
      expect(
        LegacyBase.invokeOptionalGreetingOnDelegate(
          objcDelegate,
        )?.toDartString(),
        'Hello x3',
      );
      objcDelegate.notifyMessage('ping'.toNSString());
      expect(objcDelegate.lastMessage?.toDartString(), 'ping');
    });

    test(
      'Dart-implemented protocol via implement (with & without optional)',
      () {
        String? received;
        final withOptional = LegacyDelegate$Builder.implement(
          computeWithInput_: (input) => input + 100,
          notifyMessage_: (msg) => received = msg.toDartString(),
          optionalGreeting: () => 'Hi from Dart'.toNSString(),
        );
        expect(LegacyDelegate.conformsTo(withOptional), isTrue);
        expect(
          LegacyBase.invokeComputeOnDelegate(withOptional, withInput: 5),
          105,
        );
        withOptional.notifyMessage('sync-msg'.toNSString());
        expect(received, 'sync-msg');
        expect(
          LegacyBase.invokeOptionalGreetingOnDelegate(
            withOptional,
          )?.toDartString(),
          'Hi from Dart',
        );

        final withoutOptional = LegacyDelegate$Builder.implement(
          computeWithInput_: (input) => input * 2,
          notifyMessage_: (_) {},
        );
        expect(
          LegacyBase.invokeOptionalGreetingOnDelegate(withoutOptional),
          isNull,
        );
      },
    );

    test('Dart-implemented protocol via implementAsListener', () async {
      final completer = Completer<String>();
      final listenerDelegate = LegacyDelegate$Builder.implementAsListener(
        computeWithInput_: (input) => input,
        notifyMessage_: (msg) => completer.complete(msg.toDartString()),
      );
      LegacyBase.invokeNotifyAsyncOnDelegate(
        listenerDelegate,
        message: 'async-protocol'.toNSString(),
      );
      expect(await completer.future, 'async-protocol');
    });

    test(
      'Dart-implemented protocol via implementAsBlocking on background queue',
      () async {
        final events = <String>[];
        final done = Completer<void>();

        final blockingDelegate = LegacyDelegate$Builder.implementAsBlocking(
          computeWithInput_: (input) => input,
          notifyMessage_: (msg) {
            events.add('notify:${msg.toDartString()}');
          },
        );
        final onDone = ObjCBlock_ffiVoid_NSString.listener((msg) {
          events.add(msg.toDartString());
          done.complete();
        });

        LegacyBase.invokeNotifyBlockingOnBackgroundQueue(
          blockingDelegate,
          message: 'bg-proto'.toNSString(),
          onDone: onDone,
        );
        await done.future;
        expect(events, ['notify:bg-proto', 'after-protocol-blocking']);
      },
    );
  });

  group('Blocks', () {
    test('returning and calling ObjC block from Dart', () {
      final adder = LegacyBase.makeAdderBlock(10);
      expect(adder(32), 42);
      expect(adder(-5), 5);
    });

    test('passing sync Dart block via fromFunction', () {
      final block = ObjCBlock_Int32_Int32.fromFunction((x) => x * x);
      expect(LegacyBase.callIntBlock(block, withValue: 9), 81);
    });

    test('passing async Dart block via listener on background queue', () async {
      final completer = Completer<String>();
      final block = ObjCBlock_ffiVoid_NSString.listener(
        (msg) => completer.complete(msg.toDartString()),
      );
      LegacyBase.callVoidBlockAsync(
        block,
        withMessage: 'hello-listener'.toNSString(),
      );
      expect(await completer.future, 'hello-listener');
    });

    test('passing blocking Dart block on background queue', () async {
      final events = <String>[];
      final done = Completer<void>();

      final blockingBlock = ObjCBlock_ffiVoid_NSString.blocking((msg) {
        events.add('block:${msg.toDartString()}');
      });
      final onDone = ObjCBlock_ffiVoid_NSString.listener((msg) {
        events.add(msg.toDartString());
        done.complete();
      });

      LegacyBase.callVoidBlockBlockingOnBackgroundQueue(
        blockingBlock,
        message: 'bg-block'.toNSString(),
        onDone: onDone,
      );
      await done.future;
      expect(events, ['block:bg-block', 'after-block-blocking']);
    });
  });

  group('Errors (NSError**)', () {
    test('BOOL method succeeds or throws NSErrorException', () {
      expect(LegacyBase.validatePositive(5), isTrue);

      expect(
        () => LegacyBase.validatePositive(-1),
        throwsA(
          isA<objc.NSErrorException>()
              .having((e) => e.error.code, 'code', 1001)
              .having(
                (e) => e.error.domain.toDartString(),
                'domain',
                'LegacyErrorDomain',
              ),
        ),
      );
    });

    test('nullable object method returns value or throws NSErrorException', () {
      expect(LegacyBase.checkedGreeting(false)?.toDartString(), 'ok');

      expect(
        () => LegacyBase.checkedGreeting(true),
        throwsA(
          isA<objc.NSErrorException>()
              .having((e) => e.error.code, 'code', 1002)
              .having(
                (e) => e.error.domain.toDartString(),
                'domain',
                'LegacyErrorDomain',
              ),
        ),
      );
    });
  });

  group('Structs & Enums', () {
    test('C struct passed and returned by value', () {
      final p = ffi.Struct.create<LegacyPoint>()
        ..x = 10
        ..y = 20;
      final moved = LegacyBase.translatePoint(p, dx: -3, dy: 7);
      expect(moved.x, 7);
      expect(moved.y, 27);
    });

    test('NS_ENUM and NS_OPTIONS', () {
      const flags = LegacyFlags.LegacyFlagRead | LegacyFlags.LegacyFlagExec;
      final desc = LegacyBase.describeColor(
        LegacyColor.LegacyColorGreen,
        flags: flags,
      );
      expect(desc.toDartString(), 'green:5');
    });
  });

  group('Foundation / package:objective_c Built-ins', () {
    test('NSString, NSArray, NSMutableArray', () {
      final mutable = objc.NSMutableArray()
        ..addObject('alpha'.toNSString())
        ..addObject('beta'.toNSString());
      final upper = LegacyBase.uppercasedArray(mutable);
      expect(upper.count, 2);
      expect(objc.NSString.as(upper.objectAtIndex(0)).toDartString(), 'ALPHA');
      expect(objc.NSString.as(upper.objectAtIndex(1)).toDartString(), 'BETA');
    });

    test('NSDictionary, NSMutableDictionary, NSNumber', () {
      final words = objc.NSMutableArray()
        ..addObject('cat'.toNSString())
        ..addObject('elephant'.toNSString());
      final lengths = LegacyBase.wordLengths(words);
      expect(
        objc.NSNumber.as(lengths.objectForKey('cat'.toNSString())!).intValue,
        3,
      );
      expect(
        objc.NSNumber.as(
          lengths.objectForKey('elephant'.toNSString())!,
        ).intValue,
        8,
      );

      final dict = objc.NSMutableDictionary();
      dict.setObject(42.toNSNumber(), forKey: 'answer'.toNSString());
      expect(
        objc.NSNumber.as(dict.objectForKey('answer'.toNSString())!).intValue,
        42,
      );

      final nums = objc.NSMutableArray()
        ..addObject(10.toNSNumber())
        ..addObject(20.toNSNumber())
        ..addObject(12.toNSNumber());
      expect(LegacyBase.sumNumbers(nums).longLongValue, 42);
    });

    test('NSSet and NSData', () {
      final items = objc.NSMutableArray()
        ..addObject('a'.toNSString())
        ..addObject('b'.toNSString())
        ..addObject('a'.toNSString());
      final unique = LegacyBase.uniqueItems(items);
      expect(unique.count, 2);
      expect(unique.containsObject('a'.toNSString()), isTrue);
      expect(unique.containsObject('b'.toNSString()), isTrue);

      final input = Uint8List.fromList([1, 2, 3, 4]).toNSData();
      final reversed = LegacyBase.reverseData(input);
      expect(reversed.toList(), [4, 3, 2, 1]);
    });
  });

  group('Memory Management & ARC', () {
    test('autoReleasePool and explicit release cleanly deallocate objects', () {
      late int id;
      objc.autoReleasePool(() {
        final obj = LegacyBase.createWithValue(7);
        id = obj.readOnlyId;
        expect(LegacyBase.wasDeallocated(id), isFalse);
        obj.ref.release();
      });
      expect(LegacyBase.wasDeallocated(id), isTrue);
    });
  });

  group('C Function & Global', () {
    test('top-level C function and global constant', () {
      expect(kLegacyMagicNumber, 42);
      expect(legacyAddInts(19, 23), 42);
    });
  });
}
