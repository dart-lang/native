// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:record_use/record_use.dart';
import 'package:test/test.dart';

void main() {
  group('Recordings.+', () {
    const libA = Library('package:a/a.dart');
    const libB = Library('package:b/b.dart');

    const methodA = Method('funcA', libA);
    const methodB = Method('funcB', libB);

    const classA = Class('ClassA', libA);
    const classB = Class('ClassB', libB);

    const unitRoot = LoadingUnit('');
    const unitDeferred = LoadingUnit('deferred_unit');

    const callA1 = CallWithArguments(
      positionalArguments: [StringConstant('hello')],
      namedArguments: {},
      loadingUnit: unitRoot,
    );
    const callA2 = CallWithArguments(
      positionalArguments: [StringConstant('world')],
      namedArguments: {},
      loadingUnit: unitRoot,
    );
    const callADeferred = CallWithArguments(
      positionalArguments: [StringConstant('hello')],
      namedArguments: {},
      loadingUnit: unitDeferred,
    );
    const callATearoff = CallTearoff(loadingUnit: unitRoot);

    const callB1 = CallWithArguments(
      positionalArguments: [IntConstant(42)],
      namedArguments: {},
      loadingUnit: unitRoot,
    );

    const instanceA1 = InstanceConstantReference(
      instanceConstant: InstanceConstant(
        definition: classA,
        fields: {'name': StringConstant('A1')},
      ),
      loadingUnit: unitRoot,
    );
    const instanceA2 = InstanceCreationReference(
      definition: classA,
      positionalArguments: [IntConstant(1)],
      namedArguments: {},
      loadingUnit: unitRoot,
    );
    const instanceATearoff = ConstructorTearoffReference(
      definition: Constructor('named', classA),
      loadingUnit: unitRoot,
    );

    const instanceB1 = InstanceConstantReference(
      instanceConstant: InstanceConstant(
        definition: classB,
        fields: {'name': StringConstant('B1')},
      ),
      loadingUnit: unitRoot,
    );

    test('empty recordings', () {
      final empty1 = Recordings(calls: {}, instances: {});
      final empty2 = Recordings(calls: {}, instances: {});

      final combined = empty1 + empty2;
      expect(combined.calls, isEmpty);
      expect(combined.instances, isEmpty);
    });

    test('empty with non-empty', () {
      final empty = Recordings(calls: {}, instances: {});
      final rec = Recordings(
        calls: {
          methodA: [callA1],
        },
        instances: {
          classA: [instanceA1],
        },
      );

      final combined1 = empty + rec;
      expect(combined1.calls[methodA], [callA1]);
      expect(combined1.instances[classA], [instanceA1]);

      final combined2 = rec + empty;
      expect(combined2.calls[methodA], [callA1]);
      expect(combined2.instances[classA], [instanceA1]);
    });

    test('disjoint recordings', () {
      final rec1 = Recordings(
        calls: {
          methodA: [callA1],
        },
        instances: {
          classA: [instanceA1],
        },
      );
      final rec2 = Recordings(
        calls: {
          methodB: [callB1],
        },
        instances: {
          classB: [instanceB1],
        },
      );

      final combined = rec1 + rec2;
      expect(combined.calls.keys, containsAll([methodA, methodB]));
      expect(combined.instances.keys, containsAll([classA, classB]));
      expect(combined.calls[methodA], [callA1]);
      expect(combined.calls[methodB], [callB1]);
      expect(combined.instances[classA], [instanceA1]);
      expect(combined.instances[classB], [instanceB1]);
    });

    test('overlapping definitions combines references', () {
      final rec1 = Recordings(
        calls: {
          methodA: [callA1],
        },
        instances: {
          classA: [instanceA1],
        },
      );
      final rec2 = Recordings(
        calls: {
          methodA: [callA2, callATearoff],
        },
        instances: {
          classA: [instanceA2, instanceATearoff],
        },
      );

      final combined = rec1 + rec2;
      expect(combined.calls.keys, [methodA]);
      expect(combined.instances.keys, [classA]);
      expect(combined.calls[methodA], [callA1, callA2, callATearoff]);
      expect(
        combined.instances[classA],
        [instanceA1, instanceA2, instanceATearoff],
      );
    });

    test('preserves same reference in different loading units', () {
      final rec1 = Recordings(
        calls: {
          methodA: [callA1],
        },
        instances: {},
      );
      final rec2 = Recordings(
        calls: {
          methodA: [callADeferred],
        },
        instances: {},
      );

      final combined = rec1 + rec2;
      expect(combined.calls[methodA], hasLength(2));
      expect(combined.calls[methodA], [callA1, callADeferred]);

      // Serializing via toJson also preserves both because loadingUnit differs.
      final json = combined.toJson();
      final backAgain = Recordings.fromJson(json);
      expect(backAgain.calls[methodA], hasLength(2));
    });

    test('duplicate references are deduplicated on serialization', () {
      final rec1 = Recordings(
        calls: {
          methodA: [callA1],
        },
        instances: {
          classA: [instanceA1],
        },
      );
      final rec2 = Recordings(
        calls: {
          methodA: [callA1],
        },
        instances: {
          classA: [instanceA1],
        },
      );

      final combined = rec1 + rec2;
      // In-memory list contains references from both recordings.
      expect(combined.calls[methodA], [callA1, callA1]);
      expect(combined.instances[classA], [instanceA1, instanceA1]);

      // When serialized to JSON, canonicalization deduplicates identical
      // references.
      final json = combined.toJson();
      final roundTrip = Recordings.fromJson(json);
      expect(roundTrip.calls[methodA], [callA1]);
      expect(roundTrip.instances[classA], [instanceA1]);
    });

    test('does not mutate original recordings', () {
      final list1 = [callA1];
      final rec1 = Recordings(
        calls: {methodA: list1},
        instances: {},
      );
      final list2 = [callA2];
      final rec2 = Recordings(
        calls: {methodA: list2},
        instances: {},
      );

      final combined = rec1 + rec2;
      combined.calls[methodA]!.add(callB1);

      expect(rec1.calls[methodA], [callA1]);
      expect(rec2.calls[methodA], [callA2]);
    });

    test('combining canonicalizes shared constants across recordings', () {
      // Both recordings use the same integer constant 42.
      const sharedConst = IntConstant(42);
      final rec1 = Recordings(
        calls: {
          methodA: [
            const CallWithArguments(
              positionalArguments: [sharedConst],
              namedArguments: {},
              loadingUnit: unitRoot,
            ),
          ],
        },
        instances: {},
      );
      final rec2 = Recordings(
        calls: {
          methodB: [
            const CallWithArguments(
              positionalArguments: [sharedConst],
              namedArguments: {},
              loadingUnit: unitRoot,
            ),
          ],
        },
        instances: {},
      );

      final combined = rec1 + rec2;
      final json = combined.toJson();

      // Constants table in JSON should have exactly 1 entry for 42.
      final constants = json['constants'] as List;
      expect(constants, hasLength(1));
      expect(constants[0], {'type': 'int', 'value': 42});
    });

    test('serialization is commutative for operator +', () {
      final rec1 = Recordings(
        calls: {
          methodA: [callA1],
        },
        instances: {
          classA: [instanceA1],
        },
      );
      final rec2 = Recordings(
        calls: {
          methodB: [callB1],
        },
        instances: {
          classB: [instanceB1],
        },
      );

      final json12 = (rec1 + rec2).toJson();
      final json21 = (rec2 + rec1).toJson();

      expect(json12, equals(json21));
    });
  });
}
