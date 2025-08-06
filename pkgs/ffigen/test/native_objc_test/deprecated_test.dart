// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
library;

import 'dart:io';

import 'package:ffigen/ffigen.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';
import '../test_utils.dart';

String bindingsForVersion({Versions? iosVers, Versions? macosVers}) {
  FfiGen(
    Logger.root,
    wrapperName: 'DeprecatedTestObjCLibrary',
    wrapperDocComment: 'Tests API deprecation',
    language: Language.objc,
    output: Uri.file(
      path.join(
        packagePathForTests,
        'test',
        'native_objc_test',
        'deprecated_bindings.dart',
      ),
    ),
    entryPoints: [
      Uri.file(
        path.join(
          packagePathForTests,
          'test',
          'native_objc_test',
          'deprecated_test.m',
        ),
      ),
    ],
    formatOutput: false,
    includeTransitiveObjCCategories: false,
    objcInterfaces: DeclarationFilters.include({
      'DeprecatedInterfaceMethods',
      'DeprecatedInterface',
    }),
    objcProtocols: DeclarationFilters.include({
      'DeprecatedProtocolMethods',
      'DeprecatedProtocol',
    }),
    objcCategories: DeclarationFilters.include({
      'DeprecatedCategoryMethods',
      'DeprecatedCategory',
    }),
    functionDecl: DeclarationFilters.include({
      'normalFunction',
      'deprecatedFunction',
    }),
    structDecl: DeclarationFilters.include({
      'NormalStruct',
      'DeprecatedStruct',
    }),
    unionDecl: DeclarationFilters.include({'NormalUnion', 'DeprecatedUnion'}),
    enumClassDecl: DeclarationFilters.include({'NormalEnum', 'DeprecatedEnum'}),
    unnamedEnumConstants: DeclarationFilters.include({
      'normalUnnamedEnum',
      'deprecatedUnnamedEnum',
    }),
    externalVersions: ExternalVersions(ios: iosVers, macos: macosVers),
  ).generate(Logger.root..level = Level.SEVERE);
  return File(
    path.join(
      packagePathForTests,
      'test',
      'native_objc_test',
      'deprecated_bindings.dart',
    ),
  ).readAsStringSync();
}

