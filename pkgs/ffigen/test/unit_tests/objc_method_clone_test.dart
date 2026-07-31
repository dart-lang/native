// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
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

    test('addMethod throws AssertionError if method already has a parent', () {
      final m = makeMethod('foo', voidType, []);
      final itf1 = makeInterface('Interface1', null, [m]);
      expect(m.parent, itf1);

      final itf2 = makeInterface('Interface2', null, []);
      expect(() => itf2.addMethod(m), throwsA(isA<AssertionError>()));
    });

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
  });
}
