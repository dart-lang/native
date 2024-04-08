// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

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
  A.fromReference(JReference reference) : super.fromReference(reference);
  @override
  JObjType<JObject> get $type => $AType();
}

final class $AType extends JObjType<A> {
  @override
  A fromReference(JReference reference) {
    return A.fromReference(reference);
  }

  @override
  String get signature => 'A';

  @override
  int get superCount => superType.superCount + 1;

  @override
  JObjType<JObject> get superType => JObject.type;

  @override
  int get hashCode => ($AType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $AType && other is $AType;
  }
}

class B extends JObject {
  B.fromReference(JReference reference) : super.fromReference(reference);
  @override
  JObjType<JObject> get $type => $BType();
}

final class $BType extends JObjType<B> {
  @override
  B fromReference(JReference reference) {
    return B.fromReference(reference);
  }

  @override
  String get signature => 'B';

  @override
  int get superCount => superType.superCount + 1;

  @override
  JObjType<JObject> get superType => JObject.type;

  @override
  int get hashCode => ($BType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $BType && other is $BType;
  }
}

class C extends A {
  C.fromReference(JReference reference) : super.fromReference(reference);

  @override
  JObjType<JObject> get $type => $CType();
}

final class $CType extends JObjType<C> {
  @override
  C fromReference(JReference reference) {
    return C.fromReference(reference);
  }

  @override
  String get signature => 'C';

  @override
  int get superCount => superType.superCount + 1;

  @override
  JObjType<JObject> get superType => $AType();

  @override
  int get hashCode => ($CType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $CType && other is $CType;
  }
}

class D extends A {
  D.fromReference(JReference reference) : super.fromReference(reference);

  @override
  JObjType<JObject> get $type => $DType();
}

final class $DType extends JObjType<D> {
  @override
  D fromReference(JReference reference) {
    return D.fromReference(reference);
  }

  @override
  String get signature => 'D';

  @override
  int get superCount => superType.superCount + 1;

  @override
  JObjType<JObject> get superType => $AType();

  @override
  int get hashCode => ($DType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $DType && other is $DType;
  }
}

class E extends B {
  E.fromReference(JReference reference) : super.fromReference(reference);

  @override
  JObjType<JObject> get $type => $EType();
}

final class $EType extends JObjType<E> {
  @override
  E fromReference(JReference reference) {
    return E.fromReference(reference);
  }

  @override
  String get signature => 'E';

  @override
  int get superCount => superType.superCount + 1;

  @override
  JObjType<JObject> get superType => $BType();

  @override
  int get hashCode => ($EType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $EType && other is $EType;
  }
}

class F extends C {
  F.fromReference(JReference reference) : super.fromReference(reference);

  @override
  JObjType<JObject> get $type => $FType();
}

final class $FType extends JObjType<F> {
  @override
  F fromReference(JReference reference) {
    return F.fromReference(reference);
  }

  @override
  String get signature => 'F';

  @override
  int get superCount => superType.superCount + 1;

  @override
  JObjType<JObject> get superType => $CType();

  @override
  int get hashCode => ($FType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $FType && other is $FType;
  }
}

void main() {
  if (!Platform.isAndroid) {
    checkDylibIsUpToDate();
    spawnJvm();
  }
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
    expect(lowestCommonSuperType([$AType(), $BType()]), const JObjectType());
    expect(lowestCommonSuperType([$CType(), $BType()]), const JObjectType());
    expect(lowestCommonSuperType([$FType(), $BType()]), const JObjectType());
    expect(lowestCommonSuperType([$EType(), $CType(), $FType()]),
        const JObjectType());

    expect(lowestCommonSuperType([$CType(), $DType()]), $AType());
    expect(lowestCommonSuperType([$FType(), $DType()]), $AType());
    expect(lowestCommonSuperType([$FType(), $CType(), $DType()]), $AType());

    expect(lowestCommonSuperType([$EType(), $BType()]), $BType());
    expect(lowestCommonSuperType([$BType(), $BType()]), $BType());
  });
}
