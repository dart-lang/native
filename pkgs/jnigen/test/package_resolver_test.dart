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
        'org.apache.pdfbox': 'package:pdfbox/pdfbox.dart',
        'android.os.Process': 'package:android/os.dart',
      },
      'a.b',
      {
        'a.b.C',
        'a.b.c.D',
        'a.b.c.d.E',
        'a.X',
        'e.f.G',
        'e.F',
        'a.g.Y',
        'a.m.n.P'
      });

  final tests = [
    // Absolute imports resolved using import map
    ResolverTest(
        'android.os.Process', 'package:android/os.dart', 'os_.Process'),
    ResolverTest('org.apache.pdfbox.pdmodel.PDDocument',
        'package:pdfbox/pdfbox.dart', 'pdmodel_.PDDocument'),
    // Relative imports
    // inner package
    ResolverTest('a.b.c.D', 'b/c.dart', 'c_.D'),
    // inner package, deeper
    ResolverTest('a.b.c.d.E', 'b/c/d.dart', 'd_.E'),
    // parent package
    ResolverTest('a.X', '../a.dart', 'a_.X'),
    // unrelated package in same translation unit
    ResolverTest('e.f.G', '../e/f.dart', 'f_.G'),
    ResolverTest('e.F', '../e.dart', 'e_.F'),
    // neighbour package
    ResolverTest('a.g.Y', 'g.dart', 'g_.Y'),
    // inner package of a neighbour package
    ResolverTest('a.m.n.P', 'm/n.dart', 'n_.P'),
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
