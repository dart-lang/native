// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
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
  A.fromRef(super.reference) : super.fromRef();
  @override
  JObjType<JObject> get $type => $AType();
}

class $AType extends JObjType<A> {
  @override
  A fromRef(Pointer<Void> ref) {
    return A.fromRef(ref);
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
  B.fromRef(super.reference) : super.fromRef();
  @override
  JObjType<JObject> get $type => $BType();
}

class $BType extends JObjType<B> {
  @override
  B fromRef(Pointer<Void> ref) {
    return B.fromRef(ref);
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
  C.fromRef(super.reference) : super.fromRef();

  @override
  JObjType<JObject> get $type => $CType();
}

class $CType extends JObjType<C> {
  @override
  C fromRef(Pointer<Void> ref) {
    return C.fromRef(ref);
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
  D.fromRef(super.reference) : super.fromRef();

  @override
  JObjType<JObject> get $type => $DType();
}

class $DType extends JObjType<D> {
  @override
  D fromRef(Pointer<Void> ref) {
    return D.fromRef(ref);
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
  E.fromRef(super.reference) : super.fromRef();

  @override
  JObjType<JObject> get $type => $EType();
}

class $EType extends JObjType<E> {
  @override
  E fromRef(Pointer<Void> ref) {
    return E.fromRef(ref);
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
  F.fromRef(super.reference) : super.fromRef();

  @override
  JObjType<JObject> get $type => $FType();
}

class $FType extends JObjType<F> {
  @override
  F fromRef(Pointer<Void> ref) {
    return F.fromRef(ref);
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
    Jni.spawnIfNotExists(dylibDir: "build/jni_libs", jvmOptions: ["-Xmx128m"]);
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
