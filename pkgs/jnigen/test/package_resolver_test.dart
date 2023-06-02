// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:jnigen/src/bindings/resolver.dart';
import 'package:jnigen/src/elements/elements.dart';
import 'package:test/test.dart';

import 'test_util/test_util.dart';

class ResolverTest {
  ResolverTest(this.binaryName, this.expectedImport, this.expectedName);
  String binaryName;
  String expectedImport;
  String expectedName;
}

void main() async {
  await checkLocallyBuiltDependencies();
  final resolver = Resolver(
    importedClasses: {
      'org.apache.pdfbox.pdmodel.PDDocument': ClassDecl(
        binaryName: 'org.apache.pdfbox.pdmodel.PDDocument',
      )..path = 'package:pdfbox/pdfbox.dart',
      'android.os.Process': ClassDecl(
        binaryName: 'android.os.Process',
      )..path = 'package:android/os.dart',
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
    },
  );

  final tests = [
    // Absolute imports resolved using import map
    ResolverTest('android.os.Process', 'package:android/os.dart', 'process_.'),
    ResolverTest('org.apache.pdfbox.pdmodel.PDDocument',
        'package:pdfbox/pdfbox.dart', 'pddocument_.'),
    // Relative imports
    // inner package
    ResolverTest('a.b.c.D', 'c/D.dart', 'd_.'),
    // inner package, deeper
    ResolverTest('a.b.c.d.E', 'c/d/E.dart', 'e_.'),
    // parent package
    ResolverTest('a.X', '../X.dart', 'x_.'),
    // unrelated package in same translation unit
    ResolverTest('e.f.G', '../../e/f/G.dart', 'g_.'),
    ResolverTest('e.F', '../../e/F.dart', 'f_.'),
    // neighbour package
    ResolverTest('a.g.Y', '../g/Y.dart', 'y_.'),
    // inner package of a neighbour package
    ResolverTest('a.m.n.P', '../m/n/P.dart', 'p_.'),
  ];

  for (var testCase in tests) {
    final binaryName = testCase.binaryName;
    final packageName = Resolver.getFileClassName(binaryName);
    test(
        'getImport $binaryName',
        () => expect(resolver.getImport(packageName, binaryName),
            equals(testCase.expectedImport)));
    test(
        'resolve $binaryName',
        () => expect(
            resolver
                .resolvePrefix(ClassDecl(binaryName: binaryName)..path = ''),
            equals(testCase.expectedName)));
  }
}
