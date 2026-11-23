import 'package:jni/jni.dart';
import 'package:test/test.dart';

import 'test_util/test_util.dart';

void main() {
  setUpAll(spawnJvm);

  group('converter', () {
    test('basics', () {
      expect(toJObject(false), isA<JBoolean>());
      expect(toJObject(true), isA<JBoolean>());

      expect(toDartObject(toJObject(false)), isFalse);
      expect(toDartObject(toJObject(true)), isTrue);

      expect(toJObject(123), isA<JLong>());
      expect(toDartObject(toJObject(123)), 123);

      expect(toJObject(1.23), isA<JDouble>());
      expect(toDartObject(toJObject(1.23)), 1.23);

      expect(toJObject('hello'), isA<JString>());
      expect(toDartObject(toJObject('hello')), 'hello');
    });

    test('list', () {
      final dartList = <Object>[123, 'abc', true];

      final javaList = toJObject(dartList);

      expect(javaList, isA<JList>());
      expect(toDartObject(javaList), dartList);
    });

    test('nested list', () {
      final dartList = <Object>[
        123,
        <Object>['abc', false],
      ];

      expect(
        toDartObject(toJObject(dartList)),
        dartList,
      );
    });

    test('set', () {
      final dartSet = <Object>{
        123,
        'abc',
        true,
      };

      expect(
        toJObject(dartSet),
        isA<JSet>(),
      );

      final javaSet = toJObject(dartSet) as JSet<JObject>;

      expect(
        javaSet.asDart().length,
        3,
      );

      expect(
        javaSet.asDart().contains(
              toJObject(123),
            ),
        isTrue,
      );

      expect(
        javaSet.asDart().contains(
              toJObject('abc'),
            ),
        isTrue,
      );

      expect(
        javaSet.asDart().contains(
              toJObject(true),
            ),
        isTrue,
      );

      expect(
        toDartObject(javaSet),
        dartSet,
      );

      final nestedDartSet = <Object>{
        1,
        <Object>{2, 3},
        <Object>{
          4,
          <Object>{5},
        },
      };

      final nestedJavaSet = toJObject(nestedDartSet);

      expect(
        toDartObject(nestedJavaSet),
        nestedDartSet,
      );
    });

    test('map', () {
      final dartMap = <Object, Object>{
        123: 'abc',
        'def': 456,
        true: 1.23,
      };

      expect(
        toJObject(dartMap),
        isA<JMap>(),
      );

      final javaMap = toJObject(dartMap) as JMap<JObject, JObject>;

      expect(
        javaMap.asDart().length,
        3,
      );

      expect(
        toDartObject(
          javaMap.asDart()[toJObject(123)]!,
        ),
        'abc',
      );

      expect(
        toDartObject(
          javaMap.asDart()[toJObject('def')]!,
        ),
        456,
      );

      expect(
        toDartObject(
          javaMap.asDart()[toJObject(true)]!,
        ),
        1.23,
      );

      expect(
        toDartObject(javaMap),
        dartMap,
      );

      final nestedDartMap = <Object, Object>{
        1: <Object, Object>{
          2: 3,
        },
        4: <Object, Object>{
          5: <Object, Object>{
            6: 7,
          },
        },
      };

      final nestedJavaMap = toJObject(nestedDartMap);

      expect(
        toDartObject(nestedJavaMap),
        nestedDartMap,
      );
    });

    test('primitive arrays', () {
      expect(
        toDartObject(
          JBooleanArray.of(
            [true, false, true],
          ),
        ),
        [true, false, true],
      );

      expect(
        toDartObject(
          JByteArray.of(
            [1, 2, 3],
          ),
        ),
        [1, 2, 3],
      );

      expect(
        toDartObject(
          JCharArray.of(
            [65, 66, 67],
          ),
        ),
        [65, 66, 67],
      );

      expect(
        toDartObject(
          JShortArray.of(
            [1, 2, 3],
          ),
        ),
        [1, 2, 3],
      );

      expect(
        toDartObject(
          JIntArray.of(
            [1, 2, 3],
          ),
        ),
        [1, 2, 3],
      );

      expect(
        toDartObject(
          JLongArray.of(
            [1, 2, 3],
          ),
        ),
        [1, 2, 3],
      );

      expect(
        toDartObject(
          JFloatArray.of(
            [1.0, 2.0, 3.0],
          ),
        ),
        [1.0, 2.0, 3.0],
      );

      expect(
        toDartObject(
          JDoubleArray.of(
            [1.0, 2.0, 3.0],
          ),
        ),
        [1.0, 2.0, 3.0],
      );
    });

    test('unsupported type', () {
      expect(
        () => toJObject(Future<void>.value()),
        throwsA(isA<UnimplementedError>()),
      );

      final obj = JClass.forName('java/lang/Object');

      try {
        expect(toJObject(obj), same(obj));
        expect(toDartObject(obj), same(obj));
      } finally {
        obj.release();
      }
    });

    test('custom converter in toJObject', () {
      final future = Future<void>.value();

      JObject conv(Object _) => 'converted'.toJString();

      expect(
        toDartObject(
          toJObject(
            future,
            convertOther: conv,
          ),
        ),
        'converted',
      );

      final list = toJObject(
        <Object>[123, future],
        convertOther: conv,
      );

      expect(
        toDartObject(list),
        <Object>[123, 'converted'],
      );
    });

    test('custom converter in toDartObject', () {
      final future = Future<void>.value();
      final obj = JClass.forName('java/lang/Object');

      try {
        Object conv(JObject _) => future;

        expect(
          toDartObject(
            obj,
            convertOther: conv,
          ),
          same(future),
        );

        final list = toJObject(
          <Object>['abc', obj],
        );

        expect(
          toDartObject(
            list,
            convertOther: conv,
          ),
          <Object>['abc', future],
        );
      } finally {
        obj.release();
      }
    });

    test('nullable object', () {
      expect(
        toNullableDartObject(null),
        isNull,
      );

      final javaString = 'hello'.toJString();

      expect(
        toNullableDartObject(javaString),
        'hello',
      );
    });

    test('null in list', () {
      final javaList = <JObject?>[
        'abc'.toJString(),
        null,
        123.toJLong(),
      ].toJList();

      expect(
        toDartObject(javaList),
        <Object?>['abc', null, 123],
      );
    });

    test('typed collection conversion', () {
      final javaList = <JObject?>[
        1.toJLong(),
        2.toJLong(),
      ].toJList();

      final dartList = javaList.toDartList();

      expect(
        dartList.cast<int>(),
        <int>[1, 2],
      );

      final javaSet = <JObject?>{
        'a'.toJString(),
        'b'.toJString(),
      }.toJSet();

      final dartSet = javaSet.toDartSet();

      expect(
        dartSet.cast<String>(),
        <String>{'a', 'b'},
      );

      final javaMap = <JObject?, JObject?>{
        'one'.toJString(): 1.toJLong(),
        'two'.toJString(): 2.toJLong(),
      }.toJMap();

      final dartMap = javaMap.toDartMap();

      expect(
        dartMap.cast<String, int>(),
        <String, int>{
          'one': 1,
          'two': 2,
        },
      );
    });

    test('object array is detected as JObject array', () {
      final array = JArray.of(
        JString.type,
        <JString>[
          'a'.toJString(),
          'b'.toJString(),
        ],
      );

      expect(
        array.isA(
          JArray.type(JObject.type),
        ),
        isTrue,
      );
    });

    test('object array', () {
      final array = JArray.of(
        JString.type,
        <JString>[
          'a'.toJString(),
          'b'.toJString(),
        ],
      );

      expect(
        toDartObject(array),
        <Object?>['a', 'b'],
      );
    });

    test('object array with null', () {
      final array = JArray.of(
        JObject.type,
        <JObject?>[
          'a'.toJString(),
          null,
          123.toJLong(),
        ],
      );

      expect(
        toDartObject(array),
        <Object?>['a', null, 123],
      );
    });

    test('object array deep conversion', () {
      final array = JArray.of(
        JObject.type,
        <JObject?>[
          'abc'.toJString(),
          null,
          123.toJLong(),
        ],
      );

      expect(
        array.toDartList(),
        <Object?>['abc', null, 123],
      );
    });

    test('custom converter in object array', () {
      final obj = JClass.forName('java/lang/Object');

      try {
        final array = JArray.of(
          JObject.type,
          <JObject?>[
            'abc'.toJString(),
            obj,
          ],
        );

        Object conv(JObject _) => 'converted';

        expect(
          array.toDartList(
            convertOther: conv,
          ),
          <Object?>['abc', 'converted'],
        );

        expect(
          toDartObject(
            array,
            convertOther: conv,
          ),
          <Object?>['abc', 'converted'],
        );
      } finally {
        obj.release();
      }
    });

    test('nullable Dart object', () {
      expect(
        toNullableJObject(null),
        isNull,
      );

      final javaString = toNullableJObject('hello');

      expect(
        javaString,
        isA<JString>(),
      );

      expect(
        toDartObject(javaString!),
        'hello',
      );
    });

    test('null in Dart list', () {
      final dartList = <Object?>[
        'abc',
        null,
        123,
      ];

      final javaList = toJObject(dartList);

      expect(
        toDartObject(javaList),
        dartList,
      );
    });

    test('null in Dart set', () {
      final dartSet = <Object?>{
        'abc',
        null,
        123,
      };

      final javaSet = toJObject(dartSet);

      expect(
        toDartObject(javaSet),
        dartSet,
      );
    });

    test('null in Dart map', () {
      final dartMap = <Object?, Object?>{
        'value': null,
        null: 123,
      };

      final javaMap = toJObject(dartMap);

      expect(
        toDartObject(javaMap),
        dartMap,
      );
    });

    test('nested null conversion', () {
      final dartObject = <Object?>[
        1,
        null,
        <Object?>[
          'abc',
          null,
        ],
        <Object?, Object?>{
          'key': null,
        },
      ];

      expect(
        toDartObject(toJObject(dartObject)),
        dartObject,
      );
    });

    test('Dart list to object array', () {
      final dartList = <Object?>[
        'abc',
        123,
        null,
        true,
      ];

      final javaArray = dartList.toJArray();

      expect(
        toDartObject(javaArray),
        dartList,
      );
    });

    test('Dart list to nested object array', () {
      final dartList = <Object?>[
        'abc',
        null,
        <Object?>[
          123,
          true,
        ],
      ];

      final javaArray = dartList.toJArray();

      expect(
        toDartObject(javaArray),
        dartList,
      );
    });
  });

  group('global reference leaks', () {
    test('JList.toDartList does not leak elements or nested collections', () {
      using((arena) {
        final innerStr = 'nested-list-element'.toJString();
        final innerStrWeakRef = makeWeakRef(innerStr, arena);
        final innerList = [innerStr].toJList();
        innerStr.release();
        final innerListWeakRef = makeWeakRef(innerList, arena);

        final outerStr = 'outer-list-element'.toJString();
        final outerStrWeakRef = makeWeakRef(outerStr, arena);
        final outerList = <JObject?>[outerStr, innerList].toJList();
        outerStr.release();
        innerList.release();

        expect(
          outerList.toDartList(),
          [
            'outer-list-element',
            ['nested-list-element']
          ],
        );

        // Clear and release the top-level list so only leaked JNI global refs
        // could keep the elements or nested list alive.
        outerList.clear();
        outerList.release();

        expect(
          isJavaObjectCollected(outerStrWeakRef),
          isTrue,
          reason: 'JList.toDartList leaked an element global reference',
        );
        expect(
          isJavaObjectCollected(innerListWeakRef),
          isTrue,
          reason: 'JList.toDartList leaked a nested JList global reference',
        );
        expect(
          isJavaObjectCollected(innerStrWeakRef),
          isTrue,
          reason: 'JList.toDartList leaked a nested element global reference',
        );
      });
    });

    test('JArray.toDartList does not leak elements or nested collections', () {
      using((arena) {
        final innerStr = 'array-nested-element'.toJString();
        final innerStrWeakRef = makeWeakRef(innerStr, arena);
        final innerList = [innerStr].toJList();
        innerStr.release();
        final innerListWeakRef = makeWeakRef(innerList, arena);

        final elemStr = 'array-element'.toJString();
        final elemStrWeakRef = makeWeakRef(elemStr, arena);
        final array = JArray.of<JObject?>(
          JObject.type,
          <JObject?>[elemStr, innerList],
        );
        elemStr.release();
        innerList.release();

        expect(
          array.toDartList(),
          [
            'array-element',
            ['array-nested-element']
          ],
        );

        array[0] = null;
        array[1] = null;
        array.release();

        expect(
          isJavaObjectCollected(elemStrWeakRef),
          isTrue,
          reason: 'JArray.toDartList leaked an element global reference',
        );
        expect(
          isJavaObjectCollected(innerListWeakRef),
          isTrue,
          reason: 'JArray.toDartList leaked a nested JList global reference',
        );
        expect(
          isJavaObjectCollected(innerStrWeakRef),
          isTrue,
          reason: 'JArray.toDartList leaked a nested element global reference',
        );
      });
    });

    test('JSet.toDartSet does not leak iterator', () {
      using((arena) {
        final collectionsClass = JClass.forName('java/util/Collections')
          ..releasedBy(arena);
        final singletonSet = collectionsClass.staticMethodId(
          'singleton',
          '(Ljava/lang/Object;)Ljava/util/Set;',
        );

        final str = 'singleton-set-element'.toJString();
        final strWeakRef = makeWeakRef(str, arena);
        // HashSet.iterator() holds a reference to its private backing HashMap
        // rather than the HashSet itself, whereas
        // Collections.singleton(e).iterator() directly captures `e` so leaking
        // the JIterator keeps `str` alive.
        final set = singletonSet(collectionsClass, JSet.type, [str]);
        str.release();

        expect(set.toDartSet(), {'singleton-set-element'});
        set.release();

        expect(
          isJavaObjectCollected(strWeakRef),
          isTrue,
          reason: 'JSet.toDartSet leaked its JIterator or element global ref',
        );
      });
    });

    test('JSet.toDartSet does not leak elements or nested collections', () {
      using((arena) {
        final innerStr = 'nested-set-element'.toJString();
        final innerStrWeakRef = makeWeakRef(innerStr, arena);
        final innerList = [innerStr].toJList();
        innerStr.release();
        final innerListWeakRef = makeWeakRef(innerList, arena);

        final elemStr = 'outer-set-element'.toJString();
        final elemStrWeakRef = makeWeakRef(elemStr, arena);
        final set = <JObject?>{elemStr, innerList}.toJSet();
        elemStr.release();
        innerList.release();

        expect(
          set.toDartSet(),
          {
            'outer-set-element',
            ['nested-set-element']
          },
        );

        set.clear();
        set.release();

        expect(
          isJavaObjectCollected(elemStrWeakRef),
          isTrue,
          reason: 'JSet.toDartSet leaked an element global reference',
        );
        expect(
          isJavaObjectCollected(innerListWeakRef),
          isTrue,
          reason: 'JSet.toDartSet leaked a nested collection global reference',
        );
        expect(
          isJavaObjectCollected(innerStrWeakRef),
          isTrue,
          reason: 'JSet.toDartSet leaked a nested element global reference',
        );
      });
    });

    test('JMap.toDartMap does not leak keySet or iterator', () {
      using((arena) {
        final map = <JObject?, JObject?>{}.toJMap();
        // HashMap$KeySet and HashMap$KeyIterator both hold an implicit
        // reference to their enclosing HashMap, so leaking either keeps `map`
        // alive after `map.release()`.
        final mapWeakRef = makeWeakRef(map, arena);

        expect(map.toDartMap(), isEmpty);
        map.release();

        expect(
          isJavaObjectCollected(mapWeakRef),
          isTrue,
          reason: 'JMap.toDartMap leaked its keySet or JIterator global ref',
        );
      });
    });

    test('JMap.toDartMap does not leak keys, values, or nested collections',
        () {
      using((arena) {
        final nestedKey = 'nested-map-key'.toJString();
        final nestedKeyWeakRef = makeWeakRef(nestedKey, arena);
        final nestedVal = 'nested-map-val'.toJString();
        final nestedValWeakRef = makeWeakRef(nestedVal, arena);
        final nestedMap = <JObject?, JObject?>{nestedKey: nestedVal}.toJMap();
        nestedKey.release();
        nestedVal.release();
        final nestedMapWeakRef = makeWeakRef(nestedMap, arena);

        final key = 'outer-map-key'.toJString();
        final keyWeakRef = makeWeakRef(key, arena);
        final map = <JObject?, JObject?>{key: nestedMap}.toJMap();
        key.release();
        nestedMap.release();

        expect(
          map.toDartMap(),
          {
            'outer-map-key': {'nested-map-key': 'nested-map-val'},
          },
        );

        map.clear();
        map.release();

        expect(
          isJavaObjectCollected(keyWeakRef),
          isTrue,
          reason: 'JMap.toDartMap leaked a key global reference',
        );
        expect(
          isJavaObjectCollected(nestedMapWeakRef),
          isTrue,
          reason: 'JMap.toDartMap leaked a nested JMap global reference',
        );
        expect(
          isJavaObjectCollected(nestedKeyWeakRef),
          isTrue,
          reason: 'JMap.toDartMap leaked a nested key global reference',
        );
        expect(
          isJavaObjectCollected(nestedValWeakRef),
          isTrue,
          reason: 'JMap.toDartMap leaked a nested value global reference',
        );
      });
    });

    test('toDartObject does not leak intermediate or temporary references', () {
      using((arena) {
        final leafStr = 'deep-leaf'.toJString();
        final leafStrWeakRef = makeWeakRef(leafStr, arena);
        final innerSet = <JObject?>{leafStr}.toJSet();
        leafStr.release();
        final innerSetWeakRef = makeWeakRef(innerSet, arena);

        final mapKey = 'set-key'.toJString();
        final mapKeyWeakRef = makeWeakRef(mapKey, arena);
        final innerMap = <JObject?, JObject?>{mapKey: innerSet}.toJMap();
        mapKey.release();
        innerSet.release();
        final innerMapWeakRef = makeWeakRef(innerMap, arena);

        final rootList = <JObject?>[innerMap].toJList();
        innerMap.release();
        final rootListWeakRef = makeWeakRef(rootList, arena);

        expect(
          toDartObject(rootList),
          [
            {
              'set-key': {'deep-leaf'},
            },
          ],
        );

        // Release the top-level object (caller-owned without releaseOriginal).
        rootList.clear();
        rootList.release();

        expect(
          isJavaObjectCollected(rootListWeakRef),
          isTrue,
          reason: 'toDartObject leaked root list iterator global reference',
        );
        expect(
          isJavaObjectCollected(innerMapWeakRef),
          isTrue,
          reason: 'toDartObject leaked nested JMap/keySet/iterator global ref',
        );
        expect(
          isJavaObjectCollected(mapKeyWeakRef),
          isTrue,
          reason: 'toDartObject leaked nested map key global reference',
        );
        expect(
          isJavaObjectCollected(innerSetWeakRef),
          isTrue,
          reason: 'toDartObject leaked nested JSet global reference',
        );
        expect(
          isJavaObjectCollected(leafStrWeakRef),
          isTrue,
          reason: 'toDartObject leaked nested leaf element global reference',
        );
      });
    });
  });
}
