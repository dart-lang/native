// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:jni/_internal.dart';
import 'package:jni/jni.dart';
import 'package:jni/src/types.dart';
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
  JObjType<JObject> get $type => $AType();
}

final class $ANullableType extends JObjType<A?> {
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
  JObjType<JObject?> get superType => JObject.nullableType;

  @internal
  @override
  JObjType<A?> get nullableType => this;

  @override
  int get hashCode => ($ANullableType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $ANullableType && other is $ANullableType;
  }
}

final class $AType extends JObjType<A> {
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
  JObjType<JObject> get superType => JObject.type;

  @internal
  @override
  JObjType<A?> get nullableType => $ANullableType();

  @override
  int get hashCode => ($AType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $AType && other is $AType;
  }
}

class B extends JObject {
  B.fromReference(super.reference) : super.fromReference();
  @override
  JObjType<JObject> get $type => $BType();
}

final class $BNullableType extends JObjType<B?> {
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
  JObjType<JObject?> get superType => JObject.nullableType;

  @internal
  @override
  JObjType<B?> get nullableType => this;

  @override
  int get hashCode => ($BNullableType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $BNullableType && other is $BNullableType;
  }
}

final class $BType extends JObjType<B> {
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
  JObjType<JObject> get superType => JObject.type;

  @internal
  @override
  JObjType<B?> get nullableType => $BNullableType();

  @override
  int get hashCode => ($BType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $BType && other is $BType;
  }
}

class C extends A {
  C.fromReference(super.reference) : super.fromReference();

  @override
  JObjType<JObject> get $type => $CType();
}

final class $CNullableType extends JObjType<C?> {
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
  JObjType<JObject?> get superType => $ANullableType();

  @internal
  @override
  JObjType<C?> get nullableType => this;

  @override
  int get hashCode => ($CNullableType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $CNullableType && other is $CNullableType;
  }
}

final class $CType extends JObjType<C> {
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
  JObjType<JObject> get superType => $AType();

  @internal
  @override
  JObjType<C?> get nullableType => $CNullableType();

  @override
  int get hashCode => ($CType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $CType && other is $CType;
  }
}

class D extends A {
  D.fromReference(super.reference) : super.fromReference();

  @override
  JObjType<JObject> get $type => $DType();
}

final class $DNullableType extends JObjType<D?> {
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
  JObjType<JObject?> get superType => $ANullableType();

  @internal
  @override
  JObjType<D?> get nullableType => this;

  @override
  int get hashCode => ($DNullableType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $DNullableType && other is $DNullableType;
  }
}

final class $DType extends JObjType<D> {
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
  JObjType<JObject> get superType => $AType();

  @internal
  @override
  JObjType<D?> get nullableType => $DNullableType();

  @override
  int get hashCode => ($DType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $DType && other is $DType;
  }
}

class E extends B {
  E.fromReference(super.reference) : super.fromReference();

  @override
  JObjType<JObject> get $type => $EType();
}

final class $ENullableType extends JObjType<E?> {
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
  JObjType<JObject?> get superType => $BNullableType();

  @internal
  @override
  JObjType<E?> get nullableType => this;

  @override
  int get hashCode => ($ENullableType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $ENullableType && other is $ENullableType;
  }
}

final class $EType extends JObjType<E> {
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
  JObjType<JObject> get superType => $BType();

  @internal
  @override
  JObjType<E?> get nullableType => $ENullableType();

  @override
  int get hashCode => ($EType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $EType && other is $EType;
  }
}

class F extends C {
  F.fromReference(super.reference) : super.fromReference();

  @override
  JObjType<JObject> get $type => $FType();
}

final class $FNullableType extends JObjType<F?> {
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
  JObjType<JObject?> get superType => $CNullableType();

  @internal
  @override
  JObjType<F?> get nullableType => this;

  @override
  int get hashCode => ($FNullableType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $FNullableType && other is $FNullableType;
  }
}

final class $FType extends JObjType<F> {
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
  JObjType<JObject> get superType => $CType();

  @internal
  @override
  JObjType<F?> get nullableType => $FNullableType();

  @override
  int get hashCode => ($FType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $FType && other is $FType;
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
    expect(lowestCommonSuperType([JString.type, JArray.type(jlong.type)]),
        JObject.type);
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
        lowestCommonSuperType([
          JArray.type(jint.type),
          JArray.type(jint.type),
        ]),
        JArray.type(jint.type),
      );
      expect(
        lowestCommonSuperType([
          JArray.type(JObject.type),
          JArray.type(JObject.type),
        ]),
        JArray.type(JObject.type),
      );
      expect(
        lowestCommonSuperType([
          JArray.type(JObject.type),
          JArray.type(jint.type),
        ]),
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
        lowestCommonSuperType([
          JByteBuffer.type,
          JBuffer.type,
        ]),
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
    expect(lowestCommonSuperType([$AType(), $BType()]), JObject.type);
    expect(lowestCommonSuperType([$CType(), $BType()]), JObject.type);
    expect(lowestCommonSuperType([$FType(), $BType()]), JObject.type);
    expect(lowestCommonSuperType([$EType(), $CType(), $FType()]), JObject.type);

    expect(lowestCommonSuperType([$CType(), $DType()]), $AType());
    expect(lowestCommonSuperType([$FType(), $DType()]), $AType());
    expect(lowestCommonSuperType([$FType(), $CType(), $DType()]), $AType());

    expect(lowestCommonSuperType([$EType(), $BType()]), $BType());
    expect(lowestCommonSuperType([$BType(), $BType()]), $BType());
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
    expect(lowestCommonSuperType([$AType(), $BNullableType()]),
        JObject.nullableType);
    expect(lowestCommonSuperType([$CNullableType(), $BType()]),
        JObject.nullableType);
    expect(lowestCommonSuperType([$FNullableType(), $BNullableType()]),
        JObject.nullableType);
    expect(lowestCommonSuperType([$ENullableType(), $CType(), $FType()]),
        JObject.nullableType);

    expect(
        lowestCommonSuperType([$CType(), $DNullableType()]), $ANullableType());
    expect(
        lowestCommonSuperType([$FNullableType(), $DType()]), $ANullableType());
    expect(lowestCommonSuperType([$FType(), $CNullableType(), $DType()]),
        $ANullableType());

    expect(
        lowestCommonSuperType([$ENullableType(), $BType()]), $BNullableType());
    expect(
        lowestCommonSuperType([$BNullableType(), $BType()]), $BNullableType());
    expect(lowestCommonSuperType([$BNullableType(), $BNullableType()]),
        $BNullableType());
  });
}
