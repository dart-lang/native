// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of 'types.dart';

/// A high level wrapper over a JNI class reference.
///
/// JClasses are objects of type `java.lang.Class`.
class JClass extends JObject {
  /// Constructs a [JClass] with the underlying [reference].
  JClass.fromReference(JReference reference) : super.fromReference(reference);

  /// Constructs a [JClass] associated with the class or interface with
  /// the given string name.
  JClass.forName(String name)
      : super.fromReference(using((arena) {
          final cls = Jni.accessors.getClass(name.toNativeChars(arena));
          return JGlobalReference(cls.checkedClassRef);
        }));

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
      : pointer = using((arena) => Jni.accessors
            .getFieldID(
              jClass.reference.pointer,
              name.toNativeChars(arena),
              signature.toNativeChars(arena),
            )
            .fieldID);

  DartT get<JavaT, DartT>(JObject object, JAccessible<JavaT, DartT> type) {
    return type._instanceGet(object.reference.pointer, this as JFieldIDPtr);
  }

  void set<JavaT, DartT>(
      JObject object, JAccessible<JavaT, DartT> type, DartT value) {
    type._instanceSet(object.reference.pointer, this as JFieldIDPtr, value);
  }
}

/// A thin wrapper over a [JFieldIDPtr] of an static field.
extension type JStaticFieldId._fromPointer(JFieldIDPtr pointer) {
  JStaticFieldId._(JClass jClass, String name, String signature)
      : pointer = using((arena) => Jni.accessors
            .getStaticFieldID(
              jClass.reference.pointer,
              name.toNativeChars(arena),
              signature.toNativeChars(arena),
            )
            .fieldID);

  DartT get<JavaT, DartT>(JClass jClass, JAccessible<JavaT, DartT> type) {
    return type._staticGet(jClass.reference.pointer, this as JFieldIDPtr);
  }

  void set<JavaT, DartT>(
      JObject object, JAccessible<JavaT, DartT> type, DartT value) {
    type._staticSet(object.reference.pointer, this as JFieldIDPtr, value);
  }
}

/// A thin wrapper over a [JMethodIDPtr] of an instance method.
extension type JInstanceMethodId._fromPointer(JMethodIDPtr pointer) {
  JInstanceMethodId._(
    JClass jClass,
    String name,
    String signature,
  ) : pointer = using((arena) => Jni.accessors
            .getMethodID(
              jClass.reference.pointer,
              name.toNativeChars(arena),
              signature.toNativeChars(arena),
            )
            .methodID);

  /// Calls the instance method on [object] with the given arguments.
  DartT call<JavaT, DartT>(
    JObject object,
    JCallable<JavaT, DartT> returnType,
    List<dynamic> args,
  ) {
    return using((arena) => returnType._instanceCall(object.reference.pointer,
        this as JMethodIDPtr, toJValues(args, allocator: arena)));
  }
}

/// A thin wrapper over a [JMethodIDPtr] of a static mehtod.
extension type JStaticMethodId._fromPointer(JMethodIDPtr pointer) {
  JStaticMethodId._(
    JClass jClass,
    String name,
    String signature,
  ) : pointer = using((arena) => Jni.accessors
            .getStaticMethodID(
              jClass.reference.pointer,
              name.toNativeChars(arena),
              signature.toNativeChars(arena),
            )
            .methodID);

  /// Calls the static method on [jClass] with the given arguments.
  DartT call<JavaT, DartT>(
    JClass jClass,
    JCallable<JavaT, DartT> returnType,
    List<dynamic> args,
  ) {
    return using((arena) => returnType._staticCall(jClass.reference.pointer,
        this as JMethodIDPtr, toJValues(args, allocator: arena)));
  }
}

/// A thin wrapper over a [JMethodIDPtr] of a constructor.
extension type JConstructorId._fromPointer(JMethodIDPtr pointer) {
  JConstructorId._(
    JClass jClass,
    String signature,
  ) : pointer = using((arena) => Jni.accessors
            .getMethodID(
              jClass.reference.pointer,
              '<init>'.toNativeChars(arena),
              signature.toNativeChars(arena),
            )
            .methodID);

  /// Constructs an instance of [jClass] with the given arguments.
  DartT call<JavaT, DartT>(JClass jClass,
      JConstructable<JavaT, DartT> returnType, List<dynamic> args) {
    return using((arena) => returnType._newObject(jClass.reference.pointer,
        this as JMethodIDPtr, toJValues(args, allocator: arena)));
  }
}
