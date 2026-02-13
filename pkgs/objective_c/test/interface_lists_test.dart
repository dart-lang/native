// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
library;

import 'dart:io';

import 'package:ffigen/src/code_generator/objc_built_in_types.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'util.dart';

// The default expect error message for sets isn't very useful. In the common
// case where the sets are different lengths, the default matcher just says the
// lengths don't match. This function says exactly what the difference is.
void expectSetsEqual(String name, Set<String> expected, Set<String> actual) {
  expect(
    expected.difference(actual),
    <String>{},
    reason: 'Found elements that are missing from $name',
  );
  expect(
    actual.difference(expected),
    <String>{},
    reason: "Found extra elements that shouldn't be in $name",
  );
}

void mergeLinewithNext(List<String> lines, String toMerge) {
  final i = lines.indexOf(toMerge);
  lines[i] += lines.removeAt(i + 1);
}

void main() {
  group('Verify interface lists', () {
    late final List<String> bindings;
    setUpAll(() {
      bindings = File(
        p.join(pkgDir, 'lib', 'src', 'objective_c_bindings_generated.dart'),
      ).readAsLinesSync().toList();

      // HACK: NSAttributedStringMarkdownParsingOptions is such a long class
      // name that its definition wraps, and the regex doesn't match. So find
      // that line and merge it with the following one.
      mergeLinewithNext(
        bindings,
        'extension type NSAttributedStringMarkdownParsingOptions._(',
      );
    });

    Set<String> findBindings(RegExp re) =>
        bindings.map(re.firstMatch).nonNulls.map((match) => match[1]!).toSet();

    test('All code genned interfaces are included in the list', () {
      final allClassNames = findBindings(
        RegExp(r'^extension type ([^_]\w*)\._\( *objc\.ObjCObject '),
      );
      expectSetsEqual(
        'generated classes',
        objCBuiltInInterfaces.values.toSet(),
        allClassNames,
      );
    });

    test('All code genned structs are included in the list', () {
      final allStructNames = findBindings(
        RegExp(r'^final class (\w+) extends ffi\.(Struct|Opaque)'),
      );
      expectSetsEqual(
        'generated structs',
        objCBuiltInCompounds.values.toSet(),
        allStructNames,
      );
    });

    test('All code genned enums are included in the list', () {
      final allEnumNames = findBindings(
        RegExp(r'^(?:enum|sealed class) (\w+) {'),
      );
      expectSetsEqual('generated enums', objCBuiltInEnums, allEnumNames);
    });

    test('All code genned protocols are included in the list', () {
      final allProtocolNames = findBindings(
        RegExp(r'^extension type ([^_]\w*)\._\(objc\.ObjCProtocol '),
      );
      expectSetsEqual(
        'generated protocols',
        objCBuiltInProtocols.values.toSet(),
        allProtocolNames,
      );
    });

    test('All code genned categories are included in the list', () {
      final allCategoryNames = findBindings(
        RegExp(r'^extension (\w+) on \w+ {'),
      );
      expectSetsEqual(
        'generated categories',
        objCBuiltInCategories,
        allCategoryNames,
      );
    });

    test('No stubs', () {
      final stubRegExp = RegExp(r'\Wstub\W');
      expect(bindings.where(stubRegExp.hasMatch).toList(), <String>[]);
    });

    test('No automatically renamed classes', () {
      // All automatically renamed classes or enums should be given an explicit
      // name. Note that we're not checking for renamed extensions, because ObjC
      // allows categories with identical names (so we can't unambiguously
      // rename them), and users don't need to refer to the extension by name
      // anyway.
      final renameRegExp = RegExp(r'(class|enum) .*\$[0-9 ]');
      expect(bindings.where(renameRegExp.hasMatch).toList(), <String>[]);
    });
  });
}
