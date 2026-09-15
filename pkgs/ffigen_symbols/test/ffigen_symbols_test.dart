// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen_symbols/ffigen_symbols.dart';
import 'package:test/test.dart';

void main() {
  test('const constructors and equality', () {
    const lib1 = LibraryImport('foo', 'package:foo/foo.dart');
    const lib2 = LibraryImport('foo', 'package:foo/foo.dart');
    const lib3 = LibraryImport('foo', 'package:bar/bar.dart');
    expect(lib1, equals(lib2));
    expect(identical(lib1, lib2), isTrue);
    expect(lib1 == lib3, isFalse);

    const type1 = ImportedType(lib1, 'Foo', 'Foo', 'struct Foo');
    const type2 = ImportedType(lib2, 'Foo', 'Foo', 'struct Foo');
    expect(type1, equals(type2));
    expect(identical(type1, type2), isTrue);

    const decl1 = Declaration(usr: 'c:@S@Foo', originalName: 'Foo');
    const decl2 = Declaration(usr: 'c:@S@Foo', originalName: 'Foo');
    expect(decl1, equals(decl2));
    expect(identical(decl1, decl2), isTrue);

    const symbols1 = FfigenSymbols(
      formatVersion: '1.0.0',
      symbols: {'c:@S@Foo': type1},
    );
    const symbols2 = Symbols(
      formatVersion: '1.0.0',
      symbols: {'c:@S@Foo': type2},
    );
    expect(symbols1, equals(symbols2));
    expect(identical(symbols1, symbols2), isTrue);
    expect(symbols1['c:@S@Foo'], equals(type1));
    expect(symbols1['unknown'], isNull);
    expect(symbols1.containsKey('c:@S@Foo'), isTrue);
    expect(symbols1.containsKey('unknown'), isFalse);
    expect(symbols1.length, 1);
    expect(symbols1.isEmpty, isFalse);
    expect(symbols1.isNotEmpty, isTrue);
    expect(symbols1.keys, ['c:@S@Foo']);
    expect(symbols1.values, [type1]);
    expect(symbols1.toString(), contains('1 symbols'));
  });
}
