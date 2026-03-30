// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:record_use/record_use.dart';
import 'package:test/test.dart';

const loadingUnitFoo = LoadingUnit('dart.foo');

void main() {
  group('toString', () {
    test('CallWithArguments', () {
      const call = CallWithArguments(
        positionalArguments: [],
        namedArguments: {},
        loadingUnit: loadingUnitFoo,
      );
      expect(
        call.toString(),
        'CallWithArguments(loadingUnit: dart.foo)',
      );
    });

    test('CallWithArguments with multiple args', () {
      const call = CallWithArguments(
        positionalArguments: [NonConstant(), NonConstant()],
        namedArguments: {
          'bar': NonConstant(),
          'baz': NonConstant(),
        },
        loadingUnit: loadingUnitFoo,
      );
      expect(
        call.toString(),
        'CallWithArguments(positional: NonConstant(), '
        'NonConstant(), named: bar=NonConstant(), '
        'baz=NonConstant(), loadingUnit: dart.foo)',
      );
    });

    test('SymbolConstant', () {
      expect(
        const SymbolConstant('foo').toString(),
        '#foo',
      );
      expect(
        const SymbolConstant('_bar', libraryUri: 'package:a/a.dart').toString(),
        'package:a/a.dart::#_bar',
      );
    });

    test('InstanceConstantReference with EnumConstant', () {
      const ref = InstanceConstantReference(
        instanceConstant: EnumConstant(
          definition: Enum('MyEnum', Library('package:a/a.dart')),
          index: 0,
          name: 'val1',
        ),
        loadingUnit: loadingUnitFoo,
      );
      expect(
        ref.toString(),
        'InstanceConstantReference(instanceConstant: EnumConstant(package:a/a.dart#enum:MyEnum, index: 0, name: val1, fields: {}), loadingUnit: dart.foo)',
      );
    });
  });
}
