// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
library;

import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:objective_c/objective_c.dart';
import 'package:objective_c/src/objective_c_bindings_generated.dart';
import 'package:test/test.dart';

Future<(int, Uint8List, bool, NSStreamStatus, NSError?)> read(
    NSInputStream stream, int size) {
  return Isolate.run(() => using((arena) {
        final buffer = arena<Uint8>(size);
        print('Starting read: $size');
        final readSize = stream.read_maxLength_(buffer, size);
        print('Read complete');
        final data = Uint8List.fromList(
            buffer.asTypedList(readSize == -1 ? 0 : readSize));
        return (
          readSize,
          data,
          stream.hasBytesAvailable,
          stream.streamStatus,
          stream.streamError,
        );
      }));
}

void main() {
  group('NSInputStream', () {
    setUpAll(() {
      // TODO(https://github.com/dart-lang/native/issues/1068): Remove this.
      DynamicLibrary.open('test/objective_c.dylib');
    });

    group('toNSInputStream', () {
      group('empty', () {
        late NSInputStream inputStream;

        setUp(() {
          inputStream = const Stream<List<int>>.empty().toNSInputStream();
        });

        test('initial state', () {
          expect(
              inputStream.streamStatus, NSStreamStatus.NSStreamStatusNotOpen);
          expect(inputStream.streamError, null);
        });

        test('open', () {
          inputStream.open();
          expect(inputStream.streamStatus, NSStreamStatus.NSStreamStatusOpen);
          expect(inputStream.streamError, null);
        });

        test('read', () async {
          inputStream.open();
          final (count, data, hasBytesAvailable, status, error) =
              await read(inputStream, 10);
          expect(count, 0);
          expect(data, isEmpty);
          expect(hasBytesAvailable, false);
          expect(status, NSStreamStatus.NSStreamStatusAtEnd);
          expect(error, isNull);
          inputStream.close();
        });

        test('read without open', () async {
          final (count, data, hasBytesAvailable, status, error) =
              await read(inputStream, 10);
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
            [4, 5, 6]
          ]).toNSInputStream();
        });

        test('initial state', () {
          expect(
              inputStream.streamStatus, NSStreamStatus.NSStreamStatusNotOpen);
          expect(inputStream.streamError, null);
        });

        test('open', () {
          inputStream.open();
          expect(inputStream.streamStatus, NSStreamStatus.NSStreamStatusOpen);
          expect(inputStream.streamError, null);
        });

        test('partial read', () async {
          inputStream.open();
          final (count, data, hasBytesAvailable, status, error) =
              await read(inputStream, 5);
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
            final (count, data, hasBytesAvailable, status, error) =
                await read(inputStream, 6);
            print('${(count, data, hasBytesAvailable, status, error)}');
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
          final (count, data, hasBytesAvailable, status, error) =
              await read(inputStream, 10);
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

      test('partial read', () async {
        inputStream.open();
        final (count, data, hasBytesAvailable, status, error) =
            await read(inputStream, 100000);
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
          final (count, data, hasBytesAvailable, status, error) =
              await read(inputStream, Random.secure().nextInt(100000));

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
      }()
          .toNSInputStream();

      inputStream.open();
      final (count1, data1, hasBytesAvailable1, status1, error1) =
          await read(inputStream, 10);
      expect(count1, 2);
      expect(data1, [1, 2]);
      expect(hasBytesAvailable1, true);
      expect(status1, NSStreamStatus.NSStreamStatusOpen);
      expect(error1, isNull);

      final (count2, _, hasBytesAvailable2, status2, error2) =
          await read(inputStream, 10);
      expect(count2, -1);
      expect(hasBytesAvailable2, false);
      expect(status2, NSStreamStatus.NSStreamStatusError);
      expect(
          error2,
          isA<NSError>()
              .having((e) => e.localizedDescription.toString(),
                  'localizedDescription', contains('some exception message'))
              .having((e) => e.domain.toString(), 'domain', 'DartError'));
    });
  });
}
