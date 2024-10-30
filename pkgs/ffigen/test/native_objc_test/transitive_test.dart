// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')

import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:ffigen/ffigen.dart';
import 'package:ffigen/src/config_provider/config.dart';
import 'package:ffigen/src/config_provider/config_types.dart';
import 'package:logging/logging.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';
import '../test_utils.dart';
import 'util.dart';

String generate({
  bool includeTransitiveObjCInterfaces = false,
  bool includeTransitiveObjCProtocols = false,
}) {
  final config = Config(
    wrapperName: 'TransitiveTestObjCLibrary',
    wrapperDocComment: 'Tests transitive inclusion',
    language: Language.objc,
    output: Uri.file('test/native_objc_test/transitive_bindings.dart'),
    entryPoints: [Uri.file('test/native_objc_test/transitive_test.h')],
    formatOutput: true,
    objcInterfaces: DeclarationFilters.include(
        {'DirectlyIncluded', 'DirectlyIncludedWithProtocol'}),
    objcProtocols: DeclarationFilters.include({'DirectlyIncludedProtocol'}),
    includeTransitiveObjCInterfaces: includeTransitiveObjCInterfaces,
    includeTransitiveObjCProtocols: includeTransitiveObjCProtocols,
  );
  FfiGen(logLevel: Level.SEVERE).run(config);
  return File('test/native_objc_test/transitive_bindings.dart')
      .readAsStringSync();
}

enum Inclusion { omitted, stubbed, included }


void main() {
  group('transitive', () {
    late String bindings;

    Inclusion incItf(String name) {
      bool classDef = bindings.contains('class $name ');
      bool stubWarn = bindings.contains('WARNING: $name is a stub.');
      bool isInst =
          bindings.contains('/// Returns whether [obj] is an instance of [$name].');
      bool any = bindings.contains(RegExp('\\W$name\\W'));
      if (classDef && stubWarn && !isInst && any) return Inclusion.stubbed;
      if (classDef && !stubWarn && isInst && any) return Inclusion.included;
      if (!classDef && !stubWarn && !isInst && !any) return Inclusion.omitted;
      throw Exception('Bad interface: $name ($classDef, $stubWarn, $isInst, $any)');
    }

    Inclusion incProto(String name) {
      bool classDef = bindings.contains('class $name ');
      bool any = bindings.contains(RegExp('\\W$name\\W'));
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

        // TODO(https://github.com/dart-lang/native/issues/1462): Transitive
        // protocols should be included.
        expect(incProto('DoublyTransitiveProtocol'), Inclusion.omitted);
        expect(incProto('TransitiveSuperProtocol'), Inclusion.omitted);
        expect(incProto('TransitiveProtocol'), Inclusion.omitted);
        expect(incProto('SuperSuperProtocol'), Inclusion.included);
        expect(incProto('DoublySuperTransitiveProtocol'), Inclusion.omitted);
        expect(incProto('SuperTransitiveProtocol'), Inclusion.omitted);
        expect(incProto('SuperProtocol'), Inclusion.included);
        expect(incProto('AnotherSuperProtocol'), Inclusion.included);
        expect(incProto('DirectlyIncludedProtocol'), Inclusion.included);
        expect(incProto('NotIncludedSuperProtocol'), Inclusion.omitted);
        expect(incProto('NotIncludedTransitiveProtocol'), Inclusion.omitted);
        expect(incProto('NotIncludedProtocol'), Inclusion.omitted);
        expect(incProto('SuperFromInterfaceProtocol'), Inclusion.included);
        expect(incProto('TransitiveFromInterfaceProtocol'), Inclusion.omitted);
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
        expect(bindings.contains('transitiveFromInterfaceProtoMethod'), isFalse);
        expect(bindings.contains('directlyIncludedWithProtoMethod'), isTrue);
      });

      test('not included', () {
        bindings = generate(includeTransitiveObjCProtocols: false);

        expect(incProto('DoublyTransitiveProtocol'), Inclusion.omitted);
        expect(incProto('TransitiveSuperProtocol'), Inclusion.omitted);
        expect(incProto('TransitiveProtocol'), Inclusion.omitted);
        expect(incProto('SuperSuperProtocol'), Inclusion.omitted);
        expect(incProto('DoublySuperTransitiveProtocol'), Inclusion.omitted);
        expect(incProto('SuperTransitiveProtocol'), Inclusion.omitted);
        expect(incProto('SuperProtocol'), Inclusion.omitted);
        expect(incProto('AnotherSuperProtocol'), Inclusion.omitted);
        expect(incProto('DirectlyIncludedProtocol'), Inclusion.included);
        expect(incProto('NotIncludedSuperProtocol'), Inclusion.omitted);
        expect(incProto('NotIncludedTransitiveProtocol'), Inclusion.omitted);
        expect(incProto('NotIncludedProtocol'), Inclusion.omitted);
        expect(incProto('SuperFromInterfaceProtocol'), Inclusion.omitted);
        expect(incProto('TransitiveFromInterfaceProtocol'), Inclusion.omitted);
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
        expect(bindings.contains('transitiveFromInterfaceProtoMethod'), isFalse);
        expect(bindings.contains('directlyIncludedWithProtoMethod'), isTrue);
      });
    });
  });
}
