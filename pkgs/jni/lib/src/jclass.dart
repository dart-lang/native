// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of 'types.dart';

/// A high level wrapper over a JNI class reference.
///
/// JClasses are objects of type `java.lang.Class`.
class JClass extends JObject {
  /// Constructs a [JClass] with the underlying [reference].
  JClass.fromReference(super.reference) : super.fromReference();

  /// Constructs a [JClass] associated with the class or interface with
  /// the given string name.
  JClass.forName(String name)
      : super.fromReference(JGlobalReference(Jni.findClass(name)));

  JConstructorId constructorId(String signature) {
    return JConstructorId._(this, signature);
  }

  JInstanceMethodId instanceMethodId(String name, String signature) {
    return JInstanceMethodId._(this, name, signature);
  }

  JStaticMethodId staticMethodId(String name, String signature) {
    return JStaticMethodId._(this, name, signature);
  }

  JInstanceFieldId instanceFieldId(String name, String signature) {
    return JInstanceFieldId._(this, name, signature);
  }

  JStaticFieldId staticFieldId(String name, String signature) {
    return JStaticFieldId._(this, name, signature);
  }
}

/// A thin wrapper over a [JFieldIDPtr] of an instance field.
extension type JInstanceFieldId._fromPointer(JFieldIDPtr pointer) {
  JInstanceFieldId._(JClass jClass, String name, String signature)
      : pointer = using((arena) {
          final jClassRef = jClass.reference;
          return Jni.env.GetFieldID(
            jClassRef.pointer,
            name.toNativeChars(arena),
            signature.toNativeChars(arena),
          );
        });

  DartT get<JavaT, DartT>(JObject object, JAccessible<JavaT, DartT> type) {
    final objectRef = object.reference;
    return type._instanceGet(objectRef.pointer, pointer);
  }

  void set<JavaT, DartT>(
      JObject object, JAccessible<JavaT, DartT> type, DartT value) {
    final objectRef = object.reference;
    type._instanceSet(objectRef.pointer, pointer, value);
  }
}

/// A thin wrapper over a [JFieldIDPtr] of an static field.
extension type JStaticFieldId._fromPointer(JFieldIDPtr pointer) {
  JStaticFieldId._(JClass jClass, String name, String signature)
      : pointer = using((arena) {
          final jClassRef = jClass.reference;
          return Jni.env.GetStaticFieldID(
            jClassRef.pointer,
            name.toNativeChars(arena),
            signature.toNativeChars(arena),
          );
        });

  DartT get<JavaT, DartT>(JClass jClass, JAccessible<JavaT, DartT> type) {
    final jClassRef = jClass.reference;
    return type._staticGet(jClassRef.pointer, pointer);
  }

  void set<JavaT, DartT>(
      JObject object, JAccessible<JavaT, DartT> type, DartT value) {
    final objectRef = object.reference;
    type._staticSet(objectRef.pointer, pointer, value);
  }
}

/// A thin wrapper over a [JMethodIDPtr] of an instance method.
class JInstanceMethodId {
  JMethodIDPtr pointer;

  JInstanceMethodId._(
    JClass jClass,
    String name,
    String signature,
  ) : pointer = using((arena) {
          final jClassRef = jClass.reference;
          return Jni.env.GetMethodID(
            jClassRef.pointer,
            name.toNativeChars(arena),
            signature.toNativeChars(arena),
          );
        });

  /// Calls the instance method on [object] with the given arguments.
  DartT call<JavaT, DartT>(
    JObject object,
    JCallable<JavaT, DartT> returnType,
    List<dynamic> args,
  ) {
    return using((arena) {
      final objectRef = object.reference;
      return returnType._instanceCall(objectRef.pointer, pointer,
          toJValues(args, allocator: arena));
    });
  }
}

/// A thin wrapper over a [JMethodIDPtr] of a static mehtod.
extension type JStaticMethodId._fromPointer(JMethodIDPtr pointer) {
  JStaticMethodId._(
    JClass jClass,
    String name,
    String signature,
  ) : pointer = using((arena) {
          final jClassRef = jClass.reference;
          return Jni.env.GetStaticMethodID(
            jClassRef.pointer,
            name.toNativeChars(arena),
            signature.toNativeChars(arena),
          );
        });

  /// Calls the static method on [jClass] with the given arguments.
  DartT call<JavaT, DartT>(
    JClass jClass,
    JCallable<JavaT, DartT> returnType,
    List<dynamic> args,
  ) {
    final jClassRef = jClass.reference;
    return using((arena) => returnType._staticCall(jClassRef.pointer,
        pointer, toJValues(args, allocator: arena)));
  }
}

/// A thin wrapper over a [JMethodIDPtr] of a constructor.
extension type JConstructorId._fromPointer(JMethodIDPtr pointer) {
  JConstructorId._(
    JClass jClass,
    String signature,
  ) : pointer = using((arena) {
          final jClassRef = jClass.reference;
          return Jni.env.GetMethodID(
            jClassRef.pointer,
            '<init>'.toNativeChars(arena),
            signature.toNativeChars(arena),
          );
        });

  /// Constructs an instance of [jClass] with the given arguments.
  DartT call<DartT extends JObject>(JClass jClass, List<dynamic> args) {
    return using((arena) {
      final jClassRef = jClass.reference;
      return JObject.fromReference(
        JGlobalReference(Jni.env.NewObjectA(
          jClassRef.pointer,
          this as JMethodIDPtr,
          toJValues(args, allocator: arena),
        )),
      ) as DartT;
    });
  }
}
