// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
library;

import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:objective_c/objective_c.dart';
import 'package:objective_c/src/objective_c_bindings_generated.dart'
    show DartInputStreamAdapter, DartInputStreamAdapter$Methods;
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

    group('toNSInputStream', () {
      group('empty', () {
        late NSInputStream inputStream;

        setUp(() {
          inputStream = const Stream<List<int>>.empty().toNSInputStream();
        });
        tearDown(() => inputStream.close());

        test('initial state', () {
          expect(
            inputStream.streamStatus,
            NSStreamStatus.NSStreamStatusNotOpen,
          );
          expect(inputStream.streamError, null);
        });

        test('open', () {
          inputStream.open();
          expect(inputStream.streamStatus, NSStreamStatus.NSStreamStatusOpen);
          expect(inputStream.streamError, null);
        });

        test('read', () async {
          inputStream.open();
          final (count, data, hasBytesAvailable, status, error) = await read(
            inputStream,
            10,
          );
          expect(count, 0);
          expect(data, isEmpty);
          expect(hasBytesAvailable, false);
          expect(status, NSStreamStatus.NSStreamStatusAtEnd);
          expect(error, isNull);
          inputStream.close();
        });

        test('read without open', () async {
          final (count, data, hasBytesAvailable, status, error) = await read(
            inputStream,
            10,
          );
          expect(count, -1);
          expect(data, isEmpty);
          expect(hasBytesAvailable, false);
          expect(status, NSStreamStatus.NSStreamStatusNotOpen);
          expect(error, isNull);
        });

        test('close', () {
          inputStream.open();
          inputStream.close();
          expect(inputStream.streamStatus, NSStreamStatus.NSStreamStatusClosed);
          expect(inputStream.streamError, null);
        });
      });

      group('small stream', () {
        late NSInputStream inputStream;

        setUp(() {
          inputStream = Stream.fromIterable([
            [1],
            [2, 3],
            [4, 5, 6],
          ]).toNSInputStream();
        });
        tearDown(() => inputStream.close());

        test('initial state', () {
          expect(
            inputStream.streamStatus,
            NSStreamStatus.NSStreamStatusNotOpen,
          );
          expect(inputStream.streamError, null);
        });

        test('open', () {
          inputStream.open();
          expect(inputStream.streamStatus, NSStreamStatus.NSStreamStatusOpen);
          expect(inputStream.streamError, null);
        });

        test('partial read', () async {
          inputStream.open();
          final (count, data, hasBytesAvailable, status, error) = await read(
            inputStream,
            5,
          );
          expect(count, lessThanOrEqualTo(5));
          expect(count, greaterThanOrEqualTo(1));
          expect(data, [1, 2, 3, 4, 5].sublist(0, count));
          expect(hasBytesAvailable, true);
          expect(status, NSStreamStatus.NSStreamStatusOpen);
          expect(error, isNull);
        });

        test('full read', () async {
          inputStream.open();
          final readData = <int>[];
          while (true) {
            final (count, data, hasBytesAvailable, status, error) = await read(
              inputStream,
              6,
            );
            readData.addAll(data);

            expect(error, isNull);
            if (count == 0) {
              expect(hasBytesAvailable, false);
              expect(status, NSStreamStatus.NSStreamStatusAtEnd);
              expect(readData, [1, 2, 3, 4, 5, 6]);
              break;
            }
          }
        });

        test('read without open', () async {
          final (count, data, hasBytesAvailable, status, error) = await read(
            inputStream,
            10,
          );
          expect(count, -1);
          expect(data, isEmpty);
          expect(hasBytesAvailable, false);
          expect(status, NSStreamStatus.NSStreamStatusNotOpen);
          expect(error, isNull);
        });

        test('close', () {
          inputStream.open();
          inputStream.close();
          expect(inputStream.streamStatus, NSStreamStatus.NSStreamStatusClosed);
          expect(inputStream.streamError, null);
        });
      });
    });

    group('large stream', () {
      late NSInputStream inputStream;
      final streamData = List.generate(100, (x) => List.filled(10000, x));
      final testData = streamData.expand((x) => x).toList();

      setUp(() {
        inputStream = Stream.fromIterable(streamData).toNSInputStream();
      });
      tearDown(() => inputStream.close());

      test('partial read', () async {
        inputStream.open();
        final (count, data, hasBytesAvailable, status, error) = await read(
          inputStream,
          100000,
        );
        expect(count, lessThanOrEqualTo(100000));
        expect(count, greaterThanOrEqualTo(1));
        expect(data, testData.sublist(0, count));
        expect(hasBytesAvailable, true);
        expect(status, NSStreamStatus.NSStreamStatusOpen);
        expect(error, isNull);
      });

      test('full read', () async {
        inputStream.open();
        final readData = <int>[];
        while (true) {
          final (count, data, hasBytesAvailable, status, error) = await read(
            inputStream,
            Random.secure().nextInt(100000),
          );

          readData.addAll(data);

          expect(error, isNull);
          if (count == 0) {
            expect(hasBytesAvailable, false);
            expect(status, NSStreamStatus.NSStreamStatusAtEnd);
            expect(readData, testData);
            break;
          }
        }
      });
    });

    test('error in stream', () async {
      late NSInputStream inputStream;

      inputStream = () async* {
        yield [1, 2];
        throw const FileSystemException('some exception message');
      }().toNSInputStream();

      inputStream.open();
      final (count1, data1, hasBytesAvailable1, status1, error1) = await read(
        inputStream,
        10,
      );
      expect(count1, 2);
      expect(data1, [1, 2]);
      expect(hasBytesAvailable1, true);
      expect(status1, NSStreamStatus.NSStreamStatusOpen);
      expect(error1, isNull);

      final (count2, _, hasBytesAvailable2, status2, error2) = await read(
        inputStream,
        10,
      );
      expect(count2, -1);
      expect(hasBytesAvailable2, false);
      expect(status2, NSStreamStatus.NSStreamStatusError);
      expect(
        error2,
        isA<NSError>()
            .having(
              (e) => e.localizedDescription.toDartString(),
              'localizedDescription',
              contains('some exception message'),
            )
            .having((e) => e.domain.toDartString(), 'domain', 'DartError'),
      );
    });

    group('delegate', () {
      late DartInputStreamAdapter inputStream;

      setUp(() {
        inputStream =
            Stream.fromIterable([
                  [1, 2, 3],
                ]).toNSInputStream()
                as DartInputStreamAdapter;
      });
      tearDown(() => inputStream.close());

      test('default delegate', () async {
        expect(inputStream.delegate, inputStream);
        inputStream.stream(
          inputStream,
          handleEvent: NSStreamEvent.NSStreamEventOpenCompleted,
        );
      });

      test('non-self delegate', () async {
        final events = <NSStreamEvent>[];

        inputStream.delegate = NSStreamDelegate.implement(
          stream_handleEvent_: (stream, event) => events.add(event),
        );
        inputStream.stream(
          inputStream,
          handleEvent: NSStreamEvent.NSStreamEventOpenCompleted,
        );
        expect(events, [NSStreamEvent.NSStreamEventOpenCompleted]);
      });

      test('assign to null', () async {
        inputStream.delegate = null;
        expect(inputStream.delegate, inputStream);
      });
    });

    group('ref counting', () {
      test('dart and objective-c cycle', () async {
        final completionPort = ReceivePort();
        unawaited(
          Isolate.spawn(
            (_) async {
              final inputStream = const Stream<List<int>>.empty()
                  .toNSInputStream();
              inputStream.ref.release();
            },
            Void,
            onExit: completionPort.sendPort,
          ),
        );
        await completionPort.first;
      });
      test('with self delegate', () async {
        final pool = autoreleasePoolPush();
        DartInputStreamAdapter? inputStream =
            Stream.fromIterable([
                  [1, 2, 3],
                ]).toNSInputStream()
                as DartInputStreamAdapter;

        expect(inputStream.delegate, inputStream);

        final ptr = inputStream.ref.pointer;
        autoreleasePoolPop(pool);
        expect(objectRetainCount(ptr), greaterThan(0));

        inputStream.open();
        inputStream.close();
        inputStream = null;

        doGC();
        await Future<void>.delayed(Duration.zero);
        doGC();

        expect(objectRetainCount(ptr), 0);
      });

      test('with non-self delegate', () async {
        final pool = autoreleasePoolPush();
        DartInputStreamAdapter? inputStream =
            Stream.fromIterable([
                  [1, 2, 3],
                ]).toNSInputStream()
                as DartInputStreamAdapter;

        inputStream.delegate = NSStreamDelegate.castFrom(NSObject());
        expect(inputStream.delegate, isNot(inputStream));

        final ptr = inputStream.ref.pointer;
        autoreleasePoolPop(pool);
        expect(objectRetainCount(ptr), greaterThan(0));

        inputStream.open();
        inputStream.close();
        inputStream = null;

        doGC();
        await Future<void>.delayed(Duration.zero);
        doGC();

        expect(objectRetainCount(ptr), 0);
      });
    });
  });
}
