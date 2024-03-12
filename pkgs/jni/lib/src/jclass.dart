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

  JConstructor constructor(String signature) {
    return JConstructor._(this, signature);
  }

  JInstanceMethod instanceMethod(String name, String signature) {
    return JInstanceMethod._(this, name, signature);
  }

  JStaticMethod staticMethod(String name, String signature) {
    return JStaticMethod._(this, name, signature);
  }

  JInstanceField instanceField(String name, String signature) {
    return JInstanceField._(this, name, signature);
  }

  JStaticField staticField(String name, String signature) {
    return JStaticField._(this, name, signature);
  }
}

/// A thin wrapper over a [JFieldIDPtr] of an instance field.
extension type JInstanceField._fromPointer(JFieldIDPtr pointer) {
  JInstanceField._(JClass jClass, String name, String signature)
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
extension type JStaticField._fromPointer(JFieldIDPtr pointer) {
  JStaticField._(JClass jClass, String name, String signature)
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
extension type JInstanceMethod._fromPointer(JMethodIDPtr pointer) {
  JInstanceMethod._(
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
extension type JStaticMethod._fromPointer(JMethodIDPtr pointer) {
  JStaticMethod._(
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
extension type JConstructor._fromPointer(JMethodIDPtr pointer) {
  JConstructor._(
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
