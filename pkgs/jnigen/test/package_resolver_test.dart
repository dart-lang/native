// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:jnigen/src/writers/files_writer.dart';
import 'package:jnigen/src/util/name_utils.dart';
import 'package:test/test.dart';

class ResolverTest {
  ResolverTest(this.binaryName, this.expectedImport, this.expectedName);
  String binaryName;
  String expectedImport;
  String expectedName;
}

void main() {
  final resolver = PackagePathResolver(
      {
        'org.apache.pdfbox': 'package:pdfbox',
        'org.apache.fontbox': 'package:fontbox',
        'java.lang': 'package:java_lang',
        'java.util': 'package:java_util',
        'org.me.package': 'package:my_package/src/',
      },
      'a.b',
      {'a.b.C', 'a.b.c.D', 'a.b.c.d.E', 'a.X', 'a.g.Y'});

  final tests = [
    // Simple example
    ResolverTest('org.apache.pdfbox.PDF',
        'package:pdfbox/org/apache/pdfbox.dart', 'pdfbox_.PDF'),
    // Nested classes
    ResolverTest('org.apache.fontbox.Font\$FontFile',
        'package:fontbox/org/apache/fontbox.dart', 'fontbox_.Font_FontFile'),
    // slightly deeper package
    ResolverTest('java.lang.ref.WeakReference',
        'package:java_lang/java/lang/ref.dart', 'ref_.WeakReference'),
    // Renaming
    ResolverTest('java.util.U', 'package:java_util/java/util.dart', 'util_.U'),
    ResolverTest('org.me.package.util.U',
        'package:my_package/src/org/me/package/util.dart', 'util1_.U'),
    // Relative imports
    ResolverTest('a.b.c.D', 'b/c.dart', 'c_.D'),
    ResolverTest('a.b.c.d.E', 'b/c/d.dart', 'd_.E'),
    ResolverTest('a.X', '../a.dart', 'a_.X'),
    ResolverTest('a.g.Y', '../a/g.dart', 'g_.Y'),
  ];

  for (var testCase in tests) {
    final binaryName = testCase.binaryName;
    final packageName = cutFromLast(binaryName, '.')[0];
    test(
        'getImport $binaryName',
        () => expect(resolver.getImport(packageName, binaryName),
            equals(testCase.expectedImport)));
    test(
        'resolve $binaryName',
        () => expect(
            resolver.resolve(binaryName), equals(testCase.expectedName)));
  }
  test('resolve in same package',
      () => expect(resolver.resolve('a.b.C'), equals('C')));
}
