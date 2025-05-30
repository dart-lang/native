// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
library;

import 'dart:io';

import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

import '../../ffigen/lib/src/code_generator/objc_built_in_types.dart';

// The default expect error message for sets isn't very useful. In the common
// case where the sets are different lengths, the default matcher just says the
// lengths don't match. This function says exactly what the difference is.
void expectSetsEqual(String name, Set<String> expected, Set<String> actual) {
  expect(expected.difference(actual), <String>{},
      reason: 'Found elements that are missing from $name');
  expect(actual.difference(expected), <String>{},
      reason: "Found extra elements that shouldn't be in $name");
}

void main() {
  group('Verify interface lists', () {
    late final List<String> bindings;
    setUpAll(() {
      bindings = File('lib/src/objective_c_bindings_generated.dart')
          .readAsLinesSync()
          .toList();
    });

    Set<String> findBindings(RegExp re) =>
        bindings.map(re.firstMatch).nonNulls.map((match) => match[1]!).toSet();

    test('All code genned interfaces are included in the list', () {
      final allClassNames = findBindings(RegExp(r'^class ([^_]\w*) '));
      expectSetsEqual('generated classes', objCBuiltInInterfaces.values.toSet(),
          allClassNames);
    });

    test('All code genned structs are included in the list', () {
      final allStructNames = findBindings(
          RegExp(r'^final class (\w+) extends ffi\.(Struct|Opaque)'));
      expectSetsEqual('generated structs', objCBuiltInCompounds.values.toSet(),
          allStructNames);
    });

    test('All code genned enums are included in the list', () {
      final allEnumNames = findBindings(RegExp(r'^enum (\w+) {'));
      expectSetsEqual('generated enums', objCBuiltInEnums, allEnumNames);
    });

    test('All code genned protocols are included in the list', () {
      final allProtocolNames = findBindings(RegExp(r'^interface class (\w+) '));
      expectSetsEqual('generated protocols',
          objCBuiltInProtocols.values.toSet(), allProtocolNames);
    });

    test('All code genned categories are included in the list', () {
      final allCategoryNames =
          findBindings(RegExp(r'^extension (\w+) on \w+ {'));
      expectSetsEqual(
          'generated categories', objCBuiltInCategories, allCategoryNames);
    });

    test('No stubs', () {
      final stubRegExp = RegExp(r'\Wstub\W');
      expect(bindings.where(stubRegExp.hasMatch).toList(), <String>[]);
    });
  });
}
