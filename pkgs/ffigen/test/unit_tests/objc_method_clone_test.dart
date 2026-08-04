// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/config_provider/config.dart';
import 'package:ffigen/src/config_provider/config_types.dart';
import 'package:ffigen/src/context.dart';
import 'package:ffigen/src/header_parser/sub_parsers/api_availability.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  group('ObjC method clone', () {
    final availability = ApiAvailability(
      externalVersions: const ExternalVersions(),
    );
    final config = FfiGenerator(
      output: Output(dartFile: Uri.file('unused')),
      objectiveC: const ObjectiveC(
        interfaces: Interfaces.includeAll,
        categories: Categories.includeAll,
      ),
    );
    late Context context;
    final voidType = NativeType(SupportedNativeType.voidType);
    final intType = NativeType(SupportedNativeType.int32);

    void resetContext() {
      context = testContext(config);
    }

    setUp(resetContext);

    ObjCInterface makeInterface(
      String name,
      ObjCInterface? superType,
      List<ObjCMethod> methods,
    ) {
      final itf = ObjCInterface(
        context: context,
        usr: name,
        originalName: name,
        apiAvailability: availability,
      );
      if (superType != null) {
        itf.superType = superType;
        superType.subtypes.add(itf);
      }
      for (final m in methods) {
        itf.addMethod(m);
      }
      itf.filled = true;
      return itf;
    }

    ObjCMethod makeMethod(
      String name,
      Type returnType,
      List<Parameter> params, {
      bool isClassMethod = false,
    }) => ObjCMethod(
      context: context,
      originalName: name,
      name: name,
      kind: ObjCMethodKind.method,
      isClassMethod: isClassMethod,
      isOptional: false,
      returnType: returnType,
      family: null,
      apiAvailability: availability,
      params: params,
      ownershipAttribute: null,
      consumesSelfAttribute: false,
    );

    Parameter makeParam(String name, Type type) =>
        Parameter(name: name, type: type, objCConsumed: false);

    (ObjCMethod, ObjCMethod) makeProperty(String name, Type type) {
      final getter = ObjCMethod(
        context: context,
        originalName: name,
        name: name,
        kind: ObjCMethodKind.propertyGetter,
        isClassMethod: false,
        isOptional: false,
        returnType: type,
        family: null,
        apiAvailability: availability,
        params: const [],
        ownershipAttribute: null,
        consumesSelfAttribute: false,
      );
      final setter = ObjCMethod.withSymbol(
        context: context,
        originalName: 'set${name[0].toUpperCase()}${name.substring(1)}:',
        symbol: getter.symbol,
        protocolMethodName: 'set${name[0].toUpperCase()}${name.substring(1)}:',
        kind: ObjCMethodKind.propertySetter,
        isClassMethod: false,
        isOptional: false,
        returnType: voidType,
        params: [Parameter(name: 'value', type: type, objCConsumed: false)],
        family: null,
        apiAvailability: availability,
        ownershipAttribute: null,
        consumesSelfAttribute: false,
      );
      getter.setter = setter;
      return (getter, setter);
    }

    test(
      'copyMethod creates deep clone with parent set to destination container',
      () {
        final param = makeParam('p1', intType);
        final method = makeMethod('foo:', voidType, [param]);
        final source = makeInterface('Source', null, [method]);
        final dest = makeInterface('Destination', null, []);

        dest.copyMethod(method);

        expect(dest.methods.length, 1);
        final clonedMethod = dest.methods.single;
        expect(clonedMethod, isNot(same(method)));
        expect(clonedMethod.originalName, method.originalName);
        expect(clonedMethod.parent, dest);
        expect(method.parent, source);

        expect(clonedMethod.params.length, 1);
        final clonedParam = clonedMethod.params.single;
        expect(clonedParam, isNot(same(param)));
        expect(clonedParam.originalName, param.originalName);
      },
    );

    test('clone getter with linked setter', () {
      final (getter, setter) = makeProperty('foo', intType);
      final dest = makeInterface('Destination', null, []);
      final clonedGetter = getter.clone(parent: dest);
      final clonedSetter = clonedGetter.setter;

      expect(clonedSetter, isNotNull);
      expect(clonedGetter.symbol, clonedSetter!.symbol);
      expect(clonedGetter.symbol, isNot(getter.symbol));
      expect(clonedGetter.parent, dest);
      expect(clonedSetter.parent, dest);
      expect(clonedGetter.setter, clonedSetter);
    });

    test(
      'copying a property (getter + setter) to child interface via copyMethod',
      () {
        final (getter, setter) = makeProperty('foo', intType);
        final source = makeInterface('Source', null, [getter, setter]);
        final dest = makeInterface('Destination', null, []);

        dest.copyMethod(getter);

        expect(dest.methods.length, 2);
        final clonedGetter = dest.methods.firstWhere(
          (m) => m.kind == ObjCMethodKind.propertyGetter,
        );
        final clonedSetter = dest.methods.firstWhere(
          (m) => m.kind == ObjCMethodKind.propertySetter,
        );

        expect(clonedGetter.parent, dest);
        expect(clonedSetter.parent, dest);
        expect(clonedGetter.setter, clonedSetter);
        expect(clonedGetter.symbol, clonedSetter.symbol);
        expect(clonedGetter.symbol, isNot(getter.symbol));
        expect(source.methods.length, 2);
      },
    );
  });
}
