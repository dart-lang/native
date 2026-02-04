// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:pub_semver/pub_semver.dart';
import 'package:record_use/record_use_internal.dart';
import 'package:test/test.dart';

void main() {
  const definition1 = Definition(
    identifier: Identifier(importUri: 'package:a/a.dart', name: 'definition1'),
    loadingUnit: '1',
  );
  const definition2 = Definition(
    identifier: Identifier(importUri: 'package:a/a.dart', name: 'definition2'),
    loadingUnit: '1',
  );
  const definition1differentUri = Definition(
    identifier: Identifier(importUri: 'package:a/b.dart', name: 'definition1'),
    loadingUnit: '1',
  );
  const definition1differentLoadingUnit = Definition(
    identifier: Identifier(importUri: 'package:a/a.dart', name: 'definition1'),
    loadingUnit: '2',
  );
  const definition3 = Definition(
    identifier: Identifier(
      importUri: 'package:a/a.dart',
      scope: 'SomeClass',
      name: 'definition1',
    ),
    loadingUnit: '1',
  );
  const callDefintion1Static = CallWithArguments(
    positionalArguments: [],
    namedArguments: {},
    loadingUnit: null,
    location: Location(uri: 'package:a/a.dart', line: 1, column: 1),
  );
  const callDefintion1Static2 = CallWithArguments(
    positionalArguments: [],
    namedArguments: {},
    loadingUnit: null,
    location: Location(uri: 'package:a/a.dart', line: 3, column: 1),
  );
  const callDefinition2Static = CallWithArguments(
    positionalArguments: [],
    namedArguments: {},
    loadingUnit: null,
    location: Location(uri: 'package:a/a.dart', line: 2, column: 2),
  );
  const callDefinition1TearOff = CallTearOff(
    loadingUnit: null,
    location: Location(uri: 'package:a/a.dart', line: 1, column: 1),
  );
  const definition1differentUri2 = Definition(
    identifier: Identifier(importUri: 'memory:a/a.dart', name: 'definition1'),
    loadingUnit: '1',
  );
  const callDefintion1StaticDifferentUri = CallWithArguments(
    positionalArguments: [],
    namedArguments: {},
    loadingUnit: null,
    location: Location(uri: 'memory:a/a.dart', line: 1, column: 1),
  );
  final metadata = Metadata(
    version: Version(1, 0, 0),
    comment: '',
  );

  test('Definition semantic equality', () {
    expect(definition1.semanticEquals(definition1), isTrue);
    expect(definition1.semanticEquals(definition2), isFalse);
    expect(definition1.semanticEquals(definition1differentUri), isFalse);
    expect(
      definition1.semanticEquals(
        definition1differentUri,
        uriMapping: (uri) => uri.replaceFirst('a.dart', 'b.dart'),
      ),
      isTrue,
    );
    expect(
      definition1.semanticEquals(definition1differentLoadingUnit),
      isFalse,
    );
    expect(
      definition1.semanticEquals(
        definition1differentLoadingUnit,
        loadingUnitMapping: (String unit) =>
            const <String, String>{'1': '2'}[unit] ?? unit,
      ),
      isTrue,
    );
    expect(definition1.semanticEquals(definition3), isFalse);
  });

  test('Strict equality', () {
    final recordings1 = Recordings(
      metadata: metadata,
      callsForDefinition: {
        definition1: [callDefintion1Static, callDefintion1Static2],
        definition2: [callDefinition2Static],
      },
      instancesForDefinition: const {},
    );
    final recordings2 = Recordings(
      metadata: metadata,
      callsForDefinition: {
        definition2: [callDefinition2Static],
        definition1: [callDefintion1Static2, callDefintion1Static],
      },
      instancesForDefinition: const {},
    );
    final recordings3 = Recordings(
      metadata: metadata,
      callsForDefinition: {
        definition1: [callDefintion1Static],
      },
      instancesForDefinition: const {},
    );
    // Identical.
    expect(recordings1.semanticEquals(recordings1), isTrue);
    // Equal, but reorderings.
    expect(recordings1.semanticEquals(recordings2), isTrue);
    // Not equal.
    expect(recordings1.semanticEquals(recordings3), isFalse);
  });

  test('otherIsSubset', () {
    final recordings1 = Recordings(
      metadata: metadata,
      callsForDefinition: {
        definition1: [callDefintion1Static],
        definition2: [callDefinition2Static],
      },
      instancesForDefinition: const {},
    );
    final recordings2 = Recordings(
      metadata: metadata,
      callsForDefinition: {
        definition1: [callDefintion1Static],
      },
      instancesForDefinition: const {},
    );
    expect(
      recordings1.semanticEquals(recordings2, expectedIsSubset: true),
      isTrue,
    );
    expect(
      recordings1.semanticEquals(recordings2, expectedIsSubset: false),
      isFalse,
    );
    // The arguments the wrong way around means something is missing.
    expect(
      recordings2.semanticEquals(recordings1, expectedIsSubset: true),
      isFalse,
    );
  });

  test('allowDeadCodeElimination', () {
    final recordings1 = Recordings(
      metadata: metadata,
      callsForDefinition: {
        definition1: [callDefintion1Static],
      },
      instancesForDefinition: const {},
    );
    final recordings2 = Recordings(
      metadata: metadata,
      callsForDefinition: {
        definition1: [callDefintion1Static],
        definition2: [callDefinition2Static],
      },
      instancesForDefinition: const {},
    );
    expect(
      recordings1.semanticEquals(
        recordings2,
        allowDeadCodeElimination: true,
      ),
      isTrue,
    );
    expect(
      recordings1.semanticEquals(
        recordings2,
        allowDeadCodeElimination: false,
      ),
      isFalse,
    );
    // Swapped arguments, that's not dead code elimination its an entry extra.
    expect(
      recordings2.semanticEquals(
        recordings1,
        allowDeadCodeElimination: true,
      ),
      isFalse,
    );
  });

  test('allowTearOffToStaticPromotion', () {
    final recordings1 = Recordings(
      metadata: metadata,
      callsForDefinition: {
        definition1: [callDefintion1Static],
      },
      instancesForDefinition: const {},
    );
    final recordings2 = Recordings(
      metadata: metadata,
      callsForDefinition: {
        definition1: [callDefinition1TearOff],
      },
      instancesForDefinition: const {},
    );
    expect(
      recordings1.semanticEquals(
        recordings2,
        allowTearOffToStaticPromotion: true,
      ),
      isTrue,
    );
    expect(
      recordings1.semanticEquals(
        recordings2,
        allowTearOffToStaticPromotion: false,
      ),
      isFalse,
    );
    // Don't allow downgrading a static call to a tear off.
    expect(
      recordings2.semanticEquals(
        recordings1,
        allowTearOffToStaticPromotion: true,
      ),
      isFalse,
    );
  });

  test('allowUriMismatch', () {
    final recordings1 = Recordings(
      metadata: metadata,
      callsForDefinition: {
        definition1: [
          callDefintion1Static,
        ],
      },
      instancesForDefinition: const {},
    );
    final recordings2 = Recordings(
      metadata: metadata,
      callsForDefinition: {
        definition1differentUri2: [
          callDefintion1StaticDifferentUri,
        ],
      },
      instancesForDefinition: const {},
    );
    expect(
      recordings1.semanticEquals(
        recordings2,
        uriMapping: (uri) => uri.replaceFirst('package:', 'memory:'),
      ),
      isTrue,
    );
    expect(
      recordings1.semanticEquals(recordings2),
      isFalse,
    );
  });

  test('CallWithArguments positional arguments different length', () {
    final recordings1 = Recordings(
      metadata: metadata,
      callsForDefinition: {
        definition1: [
          const CallWithArguments(
            positionalArguments: [IntConstant(1)],
            namedArguments: {},
            loadingUnit: null,
            location: Location(uri: 'package:a/a.dart', line: 1, column: 1),
          ),
        ],
      },
      instancesForDefinition: const {},
    );
    final recordings2 = Recordings(
      metadata: metadata,
      callsForDefinition: {
        definition1: [
          const CallWithArguments(
            positionalArguments: [IntConstant(1), IntConstant(2)],
            namedArguments: {},
            loadingUnit: null,
            location: Location(uri: 'package:a/a.dart', line: 1, column: 1),
          ),
        ],
      },
      instancesForDefinition: const {},
    );
    expect(
      recordings1.semanticEquals(recordings2),
      isFalse,
    );
  });
}
