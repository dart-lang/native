// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
library;

import 'dart:io';

import 'package:ffigen/ffigen.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import '../test_utils.dart';

String generate({
  bool includeTransitiveObjCCategories = true,
}) {
  FfiGenerator(
    output: Output(
      dartFile: Uri.file(
        path.join(
          packagePathForTests,
          'test',
          'native_objc_test',
          'transitive_test_bindings.dart',
        ),
      ),
      format: false,
      style: const DynamicLibraryBindings(
        wrapperName: 'TransitiveTestObjCLibrary',
        wrapperDocComment: 'Tests transitive inclusion',
      ),
    ),
    headers: Headers(
      entryPoints: [
        Uri.file(
          path.join(
            packagePathForTests,
            'test',
            'native_objc_test',
            'transitive_test.h',
          ),
        ),
      ],
    ),
    objectiveC: const ObjectiveC(),
    visitors: [
      Visitor(
        visitObjCInterface: (node) {
          if ({
            'DirectlyIncluded',
            'DirectlyIncludedWithProtocol',
            'DirectlyIncludedIntForCat',
            'Bug2935DirectInterface',
          }.contains(node.originalName)) {
            node.isIncluded = true;
          }
          node.includeCategories = includeTransitiveObjCCategories;
        },
        visitObjCProtocol: (node) {
          if ({'DirectlyIncludedProtocol'}.contains(node.originalName)) {
            node.isIncluded = true;
          }
        },
        visitObjCCategory: (node) {
          if ({'DirectlyIncludedCategory'}.contains(node.originalName)) {
            node.isIncluded = true;
          }
        },
        visitEnum: (node) {
          node.silenceWarning = true;
        },
      ),
    ],
  ).generate(logger: createTestLogger());
  final file = path.join(
    packagePathForTests,
    'test',
    'native_objc_test',
    'transitive_test_bindings.dart',
  );
  expectNoAnalysisErrors(file);
  return File(file).readAsStringSync();
}

enum Inclusion { omitted, stubbed, included }

