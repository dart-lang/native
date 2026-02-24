// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:pub_semver/pub_semver.dart';
import 'package:record_use/record_use_internal.dart';
import 'package:test/test.dart';

void main() {
  const definition1 = Definition(
    'package:a/a.dart',
    [Name('definition1')],
  );
  const definition2 = Definition(
    'package:a/a.dart',
    [Name('definition2')],
  );
  const definition1differentLibrary = Definition(
    'package:a/b.dart',
    [Name('definition1')],
  );
  const definition3 = Definition(
    'package:a/a.dart',
    [Name('SomeClass'), Name('definition1')],
  );
  const callDefintion1Static = CallWithArguments(
    positionalArguments: [],
    namedArguments: {},
    loadingUnits: [],
  );
  const callDefintion1Static2 = CallWithArguments(
    positionalArguments: [],
    namedArguments: {},
    loadingUnits: [],
  );
  const callDefinition2Static = CallWithArguments(
    positionalArguments: [],
    namedArguments: {},
    loadingUnits: [],
  );
  const callDefinition1Tearoff = CallTearoff(
    loadingUnits: [],
  );
  const definition1differentLibrary2 = Definition(
    'memory:a/a.dart',
    [Name('definition1')],
  );
  const callDefintion1StaticDifferentUri = CallWithArguments(
    positionalArguments: [],
    namedArguments: {},
    loadingUnits: [],
  );
  final metadata = Metadata(
    version: Version(1, 0, 0),
    comment: '',
  );

  test('Definition semantic equality', () {
    expect(definition1.semanticEquals(definition1), isTrue);
    expect(definition1.semanticEquals(definition2), isFalse);
    expect(definition1.semanticEquals(definition1differentLibrary), isFalse);
    expect(
      definition1.semanticEquals(
        definition1differentLibrary,
        uriMapping: (uri) => uri.replaceFirst('a.dart', 'b.dart'),
      ),
      isTrue,
    );
    expect(definition1.semanticEquals(definition3), isFalse);
  });

  test('Strict equality', () {
    final recordings1 = Recordings(
      metadata: metadata,
      calls: {
        definition1: [callDefintion1Static, callDefintion1Static2],
        definition2: [callDefinition2Static],
      },
      instances: const {},
    );
    final recordings2 = Recordings(
      metadata: metadata,
      calls: {
        definition2: [callDefinition2Static],
        definition1: [callDefintion1Static2, callDefintion1Static],
      },
      instances: const {},
    );
    final recordings3 = Recordings(
      metadata: metadata,
      calls: {
        definition1: [callDefintion1Static],
      },
      instances: const {},
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
      calls: {
        definition1: [callDefintion1Static],
        definition2: [callDefinition2Static],
      },
      instances: const {},
    );
    final recordings2 = Recordings(
      metadata: metadata,
      calls: {
        definition1: [callDefintion1Static],
      },
      instances: const {},
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
      calls: {
        definition1: [callDefintion1Static],
      },
      instances: const {},
    );
    final recordings2 = Recordings(
      metadata: metadata,
      calls: {
        definition1: [callDefintion1Static],
        definition2: [callDefinition2Static],
      },
      instances: const {},
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

  test('allowTearoffToStaticPromotion', () {
    final recordings1 = Recordings(
      metadata: metadata,
      calls: {
        definition1: [callDefintion1Static],
      },
      instances: const {},
    );
    final recordings2 = Recordings(
      metadata: metadata,
      calls: {
        definition1: [callDefinition1Tearoff],
      },
      instances: const {},
    );
    expect(
      recordings1.semanticEquals(
        recordings2,
        allowTearoffToStaticPromotion: true,
      ),
      isTrue,
    );
    expect(
      recordings1.semanticEquals(
        recordings2,
        allowTearoffToStaticPromotion: false,
      ),
      isFalse,
    );
    // Don't allow downgrading a static call to a tear off.
    expect(
      recordings2.semanticEquals(
        recordings1,
        allowTearoffToStaticPromotion: true,
      ),
      isFalse,
    );
  });

  test('allowUriMismatch', () {
    final recordings1 = Recordings(
      metadata: metadata,
      calls: {
        definition1: [
          callDefintion1Static,
        ],
      },
      instances: const {},
    );
    final recordings2 = Recordings(
      metadata: metadata,
      calls: {
        definition1differentLibrary2: [
          callDefintion1StaticDifferentUri,
        ],
      },
      instances: const {},
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
      calls: {
        definition1: [
          const CallWithArguments(
            positionalArguments: [IntConstant(1)],
            namedArguments: {},
            loadingUnits: [],
          ),
        ],
      },
      instances: const {},
    );
    final recordings2 = Recordings(
      metadata: metadata,
      calls: {
        definition1: [
          const CallWithArguments(
            positionalArguments: [IntConstant(1), IntConstant(2)],
            namedArguments: {},
            loadingUnits: [],
          ),
        ],
      },
      instances: const {},
    );
    expect(
      recordings1.semanticEquals(recordings2),
      isFalse,
    );
  });
}
