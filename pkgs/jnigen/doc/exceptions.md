# Handling Java Exceptions in Dart

When a Java method throws an exception, JNIgen translates this into a Dart `JThrowable` being thrown. By default, you can catch `JThrowable` to handle any Java-side exception.

If you have custom exceptions defined in Java, you can catch them in Dart, check their type, cast them, and access their specific fields and methods.

## Example

### Java Definition

Consider a custom exception defined in Java:

```java
package com.example;

public class MyCustomException extends RuntimeException {
  private final int errorCode;

  public MyCustomException(String message, int errorCode) {
    super(message);
    this.errorCode = errorCode;
  }

  public int getErrorCode() {
    return errorCode;
  }
}
```

And a method that throws it:

```java
public class Api {
  public static void doSomething() {
    throw new MyCustomException("Something went wrong", 404);
  }
}
```

### Dart Usage

In Dart, after generating bindings for these classes, you can catch the exception as a `JThrowable` and use `isA` and `as` to cast it to your custom exception type:

```dart
import 'package:jni/jni.dart';
import 'bindings.dart'; // Assuming this contains generated bindings

void main() {
  try {
    Api.doSomething();
  } on JThrowable catch (e) {
    if (e.isA(MyCustomException.type)) {
      final customEx = e.as(MyCustomException.type);
      print('Caught custom exception!');
      print('Message: ${customEx.getMessage().toDartString()}');
      print('Error Code: ${customEx.getErrorCode()}');
    } else {
      print('Caught generic Java exception: $e');
    }
  }
}
```

Alternatively, you can use a Dart `switch` statement with pattern matching:

```dart
try {
  Api.doSomething();
} on JThrowable catch (e) {
  switch (e) {
    case _ when e.isA(MyCustomException.type):
      final customEx = e.as(MyCustomException.type);
      print('Caught MyCustomException with code: ${customEx.getErrorCode()}');
      break;
    default:
      print('Caught generic Java exception: $e');
  }
}
```

## Key Concepts

* **`JThrowable`**: The base class for all Java exceptions in Dart. Any exception thrown from Java will emerge as a `JThrowable` in Dart.
* **`isA(JObjType)`**: Used to check if a `JObject` (including `JThrowable`) is of a specific Java type. Do not use Dart's `is` operator, as JNIgen bindings are extension types and their Dart runtime type is always `JObject`.
* **`as(JObjType)`**: Used to cast a `JObject` to a specific Java type. Do not use Dart's `as` operator for Java objects.

> [!NOTE]
> JNIgen uses Dart extension types for Java object wrappers. Because of this, standard Dart type checks (`is`) and casts (`as`) do not work as expected at runtime. Always use `.isA()` and `.as()` for JNI objects.

For more details on type checks and casting, see [Runtime type checks in Java (JNI)](java_runtime_types.md).
