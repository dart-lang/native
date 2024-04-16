// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')

import 'dart:io';

import 'package:ffigen/src/code_generator/objc_built_in_functions.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() {
  group('Verify interface lists', () {
    late List<String> yamlInterfaces;
    setUpAll(() {
      final yaml = loadYaml(File('ffigen_objc.yaml').readAsStringSync());
      yamlInterfaces = yaml['objc-interfaces']['include']
          .map<String>((dynamic i) => i as String)
          .toList() as List<String>
          ..sort();
    });

    test('ObjCBuiltInFunctions.builtInInterfaces', () {
      expect(ObjCBuiltInFunctions.builtInInterfaces, yamlInterfaces);
    });

    test('package:objective_c exports all the interfaces', () {
      final exportFile = File('lib/objective_c.dart').readAsStringSync();
      for (final intf in yamlInterfaces) {
        expect(exportFile, contains(intf));
      }
    });

    test('All code genned interfaces are included in the list', () {
      final classNameRegExp = RegExp(r'^class (\w+) ');
      final allClassNames = <String>[];
      for (final line in File('lib/src/objective_c_bindings_generated.dart')
          .readAsLinesSync()) {
        final match = classNameRegExp.firstMatch(line);
        if (match != null) {
          final className = match[1]!;
          if (!className.startsWith('ObjCBlock')) {
            allClassNames.add(className);
          }
        }
      }
      allClassNames.sort();
      expect(allClassNames, yamlInterfaces);
    });
  });
}
