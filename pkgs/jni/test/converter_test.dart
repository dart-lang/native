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

      final javaArray = dartList.toJArrayDeep();

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

      final javaArray = dartList.toJArrayDeep();

      expect(
        toDartObject(javaArray),
        dartList,
      );
    });
  });
}
