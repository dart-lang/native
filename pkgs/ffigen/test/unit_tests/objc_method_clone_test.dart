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
      output: Output(dart: DartCodeOutput(path: Uri.file('unused'))),
      objectiveC: const ObjectiveC(),
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

    ObjCCategory makeCategory(
      String name,
      ObjCInterface parent,
      List<ObjCMethod> methods, {
      bool isIncluded = true,
    }) {
      final category = ObjCCategory(
        context: context,
        usr: name,
        originalName: name,
        parent: parent,
        apiAvailability: availability,
      )..isIncluded = isIncluded;
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

    test('copyMethod with originCategory sets originCategory', () {
      final method = makeMethod('catMethod', voidType, []);
      final parent = makeInterface('Parent', null, []);
      final category = makeCategory('Category', parent, [method]);
      final dest = makeInterface('Destination', null, []);

      dest.copyMethod(method, originCategory: category);

      expect(dest.methods.length, 1);
      final clonedMethod = dest.methods.single;
      expect(clonedMethod.originCategory, category);
    });

    test('copying a property with originCategory sets originCategory on getter '
        'and setter', () {
      final (getter, setter) = makeProperty('prop', intType);
      final parent = makeInterface('Parent', null, []);
      final category = makeCategory('Category', parent, [getter, setter]);
      final dest = makeInterface('Destination', null, []);

      dest.copyMethod(getter, originCategory: category);

      expect(dest.methods.length, 2);
      final clonedGetter = dest.methods.firstWhere(
        (m) => m.kind == ObjCMethodKind.propertyGetter,
      );
      final clonedSetter = dest.methods.firstWhere(
        (m) => m.kind == ObjCMethodKind.propertySetter,
      );

      expect(clonedGetter.originCategory, category);
      expect(clonedSetter.originCategory, category);
    });

    test('copyMethod preserves originCategory across multiple copies', () {
      final method = makeMethod('catMethod', voidType, []);
      final parent = makeInterface('Parent', null, []);
      final category = makeCategory('Category', parent, [method]);
      final mid = makeInterface('Mid', null, []);
      final dest = makeInterface('Destination', null, []);

      mid.copyMethod(method, originCategory: category);
      final midMethod = mid.methods.single;
      expect(midMethod.originCategory, category);

      dest.copyMethod(midMethod);
      final destMethod = dest.methods.single;
      expect(destMethod.originCategory, category);
    });

    test('clone with originCategory sets originCategory', () {
      final method = makeMethod('catMethod', voidType, []);
      final parent = makeInterface('Parent', null, []);
      final category = makeCategory('Category', parent, []);

      final cloned = method.clone(originCategory: category);
      expect(cloned.originCategory, category);
    });

    test('clone with originCategory overrides existing originCategory', () {
      final method = makeMethod('catMethod', voidType, []);
      final parent = makeInterface('Parent', null, []);
      final category1 = makeCategory('Category1', parent, []);
      final category2 = makeCategory('Category2', parent, []);

      method.originCategory = category1;
      final cloned = method.clone(originCategory: category2);
      expect(cloned.originCategory, category2);
    });

    test('clone property with originCategory sets originCategory on getter and '
        'setter', () {
      final (getter, setter) = makeProperty('prop', intType);
      final parent = makeInterface('Parent', null, []);
      final category = makeCategory('Category', parent, []);

      final clonedGetter = getter.clone(originCategory: category);
      expect(clonedGetter.originCategory, category);
      expect(clonedGetter.setter?.originCategory, category);
    });

    test(
      'clone property with originCategory overrides existing originCategory on '
      'getter and setter',
      () {
        final (getter, setter) = makeProperty('prop', intType);
        final parent = makeInterface('Parent', null, []);
        final category1 = makeCategory('Category1', parent, []);
        final category2 = makeCategory('Category2', parent, []);

        getter.originCategory = category1;
        setter.originCategory = category1;

        final clonedGetter = getter.clone(originCategory: category2);
        expect(clonedGetter.originCategory, category2);
        expect(clonedGetter.setter?.originCategory, category2);
      },
    );

    test('clone preserves originCategory', () {
      final method = makeMethod('catMethod', voidType, []);
      final parent = makeInterface('Parent', null, []);
      final category = makeCategory('Category', parent, [method]);
      final dest1 = makeInterface('Dest1', null, []);
      final dest2 = makeInterface('Dest2', null, []);

      dest1.copyMethod(method, originCategory: category);
      final dest1Method = dest1.methods.single;

      final cloned = dest1Method.clone(parent: dest2);
      expect(cloned.originCategory, category);
    });

    test('clone property preserves originCategory on getter and setter', () {
      final (getter, setter) = makeProperty('prop', intType);
      final parent = makeInterface('Parent', null, []);
      final category = makeCategory('Category', parent, []);

      getter.originCategory = category;
      setter.originCategory = category;

      final clonedGetter = getter.clone();
      expect(clonedGetter.originCategory, category);
      expect(clonedGetter.setter?.originCategory, category);
    });
  });
}
