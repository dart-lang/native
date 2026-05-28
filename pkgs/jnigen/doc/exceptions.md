# Handling Java Exceptions in Dart

When a Java method throws an exception, JNIgen translates this
into a Dart `JThrowable` and rethrows it on the Dart-side.

You can catch the `JThrowable` using an ordinary Dart `try`/`catch`,
check its type using `.isA`, and cast it using `.as`.
Using this pattern you can handle any Java exception you have bindings for.

> [!WARNING]
> JNIgen uses Dart extension types for its Java object wrappers,
> so Dart's built in `is` and `as` won't work as expected.
> Instead, you should use `.isA` and `.as` for Java objects.
> See [java_runtime_types.md](java_runtime_types.md) for more info.

## Example

Consider a custom exception defined in Java:

```java
public class MyCustomException extends RuntimeException {
  public int errorCode;

  public MyCustomException(String message, int errorCode) {
    super(message);
    this.errorCode = errorCode;
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

In Dart, after generating bindings for these classes, you can catch the
exception as a `JThrowable` and use `isA` and `as` to cast it to
your custom exception type:

```dart
void doSomethingInJava() {
  try {
    Api.doSomething();
  } on JThrowable catch (throwable, stackTrace) {
    print('Message: ${throwable.message}');
    print('Java stack trace:\n${throwable.javaStackTrace}');
    print('Dart stack trace:\n$stackTrace');

    if (e.isA(MyCustomException.type)) {
      final customEx = throwable.as(MyCustomException.type);
      print('Caught MyCustomException!');
      print('Error Code: ${customEx.errorCode}');
    } else {
      print('Caught unknown Java exception: $throwable');
    }
  }
}
```

> [!NOTE]
> Since `MyCustomException` is an extension type of `JObject`,
> not `JThrowable`, `.message` and `.javaStackTrace` are not available
> on the `customEx` variable. They're only available on the `throwable`
> variable, since it is directly a `JThrowable`.
