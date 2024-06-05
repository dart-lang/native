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
    late List<String> yamlStructs;

    setUpAll(() {
      final yaml = loadYaml(File('ffigen_objc.yaml').readAsStringSync());
      yamlInterfaces = yaml['objc-interfaces']['include']
          .map<String>((dynamic i) => i as String)
          .toList() as List<String>
        ..sort();
      final structRenames = yaml['structs']['rename'];
      yamlStructs = yaml['structs']['include']
          .map<String>(
              (dynamic name) => (structRenames[name] ?? name) as String)
          .toList() as List<String>
        ..sort();
    });

    test('ObjCBuiltInFunctions.builtInInterfaces', () {
      expect(ObjCBuiltInFunctions.builtInInterfaces, yamlInterfaces);
    });

    test('ObjCBuiltInFunctions.builtInStructs', () {
      expect(ObjCBuiltInFunctions.builtInCompounds, yamlStructs);
    });

    test('package:objective_c exports all the interfaces', () {
      final exportFile = File('lib/objective_c.dart').readAsStringSync();
      for (final intf in yamlInterfaces) {
        expect(exportFile, contains(intf));
      }
    });

    test('package:objective_c exports all the structs', () {
      final exportFile = File('lib/objective_c.dart').readAsStringSync();
      for (final struct in yamlStructs) {
        expect(exportFile, contains(struct));
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

    test('All code genned structs are included in the list', () {
      final structNameRegExp =
          RegExp(r'^final class (\w+) extends ffi\.Struct');
      final allStructNames = <String>[];
      for (final line in File('lib/src/objective_c_bindings_generated.dart')
          .readAsLinesSync()) {
        final match = structNameRegExp.firstMatch(line);
        if (match != null) {
          allStructNames.add(match[1]!);
        }
      }
      allStructNames.sort();
      expect(allStructNames, yamlStructs);
    });
  });
}
