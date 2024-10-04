// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: only_throw_errors

import 'dart:async';

import 'package:coverage/src/util.dart';
import 'package:test/test.dart';

const _failCount = 5;
const _delay = Duration(milliseconds: 10);

void main() {
  test('retry', () async {
    var count = 0;
    final stopwatch = Stopwatch()..start();

    Future failCountTimes() async {
      expect(stopwatch.elapsed, greaterThanOrEqualTo(_delay * count));

      while (count < _failCount) {
        count++;
        throw 'not yet!';
      }
      return 42;
    }

    final value = await retry(failCountTimes, _delay) as int;

    expect(value, 42);
    expect(count, _failCount);
    expect(stopwatch.elapsed, greaterThanOrEqualTo(_delay * count));
  });

  group('retry with timeout', () {
    test('if it finishes', () async {
      var count = 0;
      final stopwatch = Stopwatch()..start();

      Future failCountTimes() async {
        expect(stopwatch.elapsed, greaterThanOrEqualTo(_delay * count));

        while (count < _failCount) {
          count++;
          throw 'not yet!';
        }
        return 42;
      }

      final safeTimoutDuration = _delay * _failCount * 10;
      final value = await retry(
        failCountTimes,
        _delay,
        timeout: safeTimoutDuration,
      ) as int;

      expect(value, 42);
      expect(count, _failCount);
      expect(stopwatch.elapsed, greaterThanOrEqualTo(_delay * count));
    });

    test('if it does not finish', () async {
      var count = 0;
      final stopwatch = Stopwatch()..start();

      var caught = false;
      var countAfterError = 0;

      Future failCountTimes() async {
        if (caught) {
          countAfterError++;
        }
        expect(stopwatch.elapsed, greaterThanOrEqualTo(_delay * count));

        count++;
        throw 'never';
      }

      final unsafeTimeoutDuration = _delay * (_failCount / 2);

      try {
        await retry(failCountTimes, _delay, timeout: unsafeTimeoutDuration);
        // ignore: avoid_catching_errors
      } on StateError catch (e) {
        expect(e.message, 'Failed to complete within 25ms');
        caught = true;

        expect(countAfterError, 0,
            reason: 'Execution should stop after a timeout');

        await Future<dynamic>.delayed(_delay * 3);

        expect(countAfterError, 0, reason: 'Even after a delay');
      }

      expect(caught, isTrue);
    });
  });

  group('extractVMServiceUri', () {
    test('returns null when not found', () {
      expect(extractVMServiceUri('foo bar baz'), isNull);
    });

    test('returns null for an incorrectly formatted URI', () {
      const msg = 'Observatory listening on :://';
      expect(extractVMServiceUri(msg), null);
    });

    test('returns URI at end of string', () {
      const msg = 'Observatory listening on http://foo.bar:9999/';
      expect(extractVMServiceUri(msg), Uri.parse('http://foo.bar:9999/'));
    });

    test('returns URI with auth token at end of string', () {
      const msg = 'Observatory listening on http://foo.bar:9999/cG90YXRv/';
      expect(
          extractVMServiceUri(msg), Uri.parse('http://foo.bar:9999/cG90YXRv/'));
    });

    test('return URI embedded within string', () {
      const msg = '1985-10-26 Observatory listening on http://foo.bar:9999/ **';
      expect(extractVMServiceUri(msg), Uri.parse('http://foo.bar:9999/'));
    });

    test('return URI with auth token embedded within string', () {
      const msg =
          '1985-10-26 Observatory listening on http://foo.bar:9999/cG90YXRv/ **';
      expect(
          extractVMServiceUri(msg), Uri.parse('http://foo.bar:9999/cG90YXRv/'));
    });

    test('handles new Dart VM service message format', () {
      const msg =
          'The Dart VM service is listening on http://foo.bar:9999/cG90YXRv/';
      expect(
          extractVMServiceUri(msg), Uri.parse('http://foo.bar:9999/cG90YXRv/'));
    });
  });

  group('getIgnoredLines', () {
    const invalidSources = [
      '''final str = ''; // coverage:ignore-start
        final str = '';
        final str = ''; // coverage:ignore-start
        ''',
      '''final str = ''; // coverage:ignore-start
        final str = '';
        final str = ''; // coverage:ignore-start
        final str = ''; // coverage:ignore-end
        final str = '';
        final str = ''; // coverage:ignore-end
        ''',
      '''final str = ''; // coverage:ignore-start
        final str = '';
        final str = ''; // coverage:ignore-end
        final str = '';
        final str = ''; // coverage:ignore-end
        ''',
      '''final str = ''; // coverage:ignore-end
        final str = '';
        final str = ''; // coverage:ignore-start
        final str = '';
        final str = ''; // coverage:ignore-end
        ''',
      '''final str = ''; // coverage:ignore-end
        final str = '';
        final str = ''; // coverage:ignore-end
        ''',
      '''final str = ''; // coverage:ignore-end
        final str = '';
        final str = ''; // coverage:ignore-start
        ''',
      '''final str = ''; // coverage:ignore-end
        ''',
      '''final str = ''; // coverage:ignore-start
        ''',
    ];

    test('throws FormatException when the annotations are not balanced', () {
      void runTest(int index, String errMsg) {
        final content = invalidSources[index].split('\n');
        expect(
          () => getIgnoredLines('content-$index.dart', content),
          throwsA(
            allOf(
              isFormatException,
              predicate((FormatException e) => e.message == errMsg),
            ),
          ),
          reason: 'expected FormatException with message "$errMsg"',
        );
      }

      runTest(
        0,
        'coverage:ignore-start found at content-0.dart:'
        '3 before previous coverage:ignore-start ended',
      );
      runTest(
        1,
        'coverage:ignore-start found at content-1.dart:'
        '3 before previous coverage:ignore-start ended',
      );
      runTest(
        2,
        'unmatched coverage:ignore-end found at content-2.dart:5',
      );
      runTest(
        3,
        'unmatched coverage:ignore-end found at content-3.dart:1',
      );
      runTest(
        4,
        'unmatched coverage:ignore-end found at content-4.dart:1',
      );
      runTest(
        5,
        'unmatched coverage:ignore-end found at content-5.dart:1',
      );
      runTest(
        6,
        'unmatched coverage:ignore-end found at content-6.dart:1',
      );
      runTest(
        7,
        'coverage:ignore-start found at content-7.dart:'
        '1 has no matching coverage:ignore-end',
      );
    });

    test(
        'returns [[0,lines.length]] when the annotations are not '
        'balanced but the whole file is ignored', () {
      for (final content in invalidSources) {
        final lines = content.split('\n');
        lines.add(' // coverage:ignore-file');
        expect(getIgnoredLines('', lines), [
          [0, lines.length]
        ]);
      }
    });

    test('returns [[0,lines.length]] when the whole file is ignored', () {
      final lines = '''final str = ''; // coverage:ignore-start
      final str = ''; // coverage:ignore-end
      final str = ''; // coverage:ignore-file
      '''
          .split('\n');

      expect(getIgnoredLines('', lines), [
        [0, lines.length]
      ]);
    });

    test('return the correct range of lines ignored', () {
      final lines = '''
      final str = ''; // coverage:ignore-start
      final str = ''; // coverage:ignore-line
      final str = ''; // coverage:ignore-end
      final str = ''; // coverage:ignore-start
      final str = ''; // coverage:ignore-line
      final str = ''; // coverage:ignore-end
      '''
          .split('\n');

      expect(getIgnoredLines('', lines), [
        [1, 3],
        [4, 6],
      ]);
    });

    test('return the correct list of lines ignored', () {
      final lines = '''
      final str = ''; // coverage:ignore-line
      final str = ''; // coverage:ignore-line
      final str = ''; // coverage:ignore-line
      '''
          .split('\n');

      expect(getIgnoredLines('', lines), [
        [1, 1],
        [2, 2],
        [3, 3],
      ]);
    });

    test('ignore comments have no effect inside string literals', () {
      final lines = '''
      final str = '// coverage:ignore-file';
      final str = '// coverage:ignore-line';
      final str = ''; // coverage:ignore-line
      final str = '// coverage:ignore-start';
      final str = '// coverage:ignore-end';
      '''
          .split('\n');

      expect(getIgnoredLines('', lines), [
        [3, 3],
      ]);
    });

    test('allow white-space after ignore comments', () {
      // Using multiple strings, rather than splitting a multi-line string,
      // because many code editors remove trailing white-space.
      final lines = [
        "final str = ''; // coverage:ignore-start      ",
        "final str = ''; // coverage:ignore-line\t",
        "final str = ''; // coverage:ignore-end \t   \t   ",
        "final str = ''; // coverage:ignore-line     \t ",
        "final str = ''; // coverage:ignore-start    \t   ",
        "final str = ''; // coverage:ignore-end  \t    \t ",
      ];

      expect(getIgnoredLines('', lines), [
        [1, 3],
        [4, 4],
        [5, 6],
      ]);
    });

    test('allow omitting space after //', () {
      final lines = [
        "final str = ''; //coverage:ignore-start",
        "final str = ''; //coverage:ignore-line",
        "final str = ''; //coverage:ignore-end",
        "final str = ''; //coverage:ignore-line",
        "final str = ''; //coverage:ignore-start",
        "final str = ''; //coverage:ignore-end",
      ];

      expect(getIgnoredLines('', lines), [
        [1, 3],
        [4, 4],
        [5, 6],
      ]);
    });

    test('allow text after ignore comments', () {
      final lines = [
        "final str = ''; // coverage:ignore-start due to XYZ",
        "final str = ''; // coverage:ignore-line",
        "final str = ''; // coverage:ignore-end due to XYZ",
        "final str = ''; // coverage:ignore-line due to 123",
        "final str = ''; // coverage:ignore-start",
        "final str = ''; // coverage:ignore-end it is done",
      ];

      expect(getIgnoredLines('', lines), [
        [1, 3],
        [4, 4],
        [5, 6],
      ]);
    });
  });
}