void main() {
  group('deprecated', () {
    group('no version info', () {
      late final String bindings;
      setUpAll(() {
        bindings = bindingsForVersion();
      });

      test('interfaces', () {
        expect(bindings, contains('DeprecatedInterface '));
        expect(bindings, contains('DeprecatedInterfaceMethods '));
      });

      test('protocols', () {
        expect(bindings, contains('DeprecatedProtocol '));
        expect(bindings, contains('DeprecatedProtocolMethods '));
      });

      test('protocols', () {
        expect(bindings, contains('DeprecatedCategory '));
        expect(bindings, contains('DeprecatedCategoryMethods '));
      });

      test('interface methods', () {
        expect(bindings, contains('normalMethod'));
        expect(bindings, contains('unavailableMac'));
        expect(bindings, contains('unavailableIos'));
        expect(bindings, contains('unavailableBoth'));
        expect(bindings, contains('depMac2'));
        expect(bindings, contains('depMac3'));
        expect(bindings, contains('depIos2'));
        expect(bindings, contains('depIos2Mac2'));
        expect(bindings, contains('depIos2Mac3'));
        expect(bindings, contains('depIos3'));
        expect(bindings, contains('depIos3Mac2'));
        expect(bindings, contains('depIos3Mac3'));
        expect(bindings, contains('alwaysDeprecated'));
        expect(bindings, contains('alwaysUnavailable'));
      });

      test('interface properties', () {
        expect(bindings, contains('get normalProperty'));
        expect(bindings, contains('set normalProperty'));
        expect(bindings, contains('get deprecatedProperty'));
        expect(bindings, contains('set deprecatedProperty'));
      });

      test('protocol methods', () {
        expect(bindings, contains('protNormalMethod'));
        expect(bindings, contains('protUnavailableMac'));
        expect(bindings, contains('protUnavailableIos'));
        expect(bindings, contains('protUnavailableBoth'));
        expect(bindings, contains('protDepMac2'));
        expect(bindings, contains('protDepMac3'));
        expect(bindings, contains('protDepIos2'));
        expect(bindings, contains('protDepIos2Mac2'));
        expect(bindings, contains('protDepIos2Mac3'));
        expect(bindings, contains('protDepIos3'));
        expect(bindings, contains('protDepIos3Mac2'));
        expect(bindings, contains('protDepIos3Mac3'));
        expect(bindings, contains('protAlwaysDeprecated'));
        expect(bindings, contains('protAlwaysUnavailable'));
      });

      test('protocol properties', () {
        expect(bindings, contains('protNormalProperty'));
        expect(bindings, contains('setProtNormalProperty'));
        expect(bindings, contains('protDeprecatedProperty'));
        expect(bindings, contains('setProtDeprecatedProperty'));
      });

      test('category methods', () {
        expect(bindings, contains('catNormalMethod'));
        expect(bindings, contains('catUnavailableMac'));
        expect(bindings, contains('catUnavailableIos'));
        expect(bindings, contains('catUnavailableBoth'));
        expect(bindings, contains('catDepMac2'));
        expect(bindings, contains('catDepMac3'));
        expect(bindings, contains('catDepIos2'));
        expect(bindings, contains('catDepIos2Mac2'));
        expect(bindings, contains('catDepIos2Mac3'));
        expect(bindings, contains('catDepIos3'));
        expect(bindings, contains('catDepIos3Mac2'));
        expect(bindings, contains('catDepIos3Mac3'));
        expect(bindings, contains('catAlwaysDeprecated'));
        expect(bindings, contains('catAlwaysUnavailable'));
      });

      test('category properties', () {
        expect(bindings, contains('get catNormalProperty'));
        expect(bindings, contains('set catNormalProperty'));
        expect(bindings, contains('get catDeprecatedProperty'));
        expect(bindings, contains('set catDeprecatedProperty'));
      });

      test('functions', () {
        expect(bindings, contains('normalFunction'));
        expect(bindings, contains('deprecatedFunction'));
      });

      test('structs', () {
        expect(bindings, contains('NormalStruct'));
        expect(bindings, contains('DeprecatedStruct'));
      });

      test('unions', () {
        expect(bindings, contains('NormalUnion'));
        expect(bindings, contains('DeprecatedUnion'));
      });

      test('enums', () {
        expect(bindings, contains('NormalEnum'));
        expect(bindings, contains('DeprecatedEnum'));
      });

      test('unnamed enums', () {
        expect(bindings, contains('normalUnnamedEnum'));
        expect(bindings, contains('deprecatedUnnamedEnum'));
      });
    });

    group('ios >=2.5, no macos version', () {
      late final String bindings;
      setUpAll(() {
        bindings = bindingsForVersion(iosVers: Versions(min: Version(2, 5, 0)));
      });

      test('interfaces', () {
        expect(bindings, isNot(contains('DeprecatedInterface ')));
        expect(bindings, contains('DeprecatedInterfaceMethods '));
      });

      test('protocols', () {
        expect(bindings, isNot(contains('DeprecatedProtocol ')));
        expect(bindings, contains('DeprecatedProtocolMethods '));
      });

      test('categories', () {
        expect(bindings, isNot(contains('DeprecatedCategory ')));
        expect(bindings, contains('DeprecatedCategoryMethods '));
      });

      test('interface methods', () {
        expect(bindings, contains('normalMethod'));
        expect(bindings, contains('unavailableMac'));
        expect(bindings, isNot(contains('unavailableIos')));
        expect(bindings, isNot(contains('unavailableBoth')));
        expect(bindings, contains('depMac2'));
        expect(bindings, contains('depMac3'));
        expect(bindings, isNot(contains('depIos2')));
        expect(bindings, isNot(contains('depIos2Mac2')));
        expect(bindings, isNot(contains('depIos2Mac3')));
        expect(bindings, contains('depIos3'));
        expect(bindings, contains('depIos3Mac2'));
        expect(bindings, contains('depIos3Mac3'));
        expect(bindings, isNot(contains('alwaysDeprecated')));
        expect(bindings, isNot(contains('alwaysUnavailable')));
      });

      test('interface properties', () {
        expect(bindings, contains('get normalProperty'));
        expect(bindings, contains('set normalProperty'));
        expect(bindings, isNot(contains('get deprecatedProperty')));
        expect(bindings, isNot(contains('set deprecatedProperty')));
      });

      test('protocol methods', () {
        expect(bindings, contains('protNormalMethod'));
        expect(bindings, contains('protUnavailableMac'));
        expect(bindings, isNot(contains('protUnavailableIos')));
        expect(bindings, isNot(contains('protUnavailableBoth')));
        expect(bindings, contains('protDepMac2'));
        expect(bindings, contains('protDepMac3'));
        expect(bindings, isNot(contains('protDepIos2')));
        expect(bindings, isNot(contains('protDepIos2Mac2')));
        expect(bindings, isNot(contains('protDepIos2Mac3')));
        expect(bindings, contains('protDepIos3'));
        expect(bindings, contains('protDepIos3Mac2'));
        expect(bindings, contains('protDepIos3Mac3'));
        expect(bindings, isNot(contains('protAlwaysDeprecated')));
        expect(bindings, isNot(contains('protAlwaysUnavailable')));
      });

      test('protocol properties', () {
        expect(bindings, contains('protNormalProperty'));
        expect(bindings, contains('setProtNormalProperty'));
        expect(bindings, isNot(contains('protDeprecatedProperty')));
        expect(bindings, isNot(contains('setProtDeprecatedProperty')));
      });

      test('category methods', () {
        expect(bindings, contains('catNormalMethod'));
        expect(bindings, contains('catUnavailableMac'));
        expect(bindings, isNot(contains('catUnavailableIos')));
        expect(bindings, isNot(contains('catUnavailableBoth')));
        expect(bindings, contains('catDepMac2'));
        expect(bindings, contains('catDepMac3'));
        expect(bindings, isNot(contains('catDepIos2')));
        expect(bindings, isNot(contains('catDepIos2Mac2')));
        expect(bindings, isNot(contains('catDepIos2Mac3')));
        expect(bindings, contains('catDepIos3'));
        expect(bindings, contains('catDepIos3Mac2'));
        expect(bindings, contains('catDepIos3Mac3'));
        expect(bindings, isNot(contains('catAlwaysDeprecated')));
        expect(bindings, isNot(contains('catAlwaysUnavailable')));
      });

      test('category properties', () {
        expect(bindings, contains('get catNormalProperty'));
        expect(bindings, contains('set catNormalProperty'));
        expect(bindings, isNot(contains('get catDeprecatedProperty')));
        expect(bindings, isNot(contains('set catDeprecatedProperty')));
      });

      test('functions', () {
        expect(bindings, contains('normalFunction'));
        expect(bindings, isNot(contains('deprecatedFunction')));
      });

      test('structs', () {
        expect(bindings, contains('NormalStruct'));
        expect(bindings, isNot(contains('DeprecatedStruct')));
      });

      test('unions', () {
        expect(bindings, contains('NormalUnion'));
        expect(bindings, isNot(contains('DeprecatedUnion')));
      });

      test('enums', () {
        expect(bindings, contains('NormalEnum'));
        expect(bindings, isNot(contains('DeprecatedEnum')));
      });

      test('unnamed enums', () {
        expect(bindings, contains('normalUnnamedEnum'));
        expect(bindings, isNot(contains('deprecatedUnnamedEnum')));
      });
    });

    group('ios >=2.5, macos >=2.5', () {
      late final String bindings;
      setUpAll(() {
        bindings = bindingsForVersion(
          iosVers: Versions(min: Version(2, 5, 0)),
          macosVers: Versions(min: Version(2, 5, 0)),
        );
      });

      test('interfaces', () {
        expect(bindings, isNot(contains('DeprecatedInterface ')));
        expect(bindings, contains('DeprecatedInterfaceMethods '));
      });

      test('protocols', () {
        expect(bindings, isNot(contains('DeprecatedProtocol ')));
        expect(bindings, contains('DeprecatedProtocolMethods '));
      });

      test('interface methods', () {
        expect(bindings, contains('normalMethod'));
        expect(bindings, contains('unavailableMac'));
        expect(bindings, contains('unavailableIos'));
        expect(bindings, isNot(contains('unavailableBoth')));
        expect(bindings, contains('depMac2'));
        expect(bindings, contains('depMac3'));
        expect(bindings, contains('depIos2'));
        expect(bindings, isNot(contains('depIos2Mac2')));
        expect(bindings, contains('depIos2Mac3'));
        expect(bindings, contains('depIos3'));
        expect(bindings, contains('depIos3Mac2'));
        expect(bindings, contains('depIos3Mac3'));
        expect(bindings, isNot(contains('alwaysDeprecated')));
        expect(bindings, isNot(contains('alwaysUnavailable')));
      });

      test('interface properties', () {
        expect(bindings, contains('get normalProperty'));
        expect(bindings, contains('set normalProperty'));
        expect(bindings, isNot(contains('get deprecatedProperty')));
        expect(bindings, isNot(contains('set deprecatedProperty')));
      });

      test('protocol methods', () {
        expect(bindings, contains('protNormalMethod'));
        expect(bindings, contains('protUnavailableMac'));
        expect(bindings, contains('protUnavailableIos'));
        expect(bindings, isNot(contains('protUnavailableBoth')));
        expect(bindings, contains('protDepMac2'));
        expect(bindings, contains('protDepMac3'));
        expect(bindings, contains('protDepIos2'));
        expect(bindings, isNot(contains('protDepIos2Mac2')));
        expect(bindings, contains('protDepIos2Mac3'));
        expect(bindings, contains('protDepIos3'));
        expect(bindings, contains('protDepIos3Mac2'));
        expect(bindings, contains('protDepIos3Mac3'));
        expect(bindings, isNot(contains('protAlwaysDeprecated')));
        expect(bindings, isNot(contains('protAlwaysUnavailable')));
      });

      test('protocol properties', () {
        expect(bindings, contains('protNormalProperty'));
        expect(bindings, contains('setProtNormalProperty'));
        expect(bindings, isNot(contains('protDeprecatedProperty')));
        expect(bindings, isNot(contains('setProtDeprecatedProperty')));
      });

      test('category methods', () {
        expect(bindings, contains('catNormalMethod'));
        expect(bindings, contains('catUnavailableMac'));
        expect(bindings, contains('catUnavailableIos'));
        expect(bindings, isNot(contains('catUnavailableBoth')));
        expect(bindings, contains('catDepMac2'));
        expect(bindings, contains('catDepMac3'));
        expect(bindings, contains('catDepIos2'));
        expect(bindings, isNot(contains('catDepIos2Mac2')));
        expect(bindings, contains('catDepIos2Mac3'));
        expect(bindings, contains('catDepIos3'));
        expect(bindings, contains('catDepIos3Mac2'));
        expect(bindings, contains('catDepIos3Mac3'));
        expect(bindings, isNot(contains('catAlwaysDeprecated')));
        expect(bindings, isNot(contains('catAlwaysUnavailable')));
      });

      test('category properties', () {
        expect(bindings, contains('get catNormalProperty'));
        expect(bindings, contains('set catNormalProperty'));
        expect(bindings, isNot(contains('get catDeprecatedProperty')));
        expect(bindings, isNot(contains('set catDeprecatedProperty')));
      });

      test('functions', () {
        expect(bindings, contains('normalFunction'));
        expect(bindings, isNot(contains('deprecatedFunction')));
      });

      test('structs', () {
        expect(bindings, contains('NormalStruct'));
        expect(bindings, isNot(contains('DeprecatedStruct')));
      });

      test('unions', () {
        expect(bindings, contains('NormalUnion'));
        expect(bindings, isNot(contains('DeprecatedUnion')));
      });

      test('enums', () {
        expect(bindings, contains('NormalEnum'));
        expect(bindings, isNot(contains('DeprecatedEnum')));
      });

      test('unnamed enums', () {
        expect(bindings, contains('normalUnnamedEnum'));
        expect(bindings, isNot(contains('deprecatedUnnamedEnum')));
      });
    });

    group('ios >=3.5, macos >=3.5', () {
      late final String bindings;
      setUpAll(() {
        bindings = bindingsForVersion(
          iosVers: Versions(min: Version(3, 5, 0)),
          macosVers: Versions(min: Version(3, 5, 0)),
        );
      });

      test('interfaces', () {
        expect(bindings, isNot(contains('DeprecatedInterface ')));
        expect(bindings, contains('DeprecatedInterfaceMethods '));
      });

      test('protocols', () {
        expect(bindings, isNot(contains('DeprecatedProtocol ')));
        expect(bindings, contains('DeprecatedProtocolMethods '));
      });

      test('interface methods', () {
        expect(bindings, contains('normalMethod'));
        expect(bindings, contains('unavailableMac'));
        expect(bindings, contains('unavailableIos'));
        expect(bindings, isNot(contains('unavailableBoth')));
        expect(bindings, contains('depMac2'));
        expect(bindings, contains('depMac3'));
        expect(bindings, contains('depIos2'));
        expect(bindings, isNot(contains('depIos2Mac2')));
        expect(bindings, isNot(contains('depIos2Mac3')));
        expect(bindings, contains('depIos3'));
        expect(bindings, isNot(contains('depIos3Mac2')));
        expect(bindings, isNot(contains('depIos3Mac3')));
        expect(bindings, isNot(contains('alwaysDeprecated')));
        expect(bindings, isNot(contains('alwaysUnavailable')));
      });

      test('interface properties', () {
        expect(bindings, contains('get normalProperty'));
        expect(bindings, contains('set normalProperty'));
        expect(bindings, isNot(contains('get deprecatedProperty')));
        expect(bindings, isNot(contains('set deprecatedProperty')));
      });

      test('protocol methods', () {
        expect(bindings, contains('protNormalMethod'));
        expect(bindings, contains('protUnavailableMac'));
        expect(bindings, contains('protUnavailableIos'));
        expect(bindings, isNot(contains('protUnavailableBoth')));
        expect(bindings, contains('protDepMac2'));
        expect(bindings, contains('protDepMac3'));
        expect(bindings, contains('protDepIos2'));
        expect(bindings, isNot(contains('protDepIos2Mac2')));
        expect(bindings, isNot(contains('protDepIos2Mac3')));
        expect(bindings, contains('protDepIos3'));
        expect(bindings, isNot(contains('protDepIos3Mac2')));
        expect(bindings, isNot(contains('protDepIos3Mac3')));
        expect(bindings, isNot(contains('protAlwaysDeprecated')));
        expect(bindings, isNot(contains('protAlwaysUnavailable')));
      });

      test('protocol properties', () {
        expect(bindings, contains('protNormalProperty'));
        expect(bindings, contains('setProtNormalProperty'));
        expect(bindings, isNot(contains('protDeprecatedProperty')));
        expect(bindings, isNot(contains('setProtDeprecatedProperty')));
      });

      test('category methods', () {
        expect(bindings, contains('catNormalMethod'));
        expect(bindings, contains('catUnavailableMac'));
        expect(bindings, contains('catUnavailableIos'));
        expect(bindings, isNot(contains('catUnavailableBoth')));
        expect(bindings, contains('catDepMac2'));
        expect(bindings, contains('catDepMac3'));
        expect(bindings, contains('catDepIos2'));
        expect(bindings, isNot(contains('catDepIos2Mac2')));
        expect(bindings, isNot(contains('catDepIos2Mac3')));
        expect(bindings, contains('catDepIos3'));
        expect(bindings, isNot(contains('catDepIos3Mac2')));
        expect(bindings, isNot(contains('catDepIos3Mac3')));
        expect(bindings, isNot(contains('catAlwaysDeprecated')));
        expect(bindings, isNot(contains('catAlwaysUnavailable')));
      });

      test('category properties', () {
        expect(bindings, contains('get catNormalProperty'));
        expect(bindings, contains('set catNormalProperty'));
        expect(bindings, isNot(contains('get catDeprecatedProperty')));
        expect(bindings, isNot(contains('set catDeprecatedProperty')));
      });

      test('functions', () {
        expect(bindings, contains('normalFunction'));
        expect(bindings, isNot(contains('deprecatedFunction')));
      });

      test('structs', () {
        expect(bindings, contains('NormalStruct'));
        expect(bindings, isNot(contains('DeprecatedStruct')));
      });

      test('unions', () {
        expect(bindings, contains('NormalUnion'));
        expect(bindings, isNot(contains('DeprecatedUnion')));
      });

      test('enums', () {
        expect(bindings, contains('NormalEnum'));
        expect(bindings, isNot(contains('DeprecatedEnum')));
      });

      test('unnamed enums', () {
        expect(bindings, contains('normalUnnamedEnum'));
        expect(bindings, isNot(contains('deprecatedUnnamedEnum')));
      });
    });

    group('ios >=2.5 <=3.5, macos >=2.5 <=3.5', () {
      late final String bindings;
      setUpAll(() {
        bindings = bindingsForVersion(
          iosVers: Versions(min: Version(2, 5, 0), max: Version(3, 5, 0)),
          macosVers: Versions(min: Version(2, 5, 0), max: Version(3, 5, 0)),
        );
      });

      test('interfaces', () {
        expect(bindings, isNot(contains('DeprecatedInterface ')));
        expect(bindings, contains('DeprecatedInterfaceMethods '));
      });

      test('protocols', () {
        expect(bindings, isNot(contains('DeprecatedProtocol ')));
        expect(bindings, contains('DeprecatedProtocolMethods '));
      });

      test('interface methods', () {
        expect(bindings, contains('normalMethod'));
        expect(bindings, contains('unavailableMac'));
        expect(bindings, contains('unavailableIos'));
        expect(bindings, isNot(contains('unavailableBoth')));
        expect(bindings, contains('depMac2'));
        expect(bindings, contains('depMac3'));
        expect(bindings, contains('depIos2'));
        expect(bindings, isNot(contains('depIos2Mac2')));
        expect(bindings, contains('depIos2Mac3'));
        expect(bindings, contains('depIos3'));
        expect(bindings, contains('depIos3Mac2'));
        expect(bindings, contains('depIos3Mac3'));
        expect(bindings, isNot(contains('alwaysDeprecated')));
        expect(bindings, isNot(contains('alwaysUnavailable')));
      });

      test('interface properties', () {
        expect(bindings, contains('get normalProperty'));
        expect(bindings, contains('set normalProperty'));
        expect(bindings, isNot(contains('get deprecatedProperty')));
        expect(bindings, isNot(contains('set deprecatedProperty')));
      });

      test('protocol methods', () {
        expect(bindings, contains('protNormalMethod'));
        expect(bindings, contains('protUnavailableMac'));
        expect(bindings, contains('protUnavailableIos'));
        expect(bindings, isNot(contains('protUnavailableBoth')));
        expect(bindings, contains('protDepMac2'));
        expect(bindings, contains('protDepMac3'));
        expect(bindings, contains('protDepIos2'));
        expect(bindings, isNot(contains('protDepIos2Mac2')));
        expect(bindings, contains('protDepIos2Mac3'));
        expect(bindings, contains('protDepIos3'));
        expect(bindings, contains('protDepIos3Mac2'));
        expect(bindings, contains('protDepIos3Mac3'));
        expect(bindings, isNot(contains('protAlwaysDeprecated')));
        expect(bindings, isNot(contains('protAlwaysUnavailable')));
      });

      test('protocol properties', () {
        expect(bindings, contains('protNormalProperty'));
        expect(bindings, contains('setProtNormalProperty'));
        expect(bindings, isNot(contains('protDeprecatedProperty')));
        expect(bindings, isNot(contains('setProtDeprecatedProperty')));
      });

      test('category methods', () {
        expect(bindings, contains('catNormalMethod'));
        expect(bindings, contains('catUnavailableMac'));
        expect(bindings, contains('catUnavailableIos'));
        expect(bindings, isNot(contains('catUnavailableBoth')));
        expect(bindings, contains('catDepMac2'));
        expect(bindings, contains('catDepMac3'));
        expect(bindings, contains('catDepIos2'));
        expect(bindings, isNot(contains('catDepIos2Mac2')));
        expect(bindings, contains('catDepIos2Mac3'));
        expect(bindings, contains('catDepIos3'));
        expect(bindings, contains('catDepIos3Mac2'));
        expect(bindings, contains('catDepIos3Mac3'));
        expect(bindings, isNot(contains('catAlwaysDeprecated')));
        expect(bindings, isNot(contains('catAlwaysUnavailable')));
      });

      test('category properties', () {
        expect(bindings, contains('get catNormalProperty'));
        expect(bindings, contains('set catNormalProperty'));
        expect(bindings, isNot(contains('get catDeprecatedProperty')));
        expect(bindings, isNot(contains('set catDeprecatedProperty')));
      });

      test('functions', () {
        expect(bindings, contains('normalFunction'));
        expect(bindings, isNot(contains('deprecatedFunction')));
      });

      test('structs', () {
        expect(bindings, contains('NormalStruct'));
        expect(bindings, isNot(contains('DeprecatedStruct')));
      });

      test('unions', () {
        expect(bindings, contains('NormalUnion'));
        expect(bindings, isNot(contains('DeprecatedUnion')));
      });

      test('enums', () {
        expect(bindings, contains('NormalEnum'));
        expect(bindings, isNot(contains('DeprecatedEnum')));
      });

      test('unnamed enums', () {
        expect(bindings, contains('normalUnnamedEnum'));
        expect(bindings, isNot(contains('deprecatedUnnamedEnum')));
      });
    });

    group('ios <=1.5, macos >=1.5', () {
      late final String bindings;
      setUpAll(() {
        bindings = bindingsForVersion(
          iosVers: Versions(max: Version(1, 5, 0)),
          macosVers: Versions(min: Version(1, 5, 0)),
        );
      });

      test('interfaces', () {
        expect(bindings, contains('DeprecatedInterface '));
        expect(bindings, contains('DeprecatedInterfaceMethods '));
      });

      test('protocols', () {
        expect(bindings, contains('DeprecatedProtocol '));
        expect(bindings, contains('DeprecatedProtocolMethods '));
      });

      test('interface methods', () {
        expect(bindings, contains('normalMethod'));
        expect(bindings, contains('unavailableMac'));
        expect(bindings, contains('unavailableIos'));
        expect(bindings, isNot(contains('unavailableBoth')));
        expect(bindings, contains('depMac2'));
        expect(bindings, contains('depMac3'));
        expect(bindings, contains('depIos2'));
        expect(bindings, contains('depIos2Mac2'));
        expect(bindings, contains('depIos2Mac3'));
        expect(bindings, contains('depIos3'));
        expect(bindings, contains('depIos3Mac2'));
        expect(bindings, contains('depIos3Mac3'));
        expect(bindings, isNot(contains('alwaysDeprecated')));
        expect(bindings, isNot(contains('alwaysUnavailable')));
      });

      test('interface properties', () {
        expect(bindings, contains('get normalProperty'));
        expect(bindings, contains('set normalProperty'));
        expect(bindings, contains('get deprecatedProperty'));
        expect(bindings, contains('set deprecatedProperty'));
      });

      test('protocol methods', () {
        expect(bindings, contains('protNormalMethod'));
        expect(bindings, contains('protUnavailableMac'));
        expect(bindings, contains('protUnavailableIos'));
        expect(bindings, isNot(contains('protUnavailableBoth')));
        expect(bindings, contains('protDepMac2'));
        expect(bindings, contains('protDepMac3'));
        expect(bindings, contains('protDepIos2'));
        expect(bindings, contains('protDepIos2Mac2'));
        expect(bindings, contains('protDepIos2Mac3'));
        expect(bindings, contains('protDepIos3'));
        expect(bindings, contains('protDepIos3Mac2'));
        expect(bindings, contains('protDepIos3Mac3'));
        expect(bindings, isNot(contains('protAlwaysDeprecated')));
        expect(bindings, isNot(contains('protAlwaysUnavailable')));
      });

      test('protocol properties', () {
        expect(bindings, contains('protNormalProperty'));
        expect(bindings, contains('setProtNormalProperty'));
        expect(bindings, contains('protDeprecatedProperty'));
        expect(bindings, contains('setProtDeprecatedProperty'));
      });

      test('category methods', () {
        expect(bindings, contains('catNormalMethod'));
        expect(bindings, contains('catUnavailableMac'));
        expect(bindings, contains('catUnavailableIos'));
        expect(bindings, isNot(contains('catUnavailableBoth')));
        expect(bindings, contains('catDepMac2'));
        expect(bindings, contains('catDepMac3'));
        expect(bindings, contains('catDepIos2'));
        expect(bindings, contains('catDepIos2Mac2'));
        expect(bindings, contains('catDepIos2Mac3'));
        expect(bindings, contains('catDepIos3'));
        expect(bindings, contains('catDepIos3Mac2'));
        expect(bindings, contains('catDepIos3Mac3'));
        expect(bindings, isNot(contains('catAlwaysDeprecated')));
        expect(bindings, isNot(contains('catAlwaysUnavailable')));
      });

      test('category properties', () {
        expect(bindings, contains('get catNormalProperty'));
        expect(bindings, contains('set catNormalProperty'));
        expect(bindings, contains('get catDeprecatedProperty'));
        expect(bindings, contains('set catDeprecatedProperty'));
      });

      test('functions', () {
        expect(bindings, contains('normalFunction'));
        expect(bindings, contains('deprecatedFunction'));
      });

      test('structs', () {
        expect(bindings, contains('NormalStruct'));
        expect(bindings, contains('DeprecatedStruct'));
      });

      test('unions', () {
        expect(bindings, contains('NormalUnion'));
        expect(bindings, contains('DeprecatedUnion'));
      });

      test('enums', () {
        expect(bindings, contains('NormalEnum'));
        expect(bindings, contains('DeprecatedEnum'));
      });

      test('unnamed enums', () {
        expect(bindings, contains('normalUnnamedEnum'));
        expect(bindings, contains('deprecatedUnnamedEnum'));
      });

      test('dart doc', () {
        final trimmed = bindings.split('\n').map((l) => l.trim()).join('\n');

        expect(
          trimmed,
          contains('''
/// iOS: introduced 1.0.0, deprecated 2.0.0
/// macOS: introduced 1.0.0, deprecated 2.0.0
final class DeprecatedStruct extends ffi.Struct'''),
        );

        expect(
          trimmed,
          contains('''
/// iOS: introduced 1.0.0, deprecated 2.0.0
/// macOS: introduced 1.0.0, deprecated 2.0.0
final class DeprecatedUnion extends ffi.Union'''),
        );

        expect(
          trimmed,
          contains('''
/// iOS: introduced 1.0.0, deprecated 2.0.0
/// macOS: introduced 1.0.0, deprecated 2.0.0
enum DeprecatedEnum'''),
        );

        expect(
          trimmed,
          contains('''
/// iOS: introduced 1.0.0, deprecated 2.0.0
/// macOS: introduced 1.0.0, deprecated 2.0.0

const int deprecatedUnnamedEnum = 1;
'''),
        );

        expect(
          trimmed,
          contains('''
/// iOS: introduced 1.0.0, deprecated 2.0.0
/// macOS: introduced 1.0.0, deprecated 2.0.0
int deprecatedFunction()'''),
        );

        expect(
          trimmed,
          contains('''
/// DeprecatedInterface
///
/// iOS: introduced 1.0.0, deprecated 2.0.0
/// macOS: introduced 1.0.0, deprecated 2.0.0
'''),
        );

        expect(
          trimmed,
          contains('''
/// depIos2Mac2
///
/// iOS: introduced 1.0.0, deprecated 2.0.0
/// macOS: introduced 1.0.0, deprecated 2.0.0
'''),
        );

        expect(
          trimmed,
          contains('''
/// DeprecatedProtocol
///
/// iOS: introduced 1.0.0, deprecated 2.0.0
/// macOS: introduced 1.0.0, deprecated 2.0.0
'''),
        );

        expect(
          trimmed,
          contains('''
/// protDepIos3
///
/// iOS: introduced 1.0.0, deprecated 3.0.0
'''),
        );

        expect(
          trimmed,
          contains('''
/// DeprecatedCategory
///
/// iOS: introduced 1.0.0, deprecated 2.0.0
/// macOS: introduced 1.0.0, deprecated 2.0.0
'''),
        );

        expect(
          trimmed,
          contains('''
/// DeprecatedCategoryMethods
///
/// iOS: introduced 2.0.0
/// macOS: introduced 10.0.0
'''),
        );
      });
    });

    group('ios >=0.5 <=0.9, macos >=0.5 <=0.9', () {
      late final String bindings;
      setUpAll(() {
        bindings = bindingsForVersion(
          iosVers: Versions(min: Version(0, 5, 0), max: Version(0, 9, 0)),
          macosVers: Versions(min: Version(0, 5, 0), max: Version(0, 9, 0)),
        );
      });

      test('interfaces', () {
        expect(bindings, isNot(contains('DeprecatedInterface ')));
        expect(bindings, contains('DeprecatedInterfaceMethods '));
      });

      test('protocols', () {
        expect(bindings, isNot(contains('DeprecatedProtocol ')));
        expect(bindings, contains('DeprecatedProtocolMethods '));
      });

      test('interface methods', () {
        expect(bindings, contains('normalMethod'));
        expect(bindings, contains('unavailableMac'));
        expect(bindings, contains('unavailableIos'));
        expect(bindings, isNot(contains('unavailableBoth')));
        expect(bindings, contains('depMac2'));
        expect(bindings, contains('depMac3'));
        expect(bindings, contains('depIos2'));
        expect(bindings, isNot(contains('depIos2Mac2')));
        expect(bindings, isNot(contains('depIos2Mac3')));
        expect(bindings, contains('depIos3'));
        expect(bindings, isNot(contains('depIos3Mac2')));
        expect(bindings, isNot(contains('depIos3Mac3')));
        expect(bindings, isNot(contains('alwaysDeprecated')));
        expect(bindings, isNot(contains('alwaysUnavailable')));
      });

      test('interface properties', () {
        expect(bindings, contains('get normalProperty'));
        expect(bindings, contains('set normalProperty'));
        expect(bindings, isNot(contains('get deprecatedProperty')));
        expect(bindings, isNot(contains('set deprecatedProperty')));
      });

      test('protocol methods', () {
        expect(bindings, contains('protNormalMethod'));
        expect(bindings, contains('protUnavailableMac'));
        expect(bindings, contains('protUnavailableIos'));
        expect(bindings, isNot(contains('protUnavailableBoth')));
        expect(bindings, contains('protDepMac2'));
        expect(bindings, contains('protDepMac3'));
        expect(bindings, contains('protDepIos2'));
        expect(bindings, isNot(contains('protDepIos2Mac2')));
        expect(bindings, isNot(contains('protDepIos2Mac3')));
        expect(bindings, contains('protDepIos3'));
        expect(bindings, isNot(contains('protDepIos3Mac2')));
        expect(bindings, isNot(contains('protDepIos3Mac3')));
        expect(bindings, isNot(contains('protAlwaysDeprecated')));
        expect(bindings, isNot(contains('protAlwaysUnavailable')));
      });

      test('protocol properties', () {
        expect(bindings, contains('protNormalProperty'));
        expect(bindings, contains('setProtNormalProperty'));
        expect(bindings, isNot(contains('protDeprecatedProperty')));
        expect(bindings, isNot(contains('setProtDeprecatedProperty')));
      });

      test('category methods', () {
        expect(bindings, isNot(contains('catNormalMethod')));
        expect(bindings, isNot(contains('catUnavailableMac')));
        expect(bindings, isNot(contains('catUnavailableIos')));
        expect(bindings, isNot(contains('catUnavailableBoth')));
        expect(bindings, isNot(contains('catDepMac2')));
        expect(bindings, isNot(contains('catDepMac3')));
        expect(bindings, isNot(contains('catDepIos2')));
        expect(bindings, isNot(contains('catDepIos2Mac2')));
        expect(bindings, isNot(contains('catDepIos2Mac3')));
        expect(bindings, isNot(contains('catDepIos3')));
        expect(bindings, isNot(contains('catDepIos3Mac2')));
        expect(bindings, isNot(contains('catDepIos3Mac3')));
        expect(bindings, isNot(contains('catAlwaysDeprecated')));
        expect(bindings, isNot(contains('catAlwaysUnavailable')));
      });

      test('category properties', () {
        expect(bindings, isNot(contains('get catNormalProperty')));
        expect(bindings, isNot(contains('set catNormalProperty')));
        expect(bindings, isNot(contains('get catDeprecatedProperty')));
        expect(bindings, isNot(contains('set catDeprecatedProperty')));
      });

      test('functions', () {
        expect(bindings, contains('normalFunction'));
        expect(bindings, isNot(contains('deprecatedFunction')));
      });

      test('structs', () {
        expect(bindings, contains('NormalStruct'));
        expect(bindings, isNot(contains('DeprecatedStruct')));
      });

      test('unions', () {
        expect(bindings, contains('NormalUnion'));
        expect(bindings, isNot(contains('DeprecatedUnion')));
      });

      test('enums', () {
        expect(bindings, contains('NormalEnum'));
        expect(bindings, isNot(contains('DeprecatedEnum')));
      });

      test('unnamed enums', () {
        expect(bindings, contains('normalUnnamedEnum'));
        expect(bindings, isNot(contains('deprecatedUnnamedEnum')));
      });
    });
  });
}
