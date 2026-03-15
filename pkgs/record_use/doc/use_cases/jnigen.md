# JNIgen record_use

JNIgen generates Dart bindings to Java/Kotlin code. After tree-shaking the generated
Dart code not all Java/Kotlin code is reachable. To tree-shake the unreachable
Java/Kotlin code we want to generate ProGuard rules that list all the
reachable Java/Kotlin classes, methods, and fields.

## Information needed for tree-shaking

### 1. Which classes are possibly instantiated.

<!-- no-source-file -->
```dart
class PDDocument extends jni$_.JObject {
  PDDocument.fromReference(
    jni$_.JReference reference,
  );

  factory PDDocument() {
    return PDDocument.fromReference(
        _new$(_class.reference.pointer, _id_new$ as jni$_.JMethodIDPtr)
            .reference);
  }

  factory PDDocument.new$1(
    jni$_.JObject? memUsageSetting,
  );
}
```

This requires tracking non-const (factory) constructor calls.

* https://github.com/dart-lang/native/issues/2907

Because the `JObjects` are wrappers around native pointers, none of the JNIgen
generated classes will ever have const constructors.

### 2. Which methods, getters and setters are reachable.

<!-- no-source-file -->
```dart
class PDDocument extends jni$_.JObject {
  void addPage(
    jni$_.JObject? page,
  )
}
```

This requires tracking instance calls, or generating a static call inside the
instance call. JNIgen already generates a static field (with a static getter)
that could be annotated to record a static call:

<!-- no-source-file -->
```dart
class PDDocument extends jni$_.JObject {
  static final _addPage = jni$_.ProtectedJniExtensions.lookup<
              jni$_.NativeFunction<
                  jni$_.JThrowablePtr Function(
                      jni$_.Pointer<jni$_.Void>,
                      jni$_.JMethodIDPtr,
                      jni$_.VarArgs<(jni$_.Pointer<jni$_.Void>,)>)>>(
          'globalEnv_CallVoidMethod')
      .asFunction<
          jni$_.JThrowablePtr Function(jni$_.Pointer<jni$_.Void>,
              jni$_.JMethodIDPtr, jni$_.Pointer<jni$_.Void>)>();

  void addPage(
    final _$page = page?.reference ?? jni$_.jNullReference;
    _addPage(reference.pointer, _id_addPage as jni$_.JMethodIDPtr,
            _$page.pointer)
        .check();
  )
}
```

Java fields in JNIgen generated code are Dart getters and setters.

* https://github.com/dart-lang/native/issues/2906

### 3. Mapping Dart identifiers to native identifiers

For each class-use and method/field-use the link hook in JNIgen needs to know
the original Java/Kotlin unique name.

Since JNIgen is already a code generator, this can be achieved by generating a
file that maps Dart identifiers to Java identifiers:

<!-- no-source-file -->
```dart
const dartToJava = {
  DartMethodIdentifer(
    importUrl: 'package:foo/foo.dart',
    name: 'Bar',
    methodName: 'baz',
  ) : JavaMethodDefinition(
    qualifiedImport: 'org.foo.foo',
    name: 'Bar',
    methodName: 'baz',
  ),
  // ...
}
```

## Links

* https://pub.dev/packages/jnigen
