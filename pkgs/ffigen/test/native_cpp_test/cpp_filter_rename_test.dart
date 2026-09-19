// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../test_utils.dart';
import 'cpp_filter_rename_test_bindings.dart';

void main() {
  group('cpp_filter_rename_test', () {
    test('renamed class and method exist and are accessible', () {
      expect(MyWidget, isNotNull);
      final widget = MyWidget.fromPointer(nullptr);
      expect(widget.greet, isNotNull);
    });

    test(
      'filtered out class and method are omitted from generated bindings',
      () {
        final bindingsFile = File(
          path.join(
            packagePathForTests,
            'test',
            'native_cpp_test',
            'cpp_filter_rename_test_bindings.dart',
          ),
        );
        final content = bindingsFile.readAsStringSync();

        expect(content, contains('class MyWidget'));
        expect(content, contains('void greet()'));

        expect(content, isNot(contains('FilteredOutClass')));
        expect(content, isNot(contains('filteredMethod')));
      },
    );
  });
}
