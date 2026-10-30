// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
library;

import 'package:ffigen/ffigen.dart';
import 'package:ffigen/src/header_parser.dart' as parser;
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  test('ObjCMethod.isProperty only converts properties to methods', () {
    final seen = <String, Object?>{};
    parser.parse(
      testContext(
        FfiGenerator(
          output: Output(
            dart: DartOutput(path: Uri.file('unused')),
            style: const NativeExternalBindings(
              assetId: 'package:ffigen/objc_test',
            ),
          ),
          input: Input(
            entryPoints: [
              Uri.file(absPath('test/header_parser_tests/objc_is_property.h')),
            ],
          ),
          objectiveC: const ObjectiveC(),
          visitors: [
            Visitor(
              objCInterface: (node) =>
                  node.isIncluded = node.originalName == 'IsPropertyInterface',
              objCMethod: (node) {
                final parent = node.parent;
                if (parent is! ObjCInterface ||
                    parent.originalName != 'IsPropertyInterface') {
                  return;
                }
                if (node.selector == 'plainMethod') {
                  expect(node.isProperty, isFalse);
                  node.isProperty = false;
                  expect(node.isProperty, isFalse);
                  expect(
                    () => node.isProperty = true,
                    throwsA(isA<ArgumentError>()),
                  );
                  seen['plainDone'] = true;
                } else if (node.selector == 'value') {
                  expect(node.isProperty, isTrue);
                  node.isProperty = true; // No-op.
                  expect(node.isProperty, isTrue);
                  seen['property'] = true;
                }
              },
            ),
          ],
        ),
      ),
    );
    expect(seen['plainDone'], isTrue);
    expect(seen['property'], isTrue);
  });
}
