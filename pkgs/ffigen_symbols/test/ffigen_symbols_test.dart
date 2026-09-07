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
  });
}
