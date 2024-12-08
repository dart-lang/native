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
        declKind: DeclKind.classKind,
        binaryName: 'org.apache.pdfbox.pdmodel.PDDocument',
      )..path = 'package:pdfbox/pdfbox.dart',
      'android.os.Process': ClassDecl(
        declKind: DeclKind.classKind,
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
    ResolverTest(
        'android.os.Process', 'package:android/os.dart', r'process$_.'),
    ResolverTest('org.apache.pdfbox.pdmodel.PDDocument',
        'package:pdfbox/pdfbox.dart', r'pddocument$_.'),
    // Relative imports
    // inner package
    ResolverTest('a.b.c.D', 'c/D.dart', r'd$_.'),
    // inner package, deeper
    ResolverTest('a.b.c.d.E', 'c/d/E.dart', r'e$_.'),
    // parent package
    ResolverTest('a.X', '../X.dart', r'x$_.'),
    // unrelated package in same translation unit
    ResolverTest('e.f.G', '../../e/f/G.dart', r'g$_.'),
    ResolverTest('e.F', '../../e/F.dart', r'f$_.'),
    // neighbour package
    ResolverTest('a.g.Y', '../g/Y.dart', r'y$_.'),
    // inner package of a neighbour package
    ResolverTest('a.m.n.P', '../m/n/P.dart', r'p$_.'),
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
            resolver.resolvePrefix(ClassDecl(
              declKind: DeclKind.classKind,
              binaryName: binaryName,
            )..path = ''),
            equals(testCase.expectedName)));
  }
}
