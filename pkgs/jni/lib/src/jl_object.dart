import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'third_party/jni_bindings_generated.dart';
import 'jni_exceptions.dart';
import 'jni.dart';

/// A container for a global [JObject] reference.
class JlObject {
  /// Constructs a `JlObject` from JNI reference.
  JlObject.fromRef(this.reference);

  /// Stored JNI global reference to the object.
  JObject reference;

  bool _deleted = false;

  /// Deletes the underlying JNI reference.
  ///
  /// Must be called after this object is no longer needed.
  void delete() {
    if (_deleted) {
      throw DoubleFreeException(this, reference);
    }
    _deleted = true;
    // TODO(#12): this should be done in jni-thread-safe way
    // will be solved when #12 is implemented.
    Jni.getInstance().getEnv().DeleteGlobalRef(reference);
  }
}

/// A container for JNI strings, with convertion to & from dart strings.
class JlString extends JlObject {
  JlString.fromRef(JString reference) : super.fromRef(reference);

  static JString _toJavaString(String s) {
    final chars = s.toNativeUtf8().cast<Char>();
    final jstr = Jni.getInstance().toJavaString(chars);
    malloc.free(chars);
    return jstr;
  }

  JlString.fromString(String s) : super.fromRef(_toJavaString(s));

  String toDartString() {
    final jni = Jni.getInstance();
    if (reference == nullptr) {
      throw NullJlStringException();
    }
    final chars = jni.getJavaStringChars(reference);
    final result = chars.cast<Utf8>().toDartString();
    jni.releaseJavaStringChars(reference, chars);
    return result;
  }

  late final _dartString = toDartString();

  @override
  String toString() => _dartString;
}
