// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
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

String bindingsForVersion({Version? iosMinVer, Version? macosMinVer}) {
  final config = Config(
    wrapperName: 'DeprecatedTestObjCLibrary',
    wrapperDocComment: 'Tests API deprecation',
    language: Language.objc,
    output: Uri.file('test/native_objc_test/deprecated_bindings.dart'),
    entryPoints: [Uri.file('test/native_objc_test/deprecated_test.m')],
    formatOutput: false,
    objcInterfaces: DeclarationFilters.include(
        {'DeprecatedInterfaceMethods', 'DeprecatedInterface'}),
    objcProtocols: DeclarationFilters.include(
        {'DeprecatedProtocolMethods', 'DeprecatedProtocol'}),
    functionDecl:
        DeclarationFilters.include({'normalFunction', 'deprecatedFunction'}),
    structDecl:
        DeclarationFilters.include({'NormalStruct', 'DeprecatedStruct'}),
    unionDecl: DeclarationFilters.include({'NormalUnion', 'DeprecatedUnion'}),
    enumClassDecl: DeclarationFilters.include({'NormalEnum', 'DeprecatedEnum'}),
    unnamedEnumConstants: DeclarationFilters.include(
        {'normalUnnamedEnum', 'deprecatedUnnamedEnum'}),
    externalVersions: ExternalVersions(
      ios: Versions(min: iosMinVer),
      macos: Versions(min: macosMinVer),
    ),
  );
  FfiGen(logLevel: Level.SEVERE).run(config);
  return File('test/native_objc_test/deprecated_bindings.dart')
      .readAsStringSync();
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

    group('ios 2.5, no macos version', () {
      late final String bindings;
      setUpAll(() {
        bindings = bindingsForVersion(
          iosMinVer: Version(2, 5, 0),
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

    group('ios 2.5, macos 2.5', () {
      late final String bindings;
      setUpAll(() {
        bindings = bindingsForVersion(
          iosMinVer: Version(2, 5, 0),
          macosMinVer: Version(2, 5, 0),
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

    group('ios 3.5, macos 3.5', () {
      late final String bindings;
      setUpAll(() {
        bindings = bindingsForVersion(
          iosMinVer: Version(3, 5, 0),
          macosMinVer: Version(3, 5, 0),
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
