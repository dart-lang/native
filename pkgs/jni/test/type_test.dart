// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:jni/_internal.dart';
import 'package:jni/jni.dart';
import 'package:test/test.dart';

import 'test_util/test_util.dart';

// Mocking this type tree:
//   JObject
//      |  \
//      A   B
//     / \   \
//    C   D   E
//   /
//  F

class A extends JObject {
  A.fromReference(super.reference) : super.fromReference();
  @override
  JType<JObject> get $type => $A$Type$();
}

final class $A$NullableType$ extends JType<A?> {
  @internal
  @override
  A? fromReference(JReference reference) {
    return reference.isNull ? null : A.fromReference(reference);
  }

  @internal
  @override
  String get signature => 'A';

  @internal
  @override
  int get superCount => superType.superCount + 1;

  @internal
  @override
  JType<JObject?> get superType => JObject.nullableType;

  @internal
  @override
  JType<A?> get nullableType => this;

  @override
  int get hashCode => ($A$NullableType$).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $A$NullableType$ && other is $A$NullableType$;
  }
}

final class $A$Type$ extends JType<A> {
  @internal
  @override
  A fromReference(JReference reference) {
    return A.fromReference(reference);
  }

  @internal
  @override
  String get signature => 'A';

  @internal
  @override
  int get superCount => superType.superCount + 1;

  @internal
  @override
  JType<JObject> get superType => JObject.type;

  @internal
  @override
  JType<A?> get nullableType => $A$NullableType$();

  @override
  int get hashCode => ($A$Type$).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $A$Type$ && other is $A$Type$;
  }
}

class B extends JObject {
  B.fromReference(super.reference) : super.fromReference();
  @override
  JType<JObject> get $type => $B$Type$();
}

final class $B$NullableType$ extends JType<B?> {
  @internal
  @override
  B? fromReference(JReference reference) {
    return reference.isNull ? null : B.fromReference(reference);
  }

  @internal
  @override
  String get signature => 'B';

  @internal
  @override
  int get superCount => superType.superCount + 1;

  @internal
  @override
  JType<JObject?> get superType => JObject.nullableType;

  @internal
  @override
  JType<B?> get nullableType => this;

  @override
  int get hashCode => ($B$NullableType$).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $B$NullableType$ && other is $B$NullableType$;
  }
}

final class $B$Type$ extends JType<B> {
  @internal
  @override
  B fromReference(JReference reference) {
    return B.fromReference(reference);
  }

  @internal
  @override
  String get signature => 'B';

  @internal
  @override
  int get superCount => superType.superCount + 1;

  @internal
  @override
  JType<JObject> get superType => JObject.type;

  @internal
  @override
  JType<B?> get nullableType => $B$NullableType$();

  @override
  int get hashCode => ($B$Type$).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $B$Type$ && other is $B$Type$;
  }
}

class C extends A {
  C.fromReference(super.reference) : super.fromReference();

  @override
  JType<JObject> get $type => $C$Type$();
}

final class $C$NullableType$ extends JType<C?> {
  @internal
  @override
  C? fromReference(JReference reference) {
    return reference.isNull ? null : C.fromReference(reference);
  }

  @internal
  @override
  String get signature => 'C';

  @internal
  @override
  int get superCount => superType.superCount + 1;

  @internal
  @override
  JType<JObject?> get superType => $A$NullableType$();

  @internal
  @override
  JType<C?> get nullableType => this;

  @override
  int get hashCode => ($C$NullableType$).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $C$NullableType$ && other is $C$NullableType$;
  }
}

final class $C$Type$ extends JType<C> {
  @internal
  @override
  C fromReference(JReference reference) {
    return C.fromReference(reference);
  }

  @internal
  @override
  String get signature => 'C';

  @internal
  @override
  int get superCount => superType.superCount + 1;

  @internal
  @override
  JType<JObject> get superType => $A$Type$();

  @internal
  @override
  JType<C?> get nullableType => $C$NullableType$();

  @override
  int get hashCode => ($C$Type$).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $C$Type$ && other is $C$Type$;
  }
}

class D extends A {
  D.fromReference(super.reference) : super.fromReference();

  @override
  JType<JObject> get $type => $D$Type$();
}

final class $D$NullableType$ extends JType<D?> {
  @internal
  @override
  D? fromReference(JReference reference) {
    return reference.isNull ? null : D.fromReference(reference);
  }

  @internal
  @override
  String get signature => 'D';

