// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
library;

import 'dart:io';

import 'package:ffigen/src/code_generator/objc_built_in_functions.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() {
  group('Verify interface lists', () {
    late List<String> yamlInterfaces;
    late List<String> yamlStructs;
    late List<String> yamlEnums;

    setUpAll(() {
      final yaml =
          loadYaml(File('ffigen_objc.yaml').readAsStringSync()) as YamlMap;
      yamlInterfaces = ((yaml['objc-interfaces'] as YamlMap)['include']
              as YamlList)
          .map<String>((dynamic i) => i as String)
          .toList()
        ..sort();
      final structRenames = (yaml['structs'] as YamlMap)['rename'] as YamlMap;
      yamlStructs = ((yaml['structs'] as YamlMap)['include'] as YamlList)
          .map<String>(
              (dynamic name) => (structRenames[name] ?? name) as String)
          .toList()
        ..sort();
      yamlEnums = ((yaml['enums'] as YamlMap)['include'] as YamlList)
          .map<String>((dynamic i) => i as String)
          .toList()
        ..sort();
    });

    test('ObjCBuiltInFunctions.builtInInterfaces', () {
      expect(ObjCBuiltInFunctions.builtInInterfaces, yamlInterfaces);
    });

    test('ObjCBuiltInFunctions.builtInCompounds', () {
      expect(ObjCBuiltInFunctions.builtInCompounds, yamlStructs);
    });

    test('ObjCBuiltInFunctions.builtInEnums', () {
      expect(ObjCBuiltInFunctions.builtInEnums, yamlEnums);
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

    test('package:objective_c exports all the enums', () {
      final exportFile = File('lib/objective_c.dart').readAsStringSync();
      for (final enum_ in yamlEnums) {
        expect(exportFile, contains(enum_));
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

    test('All code genned enums are included in the list', () {
      final enumNameRegExp = RegExp(r'^enum (\w+) {');
      final allEnumNames = <String>[];
      for (final line in File('lib/src/objective_c_bindings_generated.dart')
          .readAsLinesSync()) {
        final match = enumNameRegExp.firstMatch(line);
        if (match != null) {
          allEnumNames.add(match[1]!);
        }
      }
      allEnumNames.sort();
      expect(allEnumNames, yamlEnums);
    });
  });
}
