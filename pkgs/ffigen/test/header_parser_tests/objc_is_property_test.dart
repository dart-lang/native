// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
library;

import 'package:ffigen/ffigen.dart';
import 'package:ffigen/src/code_generator.dart' as cg;
import 'package:ffigen/src/header_parser.dart' as parser;
import 'package:test/test.dart';

import '../test_utils.dart';

const _interfaces = {
  'IsPropertyInterface',
  'IsPropertyParent',
  'IsPropertyChild',
  'IsPropertyBothParent',
  'IsPropertyBothChild',
};

void main() {
  group('ObjCMethod.isProperty', () {
    late cg.Library library;
    final visited = <String, ObjCMethod>{};

    setUpAll(() {
      library = parser.parse(
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
                Uri.file(
                  absPath('test/header_parser_tests/objc_is_property.h'),
                ),
              ],
            ),
            objectiveC: const ObjectiveC(),
            visitors: [
              Visitor(
                objCInterface: (node) =>
                    node.isIncluded = _interfaces.contains(node.originalName),
                objCMethod: (node) {
                  final parent = node.parent;
                  if (parent is! ObjCInterface ||
                      !_interfaces.contains(parent.originalName)) {
                    return;
                  }
                  visited['${parent.originalName}.${node.selector}'] = node;
                  // Only the child's property, not the parent's.
                  if (parent.originalName == 'IsPropertyChild' &&
                      node.selector == 'overridden') {
                    node.isProperty = false;
                  }
                  // Both the parent's and the child's property.
                  if (parent.originalName.startsWith('IsPropertyBoth') &&
                      node.selector == 'setOverridden:') {
                    node.isProperty = false;
                  }
                },
              ),
            ],
          ),
        ),
      );
    });

    cg.ObjCMethod methodOf(String interface, String selector) => library
        .bindings
        .whereType<cg.ObjCInterface>()
        .firstWhere((itf) => itf.originalName == interface)
        .methods
        .firstWhere((m) => m.originalName == selector);

    cg.ObjCMethodKind kindOf(String interface, String selector) =>
        methodOf(interface, selector).kind;

    test('is true only for property accessors', () {
      expect(visited['IsPropertyInterface.value']!.isProperty, isTrue);
      expect(visited['IsPropertyInterface.plainMethod']!.isProperty, isFalse);
    });

    test('cannot turn a method into a property', () {
      final method = visited['IsPropertyInterface.plainMethod']!;
      method.isProperty = false; // No-op.
      expect(method.isProperty, isFalse);
      expect(() => method.isProperty = true, throwsArgumentError);
    });

    test('does not change overrides elsewhere in the hierarchy', () {
      expect(kindOf('IsPropertyChild', 'overridden'), cg.ObjCMethodKind.method);
      expect(
        kindOf('IsPropertyChild', 'setOverridden:'),
        cg.ObjCMethodKind.method,
      );

      // The parent's property, which those methods override, is still a
      // property.
      expect(
        kindOf('IsPropertyParent', 'overridden'),
        cg.ObjCMethodKind.propertyGetter,
      );
      expect(
        kindOf('IsPropertyParent', 'setOverridden:'),
        cg.ObjCMethodKind.propertySetter,
      );
    });

    test('overriding setters converted together keep the same name', () {
      final parentSetter = methodOf('IsPropertyBothParent', 'setOverridden:');
      final childSetter = methodOf('IsPropertyBothChild', 'setOverridden:');
      expect(parentSetter.kind, cg.ObjCMethodKind.method);
      expect(childSetter.kind, cg.ObjCMethodKind.method);
      expect(childSetter.symbol, same(parentSetter.symbol));
    });
  });
}
