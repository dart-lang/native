import 'dart:io';
import 'dart:isolate';

import 'package:jni/jni.dart';
import 'package:test/test.dart';

import 'test_util/test_util.dart';

void main() {
  if (!Platform.isAndroid) {
    checkDylibIsUpToDate();
    spawnJvm();
  }

  test('Debug mode captures stack trace on double release', () {
    Jni.captureStackTraceOnRelease = true;
    addTearDown(() {
      Jni.captureStackTraceOnRelease = false;
    });

    final s = 'hello'.toJString();
    s.release();

    expect(
      s.release,
      throwsA(
        isA<DoubleReleaseError>().having(
          (e) => e.toString(),
          'toString()',
          assertsEnabled
              ? allOf(
                  contains('Object was released at:'),
                  contains('debug_release_test.dart'),
                )
              : contains('set `Jni.captureStackTraceOnRelease = true`'),
        ),
      ),
    );
  });

  test('Debug mode captures stack trace on use after release', () {
    Jni.captureStackTraceOnRelease = true;
    addTearDown(() {
      Jni.captureStackTraceOnRelease = false;
    });

    final s = 'hello'.toJString();
    s.release();

    expect(
      s.toDartString,
      throwsA(
        isA<UseAfterReleaseError>().having(
          (e) => e.toString(),
          'toString()',
          assertsEnabled
              ? allOf(
                  contains('Object was released at:'),
                  contains('debug_release_test.dart'),
                )
              : contains('set `Jni.captureStackTraceOnRelease = true`'),
        ),
      ),
    );
  });

  test('Debug mode captures arena stack trace', () {
    Jni.captureStackTraceOnRelease = true;
    addTearDown(() {
      Jni.captureStackTraceOnRelease = false;
    });

    final s = 'hello'.toJString();

    s.release();
    using(s.releasedBy);
    using(s.releasedBy);

    final expectedMessage = assertsEnabled
        ? allOf(
            stringContainsInOrder([
              'Object was released at:',
              'Object was registered to be released',
              'Object was registered to be released',
            ]),
            contains('debug_release_test.dart'),
          )
        : contains('set `Jni.captureStackTraceOnRelease = true`');

    expect(
      s.toDartString,
      throwsA(
        isA<UseAfterReleaseError>().having(
          (e) => e.toString(),
          'toString()',
          expectedMessage,
        ),
      ),
    );
    expect(
      s.release,
      throwsA(
        isA<DoubleReleaseError>().having(
          (e) => e.toString(),
          'toString()',
          expectedMessage,
        ),
      ),
    );
  });

  test('registeredInArena is safe when asserts are disabled', () {
    Jni.captureStackTraceOnRelease = true;
    addTearDown(() {
      Jni.captureStackTraceOnRelease = false;
    });

    final s = 'hello'.toJString();
    (s.reference as JGlobalReference).registeredInArena();
    s.release();

    expect(
      s.toDartString,
      throwsA(
        isA<UseAfterReleaseError>().having(
          (e) => e.toString(),
          'toString()',
          assertsEnabled
              ? stringContainsInOrder([
                  'Object was registered to be released',
                  'Object was released at:',
                ])
              : contains('set `Jni.captureStackTraceOnRelease = true`'),
        ),
      ),
    );
  });

  test('Hint is shown when debug mode is disabled', () {
    Jni.captureStackTraceOnRelease = false;

    final s = 'hello'.toJString();
    s.release();

    expect(
      s.release,
      throwsA(
        isA<DoubleReleaseError>().having(
          (e) => e.toString(),
          'toString()',
          contains('set `Jni.captureStackTraceOnRelease = true`'),
        ),
      ),
    );
    expect(
      s.toDartString,
      throwsA(
        isA<UseAfterReleaseError>().having(
          (e) => e.toString(),
          'toString()',
          contains('set `Jni.captureStackTraceOnRelease = true`'),
        ),
      ),
    );
  });

  test('Debug mode flag is shared across isolates', () async {
    Jni.captureStackTraceOnRelease = true;
    addTearDown(() {
      Jni.captureStackTraceOnRelease = false;
    });

    final isEnabled = await Isolate.run(() {
      return Jni.captureStackTraceOnRelease;
    });

    expect(isEnabled, isTrue);

    Jni.captureStackTraceOnRelease = false;

    final isEnabled2 = await Isolate.run(() {
      return Jni.captureStackTraceOnRelease;
    });

    expect(isEnabled2, isFalse);
  });

  test('Debug mode captures stack trace in another isolate', () async {
    Jni.captureStackTraceOnRelease = true;
    addTearDown(() {
      Jni.captureStackTraceOnRelease = false;
    });

    final errorString = await Isolate.run(() {
      final s = 'hello'.toJString();
      s.release();
      try {
        s.release();
      } on Object catch (e) {
        if (e is DoubleReleaseError) {
          return e.toString();
        }
        rethrow;
      }
      throw StateError('Expected DoubleReleaseError');
    });

    expect(
      errorString,
      assertsEnabled
          ? contains('Object was released at:')
          : contains('set `Jni.captureStackTraceOnRelease = true`'),
    );
  });

  test(
      'Debug mode captures stack trace from another isolate'
      ' (cross-isolate release)', () async {
    Jni.captureStackTraceOnRelease = true;
    addTearDown(() {
      Jni.captureStackTraceOnRelease = false;
    });

    final s = 'hello'.toJString();

    s.release();

    final (isReleased, doubleReleaseError, useAfterReleaseError) =
        await Isolate.run(() {
      String? doubleReleaseError;
      String? useAfterReleaseError;
      try {
        s.release();
      } on Object catch (e) {
        if (e is! DoubleReleaseError) rethrow;
        doubleReleaseError = e.toString();
      }

      try {
        s.toString();
      } on Object catch (e) {
        if (e is! UseAfterReleaseError) rethrow;
        useAfterReleaseError = e.toString();
      }
      return (s.isReleased, doubleReleaseError, useAfterReleaseError);
    });

    final expectedMessage = assertsEnabled
        ? contains('Object was released at:')
        : contains('set `Jni.captureStackTraceOnRelease = true`');
    expect(isReleased, isTrue);
    expect(doubleReleaseError, expectedMessage);
    expect(useAfterReleaseError, expectedMessage);
  });
}
