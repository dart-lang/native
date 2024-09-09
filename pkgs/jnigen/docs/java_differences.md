## Syntax and semantic differences between Java and the generated Dart bindings

### Method overloading

Java supports overloading methods. This means that it can distinguish between
two methods with the same name that have a different signature.

```java
// Java
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

This is not the case for Dart. Each method of a class must have a unique
name. To overcome this limitation, JNIgen adds a dollar sign (`$`) and a numeric
suffix to the end of the overloaded method name.

```dart
// Dart Bindings
class Calculator extends JObject {
  // Omitted for clarity.
  int add(int a, int b) { /* ... */ }
  double add$1(double a, double b) { /* ... */ }
  double add$2(double a, double b) { /* ... */ }
}
```

> [!INFORMATION]  
> Running the code generator again on a different version of the library can map
> the methods differently if the order of the methods change or another
> overloading of the same method gets added.
>
> Double check the doc comments on the generated methods to make sure you are
> calling your intended method.

You might wonder why the method isn't renamed to `add1` instead of `add$1`. The reason is that a method named `add1` could already exist in the Java class.

```java
// Java
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

In this case, the generated code will be:

```dart
// Dart Bindings
class Calculator extends JObject {
  // Omitted for clarity.
  int add(int a, int b) { /* ... */ }
  double add$1(double a, double b) { /* ... */ }
  double add$2(double a, double b) { /* ... */ }
  int add1(int a) { /* ... */ }
  double add1$2(double a) { /* ... */ }
}
```
