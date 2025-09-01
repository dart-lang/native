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
  bool includeTransitiveObjCInterfaces = false,
  bool includeTransitiveObjCProtocols = false,
  bool includeTransitiveObjCCategories = false,
}) {
  FfiGenerator(
    bindingStyle: const DynamicLibraryBindings(
      wrapperName: 'TransitiveTestObjCLibrary',
      wrapperDocComment: 'Tests transitive inclusion',
    ),
    language: Language.objc,
    output: Output(
      dartFile: Uri.file(
        path.join(
          packagePathForTests,
          'test',
          'native_objc_test',
          'transitive_bindings.dart',
        ),
      ),
      format: false,
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
    objectiveC: ObjectiveC(
      interfaces: ObjCInterfaces(
        shouldInclude: (decl) => {
          'DirectlyIncluded',
          'DirectlyIncludedWithProtocol',
          'DirectlyIncludedIntForCat',
        }.contains(decl.originalName),
        includeTransitive: includeTransitiveObjCInterfaces,
      ),
      protocols: ObjCProtocols(
        shouldInclude: (decl) =>
            {'DirectlyIncludedProtocol'}.contains(decl.originalName),
        includeTransitive: includeTransitiveObjCProtocols,
      ),
      categories: ObjCCategories(
        shouldInclude: (decl) =>
            {'DirectlyIncludedCategory'}.contains(decl.originalName),
        includeTransitive: includeTransitiveObjCCategories,
      ),
    ),
  ).generate(logger: Logger.root..level = Level.SEVERE);
  return File(
    path.join(
      packagePathForTests,
      'test',
      'native_objc_test',
      'transitive_bindings.dart',
    ),
  ).readAsStringSync();
}

enum Inclusion { omitted, stubbed, included }

void main() {
  group('transitive', () {
    late String bindings;

    Inclusion incItf(String name) {
      final classDef = bindings.contains('class $name ');
      final stubWarn = bindings.contains('WARNING: $name is a stub.');
      final isInst = bindings.contains(
        '/// Returns whether [obj] is an instance of [$name].',
      );
      final any = bindings.contains(RegExp('\\W$name\\W'));
      if (classDef && stubWarn && !isInst && any) return Inclusion.stubbed;
      if (classDef && !stubWarn && isInst && any) return Inclusion.included;
      if (!classDef && !stubWarn && !isInst && !any) return Inclusion.omitted;
      throw Exception(
        'Bad interface: $name ($classDef, $stubWarn, $isInst, $any)',
      );
    }

    Inclusion incProto(String name) {
      final classDef = bindings.contains('class $name ');
      final stubWarn = bindings.contains('WARNING: $name is a stub.');
      final hasImpl = bindings.contains(
        '/// Adds the implementation of the $name protocol',
      );
      final any = bindings.contains(RegExp('\\W$name\\W'));
      if (classDef && stubWarn && !hasImpl && any) return Inclusion.stubbed;
      if (classDef && !stubWarn && hasImpl && any) return Inclusion.included;
      if (!classDef && !stubWarn && !hasImpl && !any) return Inclusion.omitted;
      throw Exception(
        'Bad protocol: $name ($classDef, $stubWarn, $hasImpl, $any)',
      );
    }

    Inclusion incCat(String name) {
      final classDef = bindings.contains('extension $name ');
      final any = bindings.contains(RegExp('\\W$name\\W'));
      if (classDef && any) return Inclusion.included;
      if (!classDef && !any) return Inclusion.omitted;
      throw Exception('Bad protocol: $name ($classDef, $any)');
    }

    group('transitive interfaces', () {
      test('included', () {
        bindings = generate(includeTransitiveObjCInterfaces: true);

        expect(incItf('DoublyTransitive'), Inclusion.included);
        expect(incItf('TransitiveSuper'), Inclusion.included);
        expect(incItf('Transitive'), Inclusion.included);
        expect(incItf('SuperSuperType'), Inclusion.included);
        expect(incItf('DoublySuperTransitive'), Inclusion.included);
        expect(incItf('SuperTransitive'), Inclusion.included);
        expect(incItf('SuperType'), Inclusion.included);
        expect(incItf('DirectlyIncluded'), Inclusion.included);
        expect(incItf('NotIncludedSuperType'), Inclusion.omitted);
        expect(incItf('NotIncludedTransitive'), Inclusion.omitted);
        expect(incItf('NotIncludedSuperType'), Inclusion.omitted);

        expect(bindings.contains('doubleMethod'), isTrue);
        expect(bindings.contains('transitiveSuperMethod'), isTrue);
        expect(bindings.contains('transitiveMethod'), isTrue);
        expect(bindings.contains('superSuperMethod'), isTrue);
        expect(bindings.contains('doublySuperMethod'), isTrue);
        expect(bindings.contains('superTransitiveMethod'), isTrue);
        expect(bindings.contains('superMethod'), isTrue);
        expect(bindings.contains('directMethod'), isTrue);
        expect(bindings.contains('notIncludedSuperMethod'), isFalse);
        expect(bindings.contains('notIncludedTransitiveMethod'), isFalse);
        expect(bindings.contains('notIncludedMethod'), isFalse);
      });

      test('stubbed', () {
        bindings = generate(includeTransitiveObjCInterfaces: false);

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
      });
    });

    group('transitive protocols', () {
      test('included', () {
        bindings = generate(includeTransitiveObjCProtocols: true);

        expect(incProto('DoublyTransitiveProtocol'), Inclusion.included);
        expect(incProto('TransitiveSuperProtocol'), Inclusion.included);
        expect(incProto('TransitiveProtocol'), Inclusion.included);
        expect(incProto('SuperSuperProtocol'), Inclusion.included);
        expect(incProto('DoublySuperTransitiveProtocol'), Inclusion.included);
        expect(incProto('SuperTransitiveProtocol'), Inclusion.included);
        expect(incProto('SuperProtocol'), Inclusion.included);
        expect(incProto('AnotherSuperProtocol'), Inclusion.included);
        expect(incProto('DirectlyIncludedProtocol'), Inclusion.included);
        expect(incProto('NotIncludedSuperProtocol'), Inclusion.omitted);
        expect(incProto('NotIncludedTransitiveProtocol'), Inclusion.omitted);
        expect(incProto('NotIncludedProtocol'), Inclusion.omitted);
        expect(incProto('SuperFromInterfaceProtocol'), Inclusion.included);
        expect(incProto('TransitiveFromInterfaceProtocol'), Inclusion.included);
        expect(incItf('DirectlyIncludedWithProtocol'), Inclusion.included);

        expect(bindings.contains('doubleProtoMethod'), isTrue);
        expect(bindings.contains('transitiveSuperProtoMethod'), isTrue);
        expect(bindings.contains('transitiveProtoMethod'), isTrue);
        expect(bindings.contains('superSuperProtoMethod'), isTrue);
        expect(bindings.contains('doublySuperProtoMethod'), isTrue);
        expect(bindings.contains('superTransitiveProtoMethod'), isTrue);
        expect(bindings.contains('superProtoMethod'), isTrue);
        expect(bindings.contains('anotherSuperProtoMethod'), isTrue);
        expect(bindings.contains('directProtoMethod'), isTrue);
        expect(bindings.contains('notIncludedSuperProtoMethod'), isFalse);
        expect(bindings.contains('notIncludedTransitiveProtoMethod'), isFalse);
        expect(bindings.contains('notIncludedProtoMethod'), isFalse);
        expect(bindings.contains('superFromInterfaceProtoMethod'), isTrue);
        expect(bindings.contains('transitiveFromInterfaceProtoMethod'), isTrue);
        expect(bindings.contains('directlyIncludedWithProtoMethod'), isTrue);
      });

      test('not included', () {
        bindings = generate(includeTransitiveObjCProtocols: false);

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