  @internal
  @override
  int get superCount => superType.superCount + 1;

  @internal
  @override
  JType<JObject?> get superType => $A$NullableType$();

  @internal
  @override
  JType<D?> get nullableType => this;

  @override
  int get hashCode => ($D$NullableType$).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $D$NullableType$ && other is $D$NullableType$;
  }
}

final class $D$Type$ extends JType<D> {
  @internal
  @override
  D fromReference(JReference reference) {
    return D.fromReference(reference);
  }

  @internal
  @override
  String get signature => 'D';

  @internal
  @override
  int get superCount => superType.superCount + 1;

  @internal
  @override
  JType<JObject> get superType => $A$Type$();

  @internal
  @override
  JType<D?> get nullableType => $D$NullableType$();

  @override
  int get hashCode => ($D$Type$).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $D$Type$ && other is $D$Type$;
  }
}

class E extends B {
  E.fromReference(super.reference) : super.fromReference();

  @override
  JType<JObject> get $type => $E$Type$();
}

final class $E$NullableType$ extends JType<E?> {
  @internal
  @override
  E? fromReference(JReference reference) {
    return reference.isNull ? null : E.fromReference(reference);
  }

  @internal
  @override
  String get signature => 'E';

  @internal
  @override
  int get superCount => superType.superCount + 1;

  @internal
  @override
  JType<JObject?> get superType => $B$NullableType$();

  @internal
  @override
  JType<E?> get nullableType => this;

  @override
  int get hashCode => ($E$NullableType$).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $E$NullableType$ && other is $E$NullableType$;
  }
}

final class $E$Type$ extends JType<E> {
  @internal
  @override
  E fromReference(JReference reference) {
    return E.fromReference(reference);
  }

  @internal
  @override
  String get signature => 'E';

  @internal
  @override
  int get superCount => superType.superCount + 1;

  @internal
  @override
  JType<JObject> get superType => $B$Type$();

  @internal
  @override
  JType<E?> get nullableType => $E$NullableType$();

  @override
  int get hashCode => ($E$Type$).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $E$Type$ && other is $E$Type$;
  }
}

class F extends C {
  F.fromReference(super.reference) : super.fromReference();

  @override
  JType<JObject> get $type => $F$Type$();
}

final class $F$NullableType$ extends JType<F?> {
  @internal
  @override
  F? fromReference(JReference reference) {
    return reference.isNull ? null : F.fromReference(reference);
  }

  @internal
  @override
  String get signature => 'F';

  @internal
  @override
  int get superCount => superType.superCount + 1;

  @internal
  @override
  JType<JObject?> get superType => $C$NullableType$();

  @internal
  @override
  JType<F?> get nullableType => this;

  @override
  int get hashCode => ($F$NullableType$).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $F$NullableType$ && other is $F$NullableType$;
  }
}

final class $F$Type$ extends JType<F> {
  @internal
  @override
  F fromReference(JReference reference) {
    return F.fromReference(reference);
  }

  @internal
  @override
  String get signature => 'F';

  @internal
  @override
  int get superCount => superType.superCount + 1;

  @internal
  @override
  JType<JObject> get superType => $C$Type$();

  @internal
  @override
  JType<F?> get nullableType => $F$NullableType$();

  @override
  int get hashCode => ($F$Type$).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $F$Type$ && other is $F$Type$;
  }
}

void main() {
  run(testRunner: test);
}

