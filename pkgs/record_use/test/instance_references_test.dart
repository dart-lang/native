// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:record_use/record_use.dart';
import 'package:record_use/src/canonicalization_context.dart';
import 'package:record_use/src/recordings.dart';
import 'package:test/test.dart';

void main() {
  const definition = Class(
    'MyClass',
    Library('package:test/test.dart'),
  );

  const constructorDefinition = Constructor(
    '',
    definition,
  );

  const loadingUnitRoot = LoadingUnit('root');
  const loadingUnitOther = LoadingUnit('other');

  final recordings = Recordings(
    calls: {},
    instances: {
      definition: [
        const InstanceCreationReference(
          definition: constructorDefinition,
          positionalArguments: [IntConstant(1), IntConstant(2)],
          namedArguments: {'param': StringConstant('named_arg_value')},
          loadingUnit: loadingUnitRoot,
        ),
        const ConstructorTearoffReference(
          definition: constructorDefinition,
          loadingUnit: loadingUnitOther,
        ),
        const InstanceConstantReference(
          instanceConstant: EnumConstant(
            definition: definition,
            index: 0,
            name: 'value1',
          ),
          loadingUnit: loadingUnitRoot,
        ),
        const InstanceConstantReference(
          instanceConstant: EnumConstant(
            definition: definition,
            index: 1,
            name: 'enhancedValue',
            fields: {
              'description': StringConstant('A description'),
              'count': IntConstant(123),
              'nested': InstanceConstant(
                definition: definition,
                fields: {'inner': BoolConstant(true)},
              ),
            },
          ),
          loadingUnit: loadingUnitRoot,
        ),
      ],
    },
  );

  test('Deserialize creation and tearoff instances', () {
    final instances = recordings.instances[definition];
    expect(instances, isNotNull);
    expect(instances, hasLength(4));

    final creation = instances![0];
    expect(creation, isA<InstanceCreationReference>());
    if (creation is InstanceCreationReference) {
      expect(creation.definition, constructorDefinition);
      expect(creation.loadingUnit.name, loadingUnitRoot.name);
      expect(creation.positionalArguments, hasLength(2));
      expect(creation.positionalArguments[0], isA<IntConstant>());
      expect((creation.positionalArguments[0] as IntConstant).value, 1);
      expect((creation.positionalArguments[1] as IntConstant).value, 2);
      expect(creation.namedArguments, hasLength(1));
      expect(creation.namedArguments['param'], isA<StringConstant>());
      expect(
        (creation.namedArguments['param'] as StringConstant).value,
        'named_arg_value',
      );
    }

    final tearoff = instances[1];
    expect(tearoff, isA<ConstructorTearoffReference>());
    if (tearoff is ConstructorTearoffReference) {
      expect(tearoff.definition, constructorDefinition);
      expect(tearoff.loadingUnit.name, loadingUnitOther.name);
    }

    final enumInstance = instances[2];
    expect(enumInstance, isA<InstanceConstantReference>());
    if (enumInstance is InstanceConstantReference) {
      expect(enumInstance.instanceConstant, isA<EnumConstant>());
      expect((enumInstance.instanceConstant as EnumConstant).name, 'value1');
    }

    final enhancedEnumInstance = instances[3];
    expect(enhancedEnumInstance, isA<InstanceConstantReference>());
    if (enhancedEnumInstance is InstanceConstantReference) {
      expect(enhancedEnumInstance.instanceConstant, isA<EnumConstant>());
      final enumConstant =
          enhancedEnumInstance.instanceConstant as EnumConstant;
      expect(enumConstant.name, 'enhancedValue');
      expect(enumConstant.fields, hasLength(3));
      expect(
        (enumConstant.fields['description'] as StringConstant).value,
        'A description',
      );
      expect((enumConstant.fields['count'] as IntConstant).value, 123);
      final nested = enumConstant.fields['nested'] as InstanceConstant;
      expect((nested.fields['inner'] as BoolConstant).value, true);
    }
  });

  test('Round trip serialization', () {
    final canon = recordings.canonicalizeChildren(CanonicalizationContext());
    final serializedJson = canon.toJson();
    final roundTrippedRecordings = Recordings.fromJson(serializedJson);
    expect(roundTrippedRecordings, equals(canon));
  });
}
