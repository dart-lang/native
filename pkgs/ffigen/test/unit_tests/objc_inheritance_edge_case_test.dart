// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/context.dart';
import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/code_generator/unique_namer.dart';
import 'package:ffigen/src/config_provider/config.dart';
import 'package:ffigen/src/config_provider/config_types.dart';
import 'package:ffigen/src/header_parser/parser.dart';
import 'package:ffigen/src/header_parser/sub_parsers/api_availability.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  group('ObjC inheritance edge cases', () {
    final builtInFunctions = ObjCBuiltInFunctions('', false);
    final availability = ApiAvailability(
      externalVersions: const ExternalVersions(),
    );
    final config = FfiGen(
      Logger.root,
      output: Uri.file('unused'),
      objcInterfaces: DeclarationFilters.includeAll,
    );
    final context = testContext(config);
    final voidType = NativeType(SupportedNativeType.voidType);
    final intType = NativeType(SupportedNativeType.int32);
    final instanceType = Typealias(
      name: 'instancetype',
      type: ObjCObjectPointer(),
    );

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
      for (final m in methods) itf.addMethod(m);
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
      params_: params,
    )..finalizeParams();

    Parameter makeParam(String name, Type type) =>
        Parameter(name: name, type: type, objCConsumed: false);

    test('simple method inheritance', () {
      final ordinaryMethod = makeMethod('m1', voidType, []);
      final staticMethod = makeMethod('m2', voidType, [], isClassMethod: true);
      final instanceTypeMethod = makeMethod('m3', instanceType, []);

      final parent = makeInterface('Parent', null, [
        ordinaryMethod,
        staticMethod,
        instanceTypeMethod,
      ]);
      final child = makeInterface('Child', parent, []);

      final bindings = transformBindings([parent, child], context);

      expect(bindings, contains(parent));
      expect(bindings, contains(child));

      expect(child.methods, isNot(contains(ordinaryMethod)));
      expect(child.methods, contains(staticMethod));
      expect(child.methods, contains(instanceTypeMethod));
    });

    test('inherited method renaming', () {
      final parentMethod = makeMethod('method', instanceType, []);
      final childAMethod = makeMethod('method:', instanceType, [
        makeParam('a', intType),
      ]);
      final childBMethod = makeMethod('method:b:', instanceType, [
        makeParam('a', intType),
        makeParam('b', intType),
      ]);

      final parent = makeInterface('Parent', null, [parentMethod]);
      final childA = makeInterface('ChildA', parent, [childAMethod]);
      final childB = makeInterface('ChildB', parent, [childBMethod]);

      final bindings = transformBindings([parent, childA, childB], context);

      expect(bindings, contains(parent));
      expect(bindings, contains(childA));
      expect(bindings, contains(childB));

      expect(childA.methods, contains(parentMethod));
      expect(childA.methods, contains(childAMethod));
      expect(childB.methods, contains(parentMethod));
      expect(childB.methods, contains(childBMethod));

      final namer = UniqueNamer();
      print('ZXCV: ${parentMethod.getDartMethodName(namer)}');
      print('ZXCV: ${childAMethod.getDartMethodName(namer)}');
      print('ZXCV: ${childBMethod.getDartMethodName(namer)}');
    });
  });
}
