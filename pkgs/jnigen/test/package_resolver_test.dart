// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:jnigen/src/writers/files_writer.dart';
import 'package:test/test.dart';

class ResolverTest {
  ResolverTest(this.binaryName, this.expectedImport, this.expectedName);
  String binaryName;
  String expectedImport;
  String expectedName;
}

void main() {
  final resolver = FilePathResolver(
      importMap: {
        'org.apache.pdfbox': 'package:pdfbox/pdfbox.dart',
        'android.os.Process': 'package:android/os.dart',
      },
      currentClass: 'a.b.N',
      inputClassNames: {
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
        'android.os.Process', 'package:android/os.dart', 'process_.Process'),
    ResolverTest('org.apache.pdfbox.pdmodel.PDDocument',
        'package:pdfbox/pdfbox.dart', 'pddocument_.PDDocument'),
    // Relative imports
    // inner package
    ResolverTest('a.b.c.D', 'c/D.dart', 'd_.D'),
    // inner package, deeper
    ResolverTest('a.b.c.d.E', 'c/d/E.dart', 'e_.E'),
    // parent package
    ResolverTest('a.X', '../X.dart', 'x_.X'),
    // unrelated package in same translation unit
    ResolverTest('e.f.G', '../../e/f/G.dart', 'g_.G'),
    ResolverTest('e.F', '../../e/F.dart', 'f_.F'),
    // neighbour package
    ResolverTest('a.g.Y', '../g/Y.dart', 'y_.Y'),
    // inner package of a neighbour package
    ResolverTest('a.m.n.P', '../m/n/P.dart', 'p_.P'),
  ];

  for (var testCase in tests) {
    final binaryName = testCase.binaryName;
    final packageName = getFileClassName(binaryName);
    test(
        'getImport $binaryName',
        () => expect(resolver.getImport(packageName, binaryName),
            equals(testCase.expectedImport)));
    test(
        'resolve $binaryName',
        () => expect(
            resolver.resolve(binaryName), equals(testCase.expectedName)));
  }
}
