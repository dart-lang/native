// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:pub_semver/pub_semver.dart';
import 'package:record_use/record_use_internal.dart';
import 'package:test/test.dart';

void main() {
  const identifier1 = Identifier(
    importUri: 'package:a/a.dart',
    name: 'definition1',
  );
  const identifier2 = Identifier(
    importUri: 'package:a/a.dart',
    name: 'definition2',
  );
  const identifier1differentUri = Identifier(
    importUri: 'package:a/b.dart',
    name: 'definition1',
  );
  const identifier3 = Identifier(
    importUri: 'package:a/a.dart',
    scope: 'SomeClass',
    name: 'definition1',
  );
  const callDefintion1Static = CallWithArguments(
    positionalArguments: [],
    namedArguments: {},
    loadingUnit: null,
  );
  const callDefintion1Static2 = CallWithArguments(
    positionalArguments: [],
    namedArguments: {},
    loadingUnit: null,
  );
  const callDefinition2Static = CallWithArguments(
    positionalArguments: [],
    namedArguments: {},
    loadingUnit: null,
  );
  const callDefinition1Tearoff = CallTearoff(
    loadingUnit: null,
  );
  const identifier1differentUri2 = Identifier(
    importUri: 'memory:a/a.dart',
    name: 'definition1',
  );
  const callDefintion1StaticDifferentUri = CallWithArguments(
    positionalArguments: [],
    namedArguments: {},
    loadingUnit: null,
  );
  final metadata = Metadata(
    version: Version(1, 0, 0),
    comment: '',
  );

  test('Identifier semantic equality', () {
    expect(identifier1.semanticEquals(identifier1), isTrue);
    expect(identifier1.semanticEquals(identifier2), isFalse);
    expect(identifier1.semanticEquals(identifier1differentUri), isFalse);
    expect(
      identifier1.semanticEquals(
        identifier1differentUri,
        uriMapping: (uri) => uri.replaceFirst('a.dart', 'b.dart'),
      ),
      isTrue,
    );
    expect(identifier1.semanticEquals(identifier3), isFalse);
  });

  test('Strict equality', () {
    final recordings1 = Recordings(
      metadata: metadata,
      calls: {
        identifier1: [callDefintion1Static, callDefintion1Static2],
        identifier2: [callDefinition2Static],
      },
      instances: const {},
    );
    final recordings2 = Recordings(
      metadata: metadata,
      calls: {
        identifier2: [callDefinition2Static],
        identifier1: [callDefintion1Static2, callDefintion1Static],
      },
      instances: const {},
    );
    final recordings3 = Recordings(
      metadata: metadata,
      calls: {
        identifier1: [callDefintion1Static],
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
        identifier1: [callDefintion1Static],
        identifier2: [callDefinition2Static],
      },
      instances: const {},
    );
    final recordings2 = Recordings(
      metadata: metadata,
      calls: {
        identifier1: [callDefintion1Static],
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
        identifier1: [callDefintion1Static],
      },
      instances: const {},
    );
    final recordings2 = Recordings(
      metadata: metadata,
      calls: {
        identifier1: [callDefintion1Static],
        identifier2: [callDefinition2Static],
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
        identifier1: [callDefintion1Static],
      },
      instances: const {},
    );
    final recordings2 = Recordings(
      metadata: metadata,
      calls: {
        identifier1: [callDefinition1Tearoff],
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
        identifier1: [
          callDefintion1Static,
        ],
      },
      instances: const {},
    );
    final recordings2 = Recordings(
      metadata: metadata,
      calls: {
        identifier1differentUri2: [
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
        identifier1: [
          const CallWithArguments(
            positionalArguments: [IntConstant(1)],
            namedArguments: {},
            loadingUnit: null,
          ),
        ],
      },
      instances: const {},
    );
    final recordings2 = Recordings(
      metadata: metadata,
      calls: {
        identifier1: [
          const CallWithArguments(
            positionalArguments: [IntConstant(1), IntConstant(2)],
            namedArguments: {},
            loadingUnit: null,
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
