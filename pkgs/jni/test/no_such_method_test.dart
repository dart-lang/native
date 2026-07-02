// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:jni/jni.dart';
import 'package:test/test.dart';

import 'test_util/test_util.dart';

void main() {
  if (!Platform.isAndroid) {
    checkDylibIsUpToDate();
    spawnJvm();
  }
  run(testRunner: test);
}

void run({required TestRunnerCallback testRunner}) {
  group('Method, Field, and Constructor Lookup Failure Tests', () {
    testRunner(
      'Non-existent constructorId throws java.lang.NoSuchMethodError',
      () {
        final stringClass = JClass.forName('java/lang/String');
        // java.lang.String does not have a (I)V constructor (new String(int))
        expect(
          () => stringClass.constructorId('(I)V'),
          throwsA(
            isA<JThrowable>().having(
              (e) => e.toString(),
              'toString()',
              contains('java.lang.NoSuchMethodError'),
            ),
          ),
        );
        stringClass.release();
      },
    );

    testRunner(
      'Non-existent instanceMethodId throws java.lang.NoSuchMethodError',
      () {
        final stringClass = JClass.forName('java/lang/String');
        expect(
          () => stringClass.instanceMethodId('nonExistentMethod', '()V'),
          throwsA(
            isA<JThrowable>().having(
              (e) => e.toString(),
              'toString()',
              contains('java.lang.NoSuchMethodError'),
            ),
          ),
        );
        stringClass.release();
      },
    );

    testRunner(
      'Non-existent staticMethodId throws java.lang.NoSuchMethodError',
      () {
        final stringClass = JClass.forName('java/lang/String');
        expect(
          () => stringClass.staticMethodId('nonExistentStaticMethod', '()V'),
          throwsA(
            isA<JThrowable>().having(
              (e) => e.toString(),
              'toString()',
              contains('java.lang.NoSuchMethodError'),
            ),
          ),
        );
        stringClass.release();
      },
    );

    testRunner(
      'Non-existent instanceFieldId throws java.lang.NoSuchFieldError',
      () {
        final stringClass = JClass.forName('java/lang/String');
        expect(
          () => stringClass.instanceFieldId('nonExistentField', 'I'),
          throwsA(
            isA<JThrowable>().having(
              (e) => e.toString(),
              'toString()',
              contains('java.lang.NoSuchFieldError'),
            ),
          ),
        );
        stringClass.release();
      },
    );

    testRunner(
      'Non-existent staticFieldId throws java.lang.NoSuchFieldError',
      () {
        final stringClass = JClass.forName('java/lang/String');
        expect(
          () => stringClass.staticFieldId('nonExistentStaticField', 'I'),
          throwsA(
            isA<JThrowable>().having(
              (e) => e.toString(),
              'toString()',
              contains('java.lang.NoSuchFieldError'),
            ),
          ),
        );
        stringClass.release();
      },
    );
  });
}