void run({required TestRunnerCallback testRunner}) {
  testRunner('lowestCommonSuperType', () {
    expect(lowestCommonSuperType([JObject.type]), JObject.type);
    expect(lowestCommonSuperType([JString.type]), JString.type);
    expect(lowestCommonSuperType([JObject.type, JObject.type]), JObject.type);
    expect(lowestCommonSuperType([JString.type, JString.type]), JString.type);
    expect(
      lowestCommonSuperType([JString.type, JArray.type(JString.type)]),
      JObject.type,
    );
  });

  testRunner('Boxed types', () {
    expect(
      lowestCommonSuperType([
        JByte.type,
        JInteger.type,
        JLong.type,
        JShort.type,
        JDouble.type,
        JFloat.type,
      ]),
      JNumber.type,
    );
    expect(lowestCommonSuperType([JByte.type, JBoolean.type]), JObject.type);
  });

  testRunner('Nullable boxed types', () {
    expect(
      lowestCommonSuperType([
        JByte.type,
        JInteger.type,
        JLong.type,
        JShort.nullableType, // A single nullable type,
        JDouble.type,
        JFloat.type,
      ]),
      JNumber.nullableType, // Makes the common super class nullable.
    );
    expect(lowestCommonSuperType([JByte.type, JBoolean.type]), JObject.type);
  });

  testRunner('array types', () {
    using((arena) {
      expect(
        lowestCommonSuperType([JIntArray.type, JIntArray.type]),
        JIntArray.type,
      );
      expect(
        lowestCommonSuperType([
          JArray.type(JObject.type),
          JArray.type(JObject.type),
        ]),
        JArray.type(JObject.type),
      );
      expect(
        lowestCommonSuperType([JArray.type(JObject.type), JIntArray.type]),
        JObject.type,
      );
    });
  });

  testRunner('util types', () {
    using((arena) {
      expect(
        lowestCommonSuperType([
          JList.type(JObject.type),
          JList.type(JObject.type),
        ]),
        JList.type(JObject.type),
      );
      expect(
        lowestCommonSuperType([
          JList.type(JObject.type),
          JList.type(JString.type),
        ]),
        JObject.type,
      );
      expect(
        lowestCommonSuperType([
          JList.type(JObject.type),
          JMap.type(JObject.type, JObject.type),
        ]),
        JObject.type,
      );
      expect(
        lowestCommonSuperType([
          JSet.type(JObject.type),
          JIterator.type(JObject.type),
        ]),
        JObject.type,
      );
      expect(
        lowestCommonSuperType([JByteBuffer.type, JBuffer.type]),
        JBuffer.type,
      );
    });
  });

  testRunner('Mocked type tree', () {
    // As a reminder, this is how the type tree looks like:
    //   JObject
    //      |  \
    //      A   B
    //     / \   \
    //    C   D   E
    //   /
    //  F
    expect(lowestCommonSuperType([$A$Type$(), $B$Type$()]), JObject.type);
    expect(lowestCommonSuperType([$C$Type$(), $B$Type$()]), JObject.type);
    expect(lowestCommonSuperType([$F$Type$(), $B$Type$()]), JObject.type);
    expect(
      lowestCommonSuperType([$E$Type$(), $C$Type$(), $F$Type$()]),
      JObject.type,
    );

    expect(lowestCommonSuperType([$C$Type$(), $D$Type$()]), $A$Type$());
    expect(lowestCommonSuperType([$F$Type$(), $D$Type$()]), $A$Type$());
    expect(
      lowestCommonSuperType([$F$Type$(), $C$Type$(), $D$Type$()]),
      $A$Type$(),
    );

    expect(lowestCommonSuperType([$E$Type$(), $B$Type$()]), $B$Type$());
    expect(lowestCommonSuperType([$B$Type$(), $B$Type$()]), $B$Type$());
  });

  testRunner('Mocked nullable type tree', () {
    // As a reminder, this is how the type tree looks like:
    //   JObject
    //      |  \
    //      A   B
    //     / \   \
    //    C   D   E
    //   /
    //  F
    expect(
      lowestCommonSuperType([$A$Type$(), $B$NullableType$()]),
      JObject.nullableType,
    );
    expect(
      lowestCommonSuperType([$C$NullableType$(), $B$Type$()]),
      JObject.nullableType,
    );
    expect(
      lowestCommonSuperType([$F$NullableType$(), $B$NullableType$()]),
      JObject.nullableType,
    );
    expect(
      lowestCommonSuperType([$E$NullableType$(), $C$Type$(), $F$Type$()]),
      JObject.nullableType,
    );

    expect(
      lowestCommonSuperType([$C$Type$(), $D$NullableType$()]),
      $A$NullableType$(),
    );
    expect(
      lowestCommonSuperType([$F$NullableType$(), $D$Type$()]),
      $A$NullableType$(),
    );
    expect(
      lowestCommonSuperType([$F$Type$(), $C$NullableType$(), $D$Type$()]),
      $A$NullableType$(),
    );

    expect(
      lowestCommonSuperType([$E$NullableType$(), $B$Type$()]),
      $B$NullableType$(),
    );
    expect(
      lowestCommonSuperType([$B$NullableType$(), $B$Type$()]),
      $B$NullableType$(),
    );
    expect(
      lowestCommonSuperType([$B$NullableType$(), $B$NullableType$()]),
      $B$NullableType$(),
    );
  });
}
