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
      'Non-existent constructorId throws NoSuchMethodError or JThrowable',
      () {
        final stringClass = JClass.forName('java/lang/String');
        expect(
          () => stringClass.constructorId('(I)V'),
          throwsA(
            anyOf(
              isA<NoSuchMethodError>().having(
                (e) => e.name,
                'name',
                '<init>',
              ),
              isA<JThrowable>(),
            ),
          ),
        );
        stringClass.release();
      },
    );

    testRunner(
      'Non-existent instanceMethodId throws NoSuchMethodError or JThrowable',
      () {
        final stringClass = JClass.forName('java/lang/String');
        expect(
          () => stringClass.instanceMethodId('nonExistentMethod', '()V'),
          throwsA(
            anyOf(
              isA<NoSuchMethodError>().having(
                (e) => e.name,
                'name',
                'nonExistentMethod',
              ),
              isA<JThrowable>(),
            ),
          ),
        );
        stringClass.release();
      },
    );

    testRunner(
      'Non-existent staticMethodId throws NoSuchMethodError or JThrowable',
      () {
        final stringClass = JClass.forName('java/lang/String');
        expect(
          () => stringClass.staticMethodId('nonExistentStaticMethod', '()V'),
          throwsA(
            anyOf(
              isA<NoSuchMethodError>().having(
                (e) => e.name,
                'name',
                'nonExistentStaticMethod',
              ),
              isA<JThrowable>(),
            ),
          ),
        );
        stringClass.release();
      },
    );

    testRunner(
      'Non-existent instanceFieldId throws NoSuchMethodError or JThrowable',
      () {
        final stringClass = JClass.forName('java/lang/String');
        expect(
          () => stringClass.instanceFieldId('nonExistentField', 'I'),
          throwsA(
            anyOf(
              isA<NoSuchMethodError>().having(
                (e) => e.name,
                'name',
                'nonExistentField',
              ),
              isA<JThrowable>(),
            ),
          ),
        );
        stringClass.release();
      },
    );

    testRunner(
      'Non-existent staticFieldId throws NoSuchMethodError or JThrowable',
      () {
        final stringClass = JClass.forName('java/lang/String');
        expect(
          () => stringClass.staticFieldId('nonExistentStaticField', 'I'),
          throwsA(
            anyOf(
              isA<NoSuchMethodError>().having(
                (e) => e.name,
                'name',
                'nonExistentStaticField',
              ),
              isA<JThrowable>(),
            ),
          ),
        );
        stringClass.release();
      },
    );
  });
}
