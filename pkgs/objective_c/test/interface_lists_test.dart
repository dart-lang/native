// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
library;

import 'dart:io';

import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() {
  group('Verify interface lists', () {
    late List<String> yamlInterfaces;
    late List<String> yamlStructs;
    late List<String> yamlEnums;
    late List<String> yamlProtocols;
    late List<String> yamlCategories;

    setUpAll(() {
      final yaml =
          loadYaml(File('ffigen_objc.yaml').readAsStringSync()) as YamlMap;

      final interfaceRenames =
          (yaml['objc-interfaces'] as YamlMap)['rename'] as YamlMap;
      yamlInterfaces = ((yaml['objc-interfaces'] as YamlMap)['include']
              as YamlList)
          .map<String>(
              (dynamic name) => (interfaceRenames[name] ?? name) as String)
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

      final protocolRenames =
          (yaml['objc-protocols'] as YamlMap)['rename'] as YamlMap;
      yamlProtocols = ((yaml['objc-protocols'] as YamlMap)['include']
              as YamlList)
          .map<String>(
              (dynamic name) => (protocolRenames[name] ?? name) as String)
          .toList()
        ..sort();

      yamlCategories = ((yaml['objc-categories'] as YamlMap)['include']
              as YamlList)
          .map<String>((dynamic i) => i as String)
          .toList()
        ..sort();
    });

    test('All code genned interfaces are included in the list', () {
      final classNameRegExp = RegExp(r'^class ([^_]\w*) ');
      final allClassNames = <String>[];
      for (final line in File('lib/src/objective_c_bindings_generated.dart')
          .readAsLinesSync()) {
        final match = classNameRegExp.firstMatch(line);
        if (match != null) {
          allClassNames.add(match[1]!);
        }
      }
      allClassNames.sort();
      expect(allClassNames, yamlInterfaces);
    });

    test('All code genned structs are included in the list', () {
      final structNameRegExp =
          RegExp(r'^final class (\w+) extends ffi\.(Struct|Opaque)');
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
      expect(allEnumNames, unorderedEquals(yamlEnums));
    });

    test('All code genned protocols are included in the list', () {
      final protocolNameRegExp = RegExp(r'^interface class (\w+) ');
      final allProtocolNames = <String>[];
      for (final line in File('lib/src/objective_c_bindings_generated.dart')
          .readAsLinesSync()) {
        final match = protocolNameRegExp.firstMatch(line);
        if (match != null) {
          allProtocolNames.add(match[1]!);
        }
      }
      expect(allProtocolNames, unorderedEquals(yamlProtocols));
    });

    test('All code genned categories are included in the list', () {
      final categoryNameRegExp = RegExp(r'^extension (\w+) on \w+ {');
      final allCategoryNames = <String>[];
      for (final line in File('lib/src/objective_c_bindings_generated.dart')
          .readAsLinesSync()) {
        final match = categoryNameRegExp.firstMatch(line);
        if (match != null) {
          allCategoryNames.add(match[1]!);
        }
      }
      expect(allCategoryNames, unorderedEquals(yamlCategories));
    });

    test('No stubs', () {
      final stubRegExp = RegExp(r'\Wstub\W');
      final bindings = File('lib/src/objective_c_bindings_generated.dart')
          .readAsLinesSync()
          .where(stubRegExp.hasMatch)
          .toList();
      expect(bindings, <String>[]);
    });
  });
}
