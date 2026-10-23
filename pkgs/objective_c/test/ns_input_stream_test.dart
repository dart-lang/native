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

/// Reads [stream] asynchronously: schedules it in a run loop and only reads
/// after a stream event, while `hasBytesAvailable` is true.
///
/// Returns the data, the stream events, and the final status and error.
Future<(List<int>, List<int>, NSStreamStatus, NSError?)> readScheduled(
  NSInputStream stream,
) => Isolate.run(() {
  final data = <int>[];
  final events = <int>[];
  var finished = false;
  final buffer = calloc<Uint8>(1024);
  final delegate = NSStreamDelegate$Builder.implement(
    stream_handleEvent_: (_, event) {
      events.add(event);
      while (stream.hasBytesAvailable) {
        final count = stream.read(buffer, maxLength: 1024);
        if (count <= 0) break;
        data.addAll(buffer.asTypedList(count));
      }
      if (event == NSStreamEvent.NSStreamEventEndEncountered ||
          event == NSStreamEvent.NSStreamEventErrorOccurred) {
        finished = true;
      }
    },
  );
  final runLoop = NSRunLoop.getCurrentRunLoop();
  final mode = 'kCFRunLoopDefaultMode'.toNSString();
  stream.delegate = delegate;
  stream.scheduleInRunLoop(runLoop, forMode: mode);
  stream.open();
  final deadline = DateTime.now().add(const Duration(seconds: 5));
  while (!finished && DateTime.now().isBefore(deadline)) {
    runLoop.acceptInputForMode(
      mode,
      beforeDate: NSDate.dateWithTimeIntervalSinceNow(0.1),
    );
  }
  calloc.free(buffer);
  stream.removeFromRunLoop(runLoop, forMode: mode);
  stream.delegate = null;
  delegate.ref.release();
  return (data, events, stream.streamStatus, stream.streamError);
});

