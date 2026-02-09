// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:pub_semver/pub_semver.dart';
import 'package:record_use/record_use_internal.dart';
import 'package:test/test.dart';

void main() {
  const identifier = Identifier(
    importUri: 'package:test/test.dart',
    name: 'MyClass',
  );

  final metadata = Metadata(
    version: Version(1, 0, 0),
    comment: 'Test for new instance formats',
  );

  final recordings = Recordings(
    metadata: metadata,
    calls: {},
    instances: {
      identifier: [
        const InstanceCreationReference(
          positionalArguments: [IntConstant(1), IntConstant(2)],
          namedArguments: {'param': StringConstant('named_arg_value')},
          loadingUnit: 'root',
        ),
        const ConstructorTearoffReference(loadingUnit: 'other'),
      ],
    },
  );

  test('Deserialize creation and tearoff instances', () {
    final instances = recordings.instances[identifier];
    expect(instances, isNotNull);
    expect(instances, hasLength(2));

    final creation = instances![0];
    expect(creation, isA<InstanceCreationReference>());
    if (creation is InstanceCreationReference) {
      expect(creation.loadingUnit, 'root');
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
      expect(tearoff.loadingUnit, 'other');
    }
  });

  test('Round trip serialization', () {
    final serializedJson = recordings.toJson();
    final roundTrippedRecordings = Recordings.fromJson(serializedJson);
    expect(roundTrippedRecordings, equals(recordings));
  });

  test('constantsOf filters out creation and tearoff', () {
    // We need to construct RecordedUsages from Recordings, but RecordedUsages
    // doesn't expose a constructor taking Recordings directly publicly?
    // It does via `RecordedUsages._(Recordings _recordings)`.
    // But we can go via JSON.
    final usages = RecordedUsages.fromJson(recordings.toJson());

    final constants = usages.constantsOf(identifier);
    expect(constants, isEmpty);
  });
}
