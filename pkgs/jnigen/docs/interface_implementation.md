## Implementing Java interfaces from Dart

> [!NOTE]  
> This feature is experimental, and in
> [active development](https://github.com/dart-lang/native/issues/1569).
>
> To opt in to use this feature, add the following to your JNIgen configuration
> yaml:
>
> ```yaml
> enable_experiment:
>   - interface_implementation
> ```

Let's take a simple Java interface like `Runnable` that has a single `void`
method called `run`:

```java
// Java
public interface Runnable {
  void run();
}
```

These are the bindings that JNIgen generates for this interface:

```dart
// Dart Bindings - Boilerplate omitted for clarity.
class Runnable extends JObject {
  void run() { /* ... */ }

  factory Runnable.implement($Runnable impl) { /* ... */ }
  static void implementIn(
    JImplementer implementer,
    $Runnable impl,
  ) { /* ... */ }
}

abstract interface class $Runnable {
  factory $Runnable({
    required void Function() run,
  }) = _$Runnable;

  void run();
}

class _$Runnable implements $Runnable {
  _$Runnable({
    required void Function() run,
  }) : _run = run;

  final void Function() _run;

  void run() {
    return _run();
  }
}
```

### Implementing interfaces inline

`Runnable` is used a lot to pass a void callback to a function. To simply this
workflow, Java 8 introduced lambdas.

```java
// Java
Runnable runnable = () -> System.out.println("hello");
```

To allow the same flexibility in Dart, `$Runnable` has a default factory that
simply gets each method of the interface as a closure argument. So you would do:

```dart
// Dart
final runnable = Runnable.implement($Runnable(run: () => print('hello')));
```

### Reuse the same implementation

The reason JNIgen generates the `$Runnable` class is to make it easier to reuse
the same implementation for multiple instances. This is analogous to actually
implementing the interface in Java instead of using the lambdas:

```java
// Java
public class Printer implements Runnable {
  private final String text;

  public Printer(String text) {
    this.text = text;
  }

  @Override
  public void run() {
    System.out.println(text);
  }
}
```

This way you can create multiple such Runnables like `new Printer("hello")` and
`new Printer("world")`.

You can do the same in Dart by creating a subclass that implements `$Runnable`:

```dart
// Dart
class Printer implements $Runnable {
  final String text;

  Printer(this.text);

  @override
  void run() {
    print(text);
  }
}
```

And similarly write `Runnable.implement(Printer('hello'))` and
`Runnable.implement(Printer('world'))`, to create multiple Runnables and share
common logic.

### Implement multiple interfaces

To implement more than one interface, use a `JImplementer` from `package:jni`.
`Closable` is another simple Java interface that has a single void `close`
method. Here is how we create an object that implements both `Runnable` and
`Closable`:

```dart
// Dart
final implementer = JImplementer();
Runnable.implementIn(implementer, $Runnable(run: () => print('run')));
Closable.implementIn(implementer, $Closable(close: () => print('close')));
final object = implementer.implement(Runnable.type); // or Closable.type.
```

As the created `object` implements both `Runnable` and `Closable`, it's also
possible to make it a `Closable` by passing in `Closable.type` to
`implementer.implement`. Or simply cast it after creation:

```dart
// Dart
final closable = object.castTo(Closable.type);
```