void main() {
  group('transitive', () {
    late String bindings;

    Inclusion incItf(String name) {
      final classDef = bindings.contains(
        RegExp('extension type \\b$name\\._\\(objc\\.ObjCObject '),
      );
      final isInst = bindings.contains(
        '/// Returns whether [obj] is an instance of [$name].',
      );
      final any = bindings.contains(RegExp('\\b$name\\b'));
      if (classDef && !isInst && any) return Inclusion.stubbed;
      if (classDef && isInst && any) return Inclusion.included;
      if (!classDef && !isInst && !any) return Inclusion.omitted;
      throw Exception(
        'Bad interface: $name ($classDef, $isInst, $any)',
      );
    }

    Inclusion incProto(String name) {
      final classDef = bindings.contains(
        RegExp('extension type \\b$name\\._\\(objc\\.ObjCProtocol '),
      );
      final stubWarn = bindings.contains(
        RegExp('WARNING: \\b$name is a stub\\.'),
      );
      final hasImpl = bindings.contains(
        '/// Adds the implementation of the $name protocol',
      );
      final any = bindings.contains(RegExp('\\b$name\\b'));
      if (classDef && stubWarn && !hasImpl && any) return Inclusion.stubbed;
      if (classDef && !stubWarn && hasImpl && any) return Inclusion.included;
      if (!classDef && !stubWarn && !hasImpl && !any) return Inclusion.omitted;
      throw Exception(
        'Bad protocol: $name ($classDef, $stubWarn, $hasImpl, $any)',
      );
    }

    Inclusion incCat(String name) {
      final classDef = bindings.contains(RegExp('extension \\b$name\\b'));
      final any = bindings.contains(RegExp('\\b$name\\b'));
      if (classDef && any) return Inclusion.included;
      if (!classDef && !any) return Inclusion.omitted;
      throw Exception('Bad category: $name ($classDef, $any)');
    }

    group('transitive interfaces', () {
      test('stubbed', () {
        bindings = generate();

        expect(incItf('DoublyTransitive'), Inclusion.omitted);
        expect(incItf('TransitiveSuper'), Inclusion.stubbed);
        expect(incItf('Transitive'), Inclusion.stubbed);
        expect(incItf('SuperSuperType'), Inclusion.included);
        expect(incItf('DoublySuperTransitive'), Inclusion.omitted);
        expect(incItf('SuperTransitive'), Inclusion.stubbed);
        expect(incItf('SuperType'), Inclusion.included);
        expect(incItf('DirectlyIncluded'), Inclusion.included);
        expect(incItf('NotIncludedSuperType'), Inclusion.omitted);
        expect(incItf('NotIncludedTransitive'), Inclusion.omitted);
        expect(incItf('NotIncludedSuperType'), Inclusion.omitted);
        expect(incItf('Bug2935DirectInterface'), Inclusion.included);
        expect(incItf('Bug2935TransitiveInterface'), Inclusion.stubbed);
        expect(incItf('Bug2935TransitiveBlockInterface'), Inclusion.omitted);

        expect(bindings.contains('doubleMethod'), isFalse);
        expect(bindings.contains('transitiveSuperMethod'), isFalse);
        expect(bindings.contains('transitiveMethod'), isFalse);
        expect(bindings.contains('superSuperMethod'), isTrue);
        expect(bindings.contains('doublySuperMethod'), isFalse);
        expect(bindings.contains('superTransitiveMethod'), isFalse);
        expect(bindings.contains('superMethod'), isTrue);
        expect(bindings.contains('directMethod'), isTrue);
        expect(bindings.contains('notIncludedSuperMethod'), isFalse);
        expect(bindings.contains('notIncludedTransitiveMethod'), isFalse);
        expect(bindings.contains('notIncludedMethod'), isFalse);
        expect(bindings.contains('bug2935DirectInterfaceMethod'), isTrue);
        expect(bindings.contains('bug2935TransitiveInterfaceMethod'), isFalse);
        expect(
          bindings.contains('bug2935TransitiveBlockInterfaceMethod'),
          isFalse,
        );
      });
    });

    group('transitive protocols', () {
      test('not included', () {
        bindings = generate();

        expect(incProto('DoublyTransitiveProtocol'), Inclusion.omitted);
        expect(incProto('TransitiveSuperProtocol'), Inclusion.stubbed);
        expect(incProto('TransitiveProtocol'), Inclusion.stubbed);
        expect(incProto('SuperSuperProtocol'), Inclusion.stubbed);
        expect(incProto('DoublySuperTransitiveProtocol'), Inclusion.omitted);
        expect(incProto('SuperTransitiveProtocol'), Inclusion.stubbed);
        expect(incProto('SuperProtocol'), Inclusion.stubbed);
        expect(incProto('AnotherSuperProtocol'), Inclusion.stubbed);
        expect(incProto('DirectlyIncludedProtocol'), Inclusion.included);
        expect(incProto('NotIncludedSuperProtocol'), Inclusion.omitted);
        expect(incProto('NotIncludedTransitiveProtocol'), Inclusion.omitted);
        expect(incProto('NotIncludedProtocol'), Inclusion.omitted);
        expect(incProto('SuperFromInterfaceProtocol'), Inclusion.stubbed);
        expect(incProto('TransitiveFromInterfaceProtocol'), Inclusion.stubbed);
        expect(incItf('DirectlyIncludedWithProtocol'), Inclusion.included);
        expect(incProto('Bug2935TransitiveProtocol'), Inclusion.stubbed);

        expect(bindings.contains('doubleProtoMethod'), isFalse);
        expect(bindings.contains('transitiveSuperProtoMethod'), isFalse);
        expect(bindings.contains('transitiveProtoMethod'), isFalse);
        expect(bindings.contains('superSuperProtoMethod'), isTrue);
        expect(bindings.contains('doublySuperProtoMethod'), isFalse);
        expect(bindings.contains('superTransitiveProtoMethod'), isFalse);
        expect(bindings.contains('superProtoMethod'), isTrue);
        expect(bindings.contains('anotherSuperProtoMethod'), isTrue);
        expect(bindings.contains('directProtoMethod'), isTrue);
        expect(bindings.contains('notIncludedSuperProtoMethod'), isFalse);
        expect(bindings.contains('notIncludedTransitiveProtoMethod'), isFalse);
        expect(bindings.contains('notIncludedProtoMethod'), isFalse);
        expect(bindings.contains('superFromInterfaceProtoMethod'), isTrue);
        expect(
          bindings.contains('transitiveFromInterfaceProtoMethod'),
          isFalse,
        );
        expect(bindings.contains('directlyIncludedWithProtoMethod'), isTrue);
        expect(bindings.contains('bug2935TransitiveProtocolMethod'), isFalse);
      });
    });

    group('transitive categories', () {
      test('included', () {
        bindings = generate(includeTransitiveObjCCategories: true);

        expect(incItf('IntOfDirectCat'), Inclusion.stubbed);
        expect(incItf('TransitiveIntOfDirectCat'), Inclusion.stubbed);
        expect(incProto('TransitiveProtOfDirectCat'), Inclusion.stubbed);
        expect(incCat('DirectlyIncludedCategory'), Inclusion.included);
        expect(incItf('DoubleTransitiveIntOfTransitiveCat'), Inclusion.omitted);
        expect(incCat('TransitiveCatOfTransitiveInt'), Inclusion.omitted);
        expect(incItf('DirectlyIncludedIntForCat'), Inclusion.included);
        expect(incItf('TransitiveIntOfTransitiveCat'), Inclusion.stubbed);
        expect(incCat('TransitiveCatOfDirectInt'), Inclusion.included);
        expect(incCat('NotIncludedCategory'), Inclusion.omitted);

        expect(bindings.contains('intOfDirectCatMethod'), isFalse);
        expect(bindings.contains('transitiveIntOfCatMethod'), isFalse);
        expect(bindings.contains('transitiveProtOfDirectCatMethod'), isTrue);
        expect(bindings.contains('directlyIncludedCategoryMethod'), isTrue);
        expect(
          bindings.contains('doubleTransitiveIntOfTransitiveCatMethod'),
          isFalse,
        );
        expect(
          bindings.contains('transitiveCatOfTransitiveIntMethod'),
          isFalse,
        );
        expect(bindings.contains('directlyIncludedIntForCatMethod'), isTrue);
        expect(
          bindings.contains('transitiveIntOfTransitiveCatMethod'),
          isFalse,
        );
        expect(bindings.contains('transitiveCatOfDirectIntMethod'), isTrue);
        expect(bindings.contains('notIncludedCategoryMethod'), isFalse);
      });

      test('not included', () {
        bindings = generate(includeTransitiveObjCCategories: false);

        expect(incItf('IntOfDirectCat'), Inclusion.stubbed);
        expect(incItf('TransitiveIntOfDirectCat'), Inclusion.stubbed);
        expect(incProto('TransitiveProtOfDirectCat'), Inclusion.stubbed);
        expect(incCat('DirectlyIncludedCategory'), Inclusion.included);
        expect(incItf('DoubleTransitiveIntOfTransitiveCat'), Inclusion.omitted);
        expect(incCat('TransitiveCatOfTransitiveInt'), Inclusion.omitted);
        expect(incItf('DirectlyIncludedIntForCat'), Inclusion.included);
        expect(incItf('TransitiveIntOfTransitiveCat'), Inclusion.omitted);
        expect(incCat('TransitiveCatOfDirectInt'), Inclusion.omitted);
        expect(incCat('NotIncludedCategory'), Inclusion.omitted);

        expect(bindings.contains('intOfDirectCatMethod'), isFalse);
        expect(bindings.contains('transitiveIntOfCatMethod'), isFalse);
        expect(bindings.contains('transitiveProtOfDirectCatMethod'), isTrue);
        expect(bindings.contains('directlyIncludedCategoryMethod'), isTrue);
        expect(
          bindings.contains('doubleTransitiveIntOfTransitiveCatMethod'),
          isFalse,
        );
        expect(
          bindings.contains('transitiveCatOfTransitiveIntMethod'),
          isFalse,
        );
        expect(bindings.contains('directlyIncludedIntForCatMethod'), isTrue);
        expect(
          bindings.contains('transitiveIntOfTransitiveCatMethod'),
          isFalse,
        );
        expect(bindings.contains('transitiveCatOfDirectIntMethod'), isFalse);
        expect(bindings.contains('notIncludedCategoryMethod'), isFalse);
      });
    });
  });
}