void main() {
  group('NSInputStream', () {
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

        // NSURLSession can still read from or close a request body stream
        // after the Dart owner closed it (e.g. when the request completes
        // with an error or is cancelled right after it starts). By then the
        // Dart side has received the close message and closed its port, so
        // these must fail gracefully rather than assert on a failed post.
        test('read after close', () async {
          inputStream.open();
          inputStream.close();
          await Future<void>.delayed(const Duration(milliseconds: 100));
          final (count, data, hasBytesAvailable, status, error) = await read(
            inputStream,
            10,
          );
          expect(count, -1);
          expect(data, isEmpty);
          expect(hasBytesAvailable, false);
          expect(status, NSStreamStatus.NSStreamStatusClosed);
          expect(error, isNull);
        });

        test('close twice', () async {
          inputStream.open();
          inputStream.close();
          await Future<void>.delayed(const Duration(milliseconds: 100));
          inputStream.close();
          expect(inputStream.streamStatus, NSStreamStatus.NSStreamStatusClosed);
          expect(inputStream.streamError, null);
        });
      });

      group('read waiting for data', () {
        test('stream closed', () async {
          late final NSInputStream inputStream;
          final controller = StreamController<List<int>>(
            // Close the input stream during the native read.
            onResume: () => inputStream.close(),
          );
          addTearDown(controller.close);
          inputStream = controller.stream.toNSInputStream();
          inputStream.open();
          final (count, data, hasBytesAvailable, status, error) = await read(
            inputStream,
            10,
          );
          expect(count, -1);
          expect(data, isEmpty);
          expect(hasBytesAvailable, false);
          expect(status, NSStreamStatus.NSStreamStatusClosed);
          expect(error, isNull);
        });

        test('isolate exits', () async {
          final ready = ReceivePort();
          await Isolate.spawn((SendPort sendPort) {
            final controller = StreamController<List<int>>(
              // Exit the isolate during the native read.
              onResume: Isolate.exit,
            );
            sendPort.send(controller.stream.toNSInputStream());
          }, ready.sendPort);
          final inputStream = await ready.first as NSInputStream;
          addTearDown(inputStream.close);
          inputStream.open();
          final (count, data, hasBytesAvailable, status, error) = await read(
            inputStream,
            10,
          );
          expect(count, -1);
          expect(data, isEmpty);
          expect(hasBytesAvailable, false);
          expect(status, NSStreamStatus.NSStreamStatusError);
          expect(error, isNotNull);
        });
      });

      group('scheduled in a run loop', () {
        test('hasBytesAvailable', () async {
          final controller = StreamController<List<int>>();
          final inputStream = controller.stream.toNSInputStream();
          addTearDown(inputStream.close);
          inputStream.scheduleInRunLoop(
            NSRunLoop.getCurrentRunLoop(),
            forMode: 'kCFRunLoopDefaultMode'.toNSString(),
          );
          inputStream.open();
          expect(inputStream.hasBytesAvailable, isFalse);

          controller.add([1]);
          final deadline = DateTime.now().add(const Duration(seconds: 5));
          while (!inputStream.hasBytesAvailable &&
              DateTime.now().isBefore(deadline)) {
            await Future<void>.delayed(const Duration(milliseconds: 10));
          }
          expect(inputStream.hasBytesAvailable, isTrue);
        });

        test('read', () async {
          final controller = StreamController<List<int>>();
          final inputStream = controller.stream.toNSInputStream();
          addTearDown(inputStream.close);
          final reading = readScheduled(inputStream);
          await Future<void>.delayed(const Duration(milliseconds: 100));
          controller.add([1, 2, 3]);
          await Future<void>.delayed(const Duration(milliseconds: 100));
          controller.add([4, 5]);
          // Without run loop support, the subscription stays paused and this
          // never completes.
          unawaited(controller.close());
          final (data, events, status, error) = await reading;
          expect(data, [1, 2, 3, 4, 5]);
          expect(
            events,
            containsAllInOrder([
              NSStreamEvent.NSStreamEventOpenCompleted,
              NSStreamEvent.NSStreamEventHasBytesAvailable,
              NSStreamEvent.NSStreamEventEndEncountered,
            ]),
          );
          expect(status, NSStreamStatus.NSStreamStatusAtEnd);
          expect(error, isNull);
        });

        test('isolate exits', () async {
          final ready = ReceivePort();
          await Isolate.spawn((SendPort sendPort) {
            final controller = StreamController<List<int>>(
              // Exit the isolate when the stream asks for data.
              onResume: Isolate.exit,
            );
            sendPort.send(controller.stream.toNSInputStream());
          }, ready.sendPort);
          final inputStream = await ready.first as NSInputStream;
          addTearDown(inputStream.close);
          final (data, events, status, error) = await readScheduled(
            inputStream,
          );
          expect(data, isEmpty);
          expect(events, contains(NSStreamEvent.NSStreamEventErrorOccurred));
          expect(status, NSStreamStatus.NSStreamStatusError);
          expect(error, isNotNull);
        });

        test('scheduled again after being removed', () async {
          var paused = Completer<void>();
          final resumed = Completer<void>();
          final controller = StreamController<List<int>>(
            onPause: () {
              if (!paused.isCompleted) paused.complete();
            },
            onResume: () {
              if (!resumed.isCompleted) resumed.complete();
            },
          );
          final inputStream = controller.stream.toNSInputStream();
          addTearDown(inputStream.close);
          // `toNSInputStream` pauses the stream until data is requested.
          paused = Completer<void>();
          final runLoop = NSRunLoop.getCurrentRunLoop();
          final mode = 'kCFRunLoopDefaultMode'.toNSString();
          inputStream.scheduleInRunLoop(runLoop, forMode: mode);
          inputStream.open();
          await resumed.future;
          inputStream.removeFromRunLoop(runLoop, forMode: mode);

          // Add more than the stream buffers ahead, so that the stream is
          // paused, and then empty the buffer with an unscheduled read.
          controller.add(List.filled(5000, 1));
          await paused.future;
          final buffer = calloc<Uint8>(5000);
          addTearDown(() => calloc.free(buffer));
          expect(inputStream.read(buffer, maxLength: 5000), 5000);

          controller.add([1, 2, 3]);
          unawaited(controller.close());
          final (data, events, status, error) = await readScheduled(
            inputStream,
          );
          expect(data, [1, 2, 3]);
          expect(events, contains(NSStreamEvent.NSStreamEventEndEncountered));
          expect(status, NSStreamStatus.NSStreamStatusAtEnd);
          expect(error, isNull);
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
        final events = <int>[];

        inputStream.delegate = NSStreamDelegate$Builder.implement(
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
        await using((arena) async {
          final inputStreamTracker = ReferenceTracker(arena);
          late DartInputStreamAdapter? inputStream;
          autoReleasePool(() {
            inputStream =
                Stream.fromIterable([
                      [1, 2, 3],
                    ]).toNSInputStream()
                    as DartInputStreamAdapter;

            expect(inputStream!.delegate, inputStream);

            inputStreamTracker.track(inputStream!);
          });
          expect(inputStreamTracker.isAlive, true);

          inputStream!.open();
          inputStream!.close();
          inputStream = null;

          doGC();
          await Future<void>.delayed(Duration.zero);
          doGC();

          expect(inputStreamTracker.isAlive, false);
        });
      });

      test('with non-self delegate', () async {
        await using((arena) async {
          final inputStreamTracker = ReferenceTracker(arena);
          late DartInputStreamAdapter? inputStream;
          autoReleasePool(() {
            inputStream =
                Stream.fromIterable([
                      [1, 2, 3],
                    ]).toNSInputStream()
                    as DartInputStreamAdapter;

            inputStream!.delegate = NSStreamDelegate.as(NSObject());
            expect(inputStream!.delegate, isNot(inputStream));

            inputStreamTracker.track(inputStream!);
          });
          expect(inputStreamTracker.isAlive, true);

          inputStream!.open();
          inputStream!.close();
          inputStream = null;

          doGC();
          await Future<void>.delayed(Duration.zero);
          doGC();

          expect(inputStreamTracker.isAlive, false);
        });
      });

      test('from iterable, garbage collected', () async {
        await using((arena) async {
          final inputStreamTracker = ReferenceTracker(arena);
          DartInputStreamAdapter? inputStream =
              Stream.fromIterable([
                    [1, 2, 3],
                    [4, 5, 6],
                  ]).toNSInputStream()
                  as DartInputStreamAdapter;

          inputStreamTracker.track(inputStream);
          expect(inputStreamTracker.isAlive, isTrue);

          inputStream.open();
          while (true) {
            final (count, _, _, _, _) = await read(inputStream, 10);
            if (count == 0) break;
          }
          inputStream.close();
          inputStream = null;

          doGC();
          await Future<void>.delayed(Duration.zero);
          doGC();

          expect(inputStreamTracker.isAlive, isFalse);
        });
      });

      test('from stream, garbage collected', () async {
        await using((arena) async {
          final inputStreamTracker = ReferenceTracker(arena);
          final chunk = Uint8List(1024 * 1024);
          final controller = StreamController<Uint8List>();

          DartInputStreamAdapter? inputStream =
              controller.stream.toNSInputStream() as DartInputStreamAdapter;
          inputStreamTracker.track(inputStream);
          expect(inputStreamTracker.isAlive, isTrue);

          inputStream.open();

          final feedFuture = () async {
            for (var i = 0; i < 50; i++) {
              controller.add(chunk);
              await Future<void>.delayed(Duration.zero);
            }
            await controller.close();
          }();

          var totalRead = 0;
          while (true) {
            final (count, _, _, _, _) = await read(inputStream, 1024 * 1024);
            if (count == 0) break;
            totalRead += count;
          }
          expect(totalRead, 50 * 1024 * 1024);

          inputStream.close();
          inputStream = null;
          await feedFuture;

          doGC();
          await Future<void>.delayed(Duration.zero);
          doGC();

          expect(inputStreamTracker.isAlive, isFalse);
        });
      });
    });
  });
}
