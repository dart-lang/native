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

const privateObjectiveCClasses = ['DartInputStreamAdapter'];

void main() {
  group('Verify interface lists', () {
    late List<String> yamlInterfaces;
    late List<String> yamlStructs;
    late List<String> yamlEnums;
    late List<String> yamlProtocols;

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
      yamlProtocols = ((yaml['objc-protocols'] as YamlMap)['include']
              as YamlList)
          .map<String>((dynamic i) => i as String)
          .toList()
        ..sort();
    });

    test('ObjCBuiltInFunctions.builtInInterfaces', () {
      expect(ObjCBuiltInFunctions.builtInInterfaces, yamlInterfaces);
    });

    test('ObjCBuiltInFunctions.builtInCompounds', () {
      expect(ObjCBuiltInFunctions.builtInCompounds.values, yamlStructs);
    });

    test('ObjCBuiltInFunctions.builtInEnums', () {
      expect(ObjCBuiltInFunctions.builtInEnums, yamlEnums);
    });

    test('ObjCBuiltInFunctions.builtInProtocols', () {
      expect(ObjCBuiltInFunctions.builtInProtocols, yamlProtocols);
    });

    test('package:objective_c exports all the interfaces', () {
      final exportFile = File('lib/objective_c.dart').readAsStringSync();
      for (final intf in yamlInterfaces) {
        if (!privateObjectiveCClasses.contains(intf)) {
          expect(exportFile, contains(RegExp('\\W$intf\\W')));
        }
      }
    });

    test('package:objective_c exports all the structs', () {
      final exportFile = File('lib/objective_c.dart').readAsStringSync();
      for (final struct in yamlStructs) {
        expect(exportFile, contains(RegExp('\\W$struct\\W')));
      }
    });

    test('package:objective_c exports all the enums', () {
      final exportFile = File('lib/objective_c.dart').readAsStringSync();
      for (final enum_ in yamlEnums) {
        expect(exportFile, contains(RegExp('\\W$enum_\\W')));
      }
    });

    test('package:objective_c exports all the protocols', () {
      final exportFile = File('lib/objective_c.dart').readAsStringSync();
      for (final protocol in yamlProtocols) {
        expect(exportFile, contains(RegExp('\\W$protocol\\W')));
      }
    });

    test('All code genned interfaces are included in the list', () {
      final classNameRegExp = RegExp(r'^class (\w+) ');
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
      expect(allEnumNames, unorderedEquals(yamlEnums));
    });

    test('All code genned protocols are included in the list', () {
      final protocolNameRegExp =
          RegExp(r'^abstract final class (?!ObjCBlock_)(\w+) {');
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
  });
}
