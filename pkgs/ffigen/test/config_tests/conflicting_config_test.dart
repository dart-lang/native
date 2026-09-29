// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/ffigen.dart';
import 'package:test/test.dart';

void main() {
  group('conflicting_config_test', () {
    test(
      'Throws AssertionError when both cpp and objectiveC are specified',
      () {
        expect(
          () => FfiGenerator(
            output: Output(dart: DartOutput(path: Uri.file('unused'))),
            cpp: const Cpp(),
            objectiveC: const ObjectiveC(),
          ),
          throwsA(
            isA<AssertionError>().having(
              (e) => e.message,
              'message',
              contains('Cannot use C++ and Objective-C together'),
            ),
          ),
        );
      },
    );
  });
}
