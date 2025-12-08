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

    try {
      s.release();
      // ignore: avoid_catching_errors
    } on DoubleReleaseError catch (e) {
      expect(e.toString(), contains('Object was released at:'));
      expect(e.toString(), contains('debug_release_test.dart'));
    }
  });

  test('Debug mode captures stack trace on use after release', () {
    Jni.captureStackTraceOnRelease = true;
    addTearDown(() {
      Jni.captureStackTraceOnRelease = false;
    });

    final s = 'hello'.toJString();
    s.release();

    try {
      s.toDartString();
      // ignore: avoid_catching_errors
    } on UseAfterReleaseError catch (e) {
      expect(e.toString(), contains('Object was released at:'));
      expect(e.toString(), contains('debug_release_test.dart'));
    }
  });

  test('Hint is shown when debug mode is disabled', () {
    Jni.captureStackTraceOnRelease = false;

    final s = 'hello'.toJString();
    s.release();

    try {
      s.release();
      // ignore: avoid_catching_errors
    } on DoubleReleaseError catch (e) {
      expect(e.toString(),
          contains('set `Jni.captureStackTraceOnRelease = true`'));
    }
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

    await Isolate.run(() {
      final s = 'hello'.toJString();
      s.release();
      try {
        s.release();
        // ignore: avoid_catching_errors
      } on DoubleReleaseError catch (e) {
        if (!e.toString().contains('Object was released at:')) {
          throw StateError('Stack trace not captured in isolate');
        }
      }
    });
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
        // ignore: avoid_catching_errors
      } on DoubleReleaseError catch (e) {
        doubleReleaseError = e.toString();
      }

      try {
        s.toString();
        // ignore: avoid_catching_errors
      } on UseAfterReleaseError catch (e) {
        useAfterReleaseError = e.toString();
      }
      return (s.isReleased, doubleReleaseError, useAfterReleaseError);
    });

    expect(isReleased, isTrue);
    expect(doubleReleaseError, contains('Object was released at:'));
    expect(useAfterReleaseError, contains('Object was released at:'));
  });
}
