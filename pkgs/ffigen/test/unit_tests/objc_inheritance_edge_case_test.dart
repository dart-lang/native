// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/config_provider/config.dart';
import 'package:ffigen/src/config_provider/config_types.dart';
import 'package:ffigen/src/context.dart';
import 'package:ffigen/src/header_parser/parser.dart';
import 'package:ffigen/src/header_parser/sub_parsers/api_availability.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  group('ObjC inheritance edge cases', () {
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
    final instanceType = Typealias(
      name: 'instancetype',
      type: ObjCObjectPointer(),
    );

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

    ObjCCategory makeCategory(
      String name,
      ObjCInterface parent,
      List<ObjCMethod> methods,
    ) {
      final category = ObjCCategory(
        context: context,
        usr: name,
        originalName: name,
        parent: parent,
      );
      parent.categories.add(category);
      for (final m in methods) {
        category.addMethod(m);
      }
      return category;
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
      // Regression test for https://github.com/dart-lang/native/issues/2419
      final parentMethod = makeMethod('method', instanceType, []);
      final childAMethod = makeMethod('method:', instanceType, [
        makeParam('a', intType),
      ]);
      final childBMethod = makeMethod('method:b:', instanceType, [
        makeParam('a', intType),
        makeParam('b', intType),
      ]);
      final childBOtherMethod = makeMethod('method:b:c:', instanceType, [
        makeParam('a', intType),
        makeParam('b', intType),
        makeParam('c', intType),
      ]);

      final parent = makeInterface('Parent', null, [parentMethod]);
      final childA = makeInterface('ChildA', parent, [childAMethod]);
      final childB = makeInterface(
        'ChildB',
        parent,
        [childBMethod, childBOtherMethod]..shuffle(),
      );

      final bindings = transformBindings(
        [parent, childA, childB]..shuffle(),
        context,
      );

      expect(bindings, contains(parent));
      expect(bindings, contains(childA));
      expect(bindings, contains(childB));

      expect(childA.methods, contains(parentMethod));
      expect(childA.methods, contains(childAMethod));
      expect(childB.methods, contains(parentMethod));
      expect(childB.methods, contains(childBMethod));
      expect(childB.methods, contains(childBOtherMethod));

      // Methods are renamed to avoid collisions between supertypes and subtypes
      // but not between two subtypes.
      expect(parentMethod.name, 'method');
      expect(childAMethod.name, 'method\$1');
      expect(childBMethod.name, 'method\$1');
      expect(childBOtherMethod.name, 'method\$2');
    });

    test('category method renaming', () {
      // Regression test for https://github.com/dart-lang/native/issues/2642
      final parentMethod = makeMethod('method', instanceType, []);
      final childMethod = makeMethod('method:', instanceType, [
        makeParam('a', intType),
      ]);
      final categoryMethod = makeMethod('method:b:', intType, [
        makeParam('a', intType),
        makeParam('b', intType),
      ]);

      final parent = makeInterface('Parent', null, [parentMethod]);
      final child = makeInterface('Child', parent, [childMethod]);
      final category = makeCategory('Category', child, [categoryMethod]);

      final bindings = transformBindings(
        [parent, child, category]..shuffle(),
        context,
      );

      expect(bindings, contains(parent));
      expect(bindings, contains(child));
      expect(bindings, contains(category));

      expect(child.methods, contains(parentMethod));
      expect(child.methods, contains(childMethod));
      expect(child.methods, isNot(contains(categoryMethod)));
      expect(category.methods, contains(categoryMethod));
      expect(category.methods, isNot(contains(childMethod)));

      // Category methods are renamed to avoid collisions with the methods of
      // the interface they extend.
      expect(parentMethod.name, 'method');
      expect(childMethod.name, 'method\$1');
      expect(categoryMethod.name, 'method\$2');
    });
  });
}
