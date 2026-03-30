// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:record_use/record_use.dart';
import 'package:test/test.dart';

void main() {
  const definition1 = Method(
    'definition1',
    Library('package:a/a.dart'),
  );
  const definition2 = Method(
    'definition2',
    Library('package:a/a.dart'),
  );
  const definition1differentLibrary = Method(
    'definition1',
    Library('package:a/b.dart'),
  );
  const definition3 = Method(
    'definition1',
    Class('SomeClass', Library('package:a/a.dart')),
    isInstanceMember: true,
  );

  const classDefinition1 = Class(
    'Class1',
    Library('package:a/a.dart'),
  );

  const callDefintion1Static = CallWithArguments(
    positionalArguments: [],
    namedArguments: {},
    loadingUnit: LoadingUnit(''),
  );
  const callDefintion1Static2 = CallWithArguments(
    positionalArguments: [],
    namedArguments: {},
    loadingUnit: LoadingUnit(''),
  );
  const callDefinition2Static = CallWithArguments(
    positionalArguments: [],
    namedArguments: {},
    loadingUnit: LoadingUnit(''),
  );
  const callDefinition1Tearoff = CallTearoff(
    loadingUnit: LoadingUnit(''),
  );
  const definition1differentLibrary2 = Method(
    'definition1',
    Library('memory:a/a.dart'),
  );
  const callDefintion1StaticDifferentUri = CallWithArguments(
    positionalArguments: [],
    namedArguments: {},
    loadingUnit: LoadingUnit(''),
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
      calls: {
        definition1: [callDefintion1Static, callDefintion1Static2],
        definition2: [callDefinition2Static],
      },
      instances: const {},
    );
    final recordings2 = Recordings(
      calls: {
        definition2: [callDefinition2Static],
        definition1: [callDefintion1Static2, callDefintion1Static],
      },
      instances: const {},
    );
    final recordings3 = Recordings(
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
      calls: {
        definition1: [callDefintion1Static],
        definition2: [callDefinition2Static],
      },
      instances: const {},
    );
    final recordings2 = Recordings(
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
      calls: {
        definition1: [callDefintion1Static],
      },
      instances: const {},
    );
    final recordings2 = Recordings(
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
      calls: {
        definition1: [callDefintion1Static],
      },
      instances: const {},
    );
    final recordings2 = Recordings(
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
      calls: {
        definition1: [
          callDefintion1Static,
        ],
      },
      instances: const {},
    );
    final recordings2 = Recordings(
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
      calls: {
        definition1: [
          const CallWithArguments(
            positionalArguments: [IntConstant(1)],
            namedArguments: {},
            loadingUnit: LoadingUnit(''),
          ),
        ],
      },
      instances: const {},
    );
    final recordings2 = Recordings(
      calls: {
        definition1: [
          const CallWithArguments(
            positionalArguments: [IntConstant(1), IntConstant(2)],
            namedArguments: {},
            loadingUnit: LoadingUnit(''),
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

  test('InstanceConstantReference semantic equality with EnumConstant', () {
    final recordings1 = Recordings(
      calls: const {},
      instances: {
        classDefinition1: [
          const InstanceConstantReference(
            instanceConstant: EnumConstant(
              definition: classDefinition1,
              index: 0,
              name: 'a',
              fields: {'f': IntConstant(1)},
            ),
            loadingUnit: LoadingUnit(''),
          ),
        ],
      },
    );
    final recordings2 = Recordings(
      calls: const {},
      instances: {
        classDefinition1: [
          const InstanceConstantReference(
            instanceConstant: EnumConstant(
              definition: classDefinition1,
              index: 0,
              name: 'a',
              fields: {'f': IntConstant(1)},
            ),
            loadingUnit: LoadingUnit(''),
          ),
        ],
      },
    );
    final recordings3 = Recordings(
      calls: const {},
      instances: {
        classDefinition1: [
          const InstanceConstantReference(
            instanceConstant: EnumConstant(
              definition: classDefinition1,
              index: 1,
              name: 'b',
              fields: {'f': IntConstant(1)},
            ),
            loadingUnit: LoadingUnit(''),
          ),
        ],
      },
    );

    expect(recordings1.semanticEquals(recordings2), isTrue);
    expect(recordings1.semanticEquals(recordings3), isFalse);
  });

  test('SetConstant semantic equality', () {
    const set1 = SetConstant([IntConstant(1), IntConstant(2)]);
    const set2 = SetConstant([IntConstant(2), IntConstant(1)]);
    const set3 = SetConstant([IntConstant(1), IntConstant(3)]);
    const set4 = SetConstant([IntConstant(1)]);

    expect(set1.semanticEquals(set1), isTrue);
    expect(set1.semanticEquals(set2), isTrue);
    expect(set1.semanticEquals(set3), isFalse);
    expect(set1.semanticEquals(set4), isFalse);

    const unsupported = UnsupportedConstant('MethodTearoff');
    const setWithUnsupported = SetConstant([IntConstant(1), unsupported]);
    const setWithInt2 = SetConstant([
      IntConstant(1),
      IntConstant(2),
    ]);

    // unsupported does not match IntConstant(2) by default
    expect(setWithInt2.semanticEquals(setWithUnsupported), isFalse);

    // unsupported matches any constant when promotion is allowed
    expect(
      setWithInt2.semanticEquals(
        setWithUnsupported,
        allowPromotionOfUnsupported: true,
      ),
      isTrue,
    );
  });
}
