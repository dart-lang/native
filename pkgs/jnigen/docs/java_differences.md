## Syntax and semantic differences between Java and the generated Dart bindings

### Method overloading

Java supports overloading methods. This means that it can distinguish between
two methods with the same name that have a different signature.

```java
public class Calculator {
  public int add(int a, int b) {
    return a + b;
  }

  public double add(double a, double b) {
    return a + b;
  }

  public float add(float a, float b) {
    return a + b;
  }
}
```

This is not the case for Dart. Each method of a class must have a different
name. To overcome this limitation, JNIgen adds a numeric suffix to the end of
the overloaded method name.

```dart
class Calculator extends JObject {
  // Omitted for clarity.
  int add(int a, int b) { /* ... */ }
  double add1(double a, double b) { /* ... */ }
  double add2(double a, double b) { /* ... */ }
}
```

> [!WARNING]  
> Running the code generator again on a different version of the library can map
> the methods differently if the order of the methods change or another
> overloading of the same method gets added.
>
> Double check the doc comments on the generated methods to make sure you are
> calling your intended method.

What if we have another two methods named `add1`?

```java
public class Calculator {
  public int add(int a, int b) {
    return a + b;
  }

  public double add(double a, double b) {
    return a + b;
  }

  public float add(float a, float b) {
    return a + b;
  }

  public int add1(int a) {
    return a + 1;
  }

  public double add1(double a) {
    return a + 1;
  }
}
```

> [!IMPORTANT]  
> JNIgen adds a dollar sign (`$`) to all the methods ending with a number by
> default.

So the generated code will be:

```dart
class Calculator extends JObject {
  // Omitted for clarity.
  int add(int a, int b) { /* ... */ }
  double add1(double a, double b) { /* ... */ }
  double add2(double a, double b) { /* ... */ }
  int add1$(int a) { /* ... */ }
  double add1$1(double a) { /* ... */ }
}
```
