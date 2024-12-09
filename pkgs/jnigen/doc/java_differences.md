## Syntactic and semantic differences between Java and the generated Dart bindings

This document highlights the key syntactic and semantic variations between Java
and Dart and how JNIgen addresses them to ensure smooth interoperability.

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

This is not the case for Dart. Each method of a class must have a unique name.
To overcome this limitation, JNIgen adds a dollar sign (`$`) and a numeric
suffix to the end of the overloaded method name.

```dart
// Dart Bindings - Boilerplate omitted for clarity.
class Calculator extends JObject {
  int add(int a, int b) { /* ... */ }

  double add$1(double a, double b) { /* ... */ }

  double add$2(double a, double b) { /* ... */ }
}
```

> [!WARNING]  
> Running the code generator again on a different version of the library can map
> the methods differently if the order of the methods change or another
> overloading of the same method gets added.
>
> Double check the doc comments on the generated methods to make sure you are
> calling your intended method.

You might wonder why the method isn't renamed to `add1` instead of `add$1`. The
reason is that a method named `add1` could already exist in the Java class. On
the other hand, Java identifiers normally do not contain dollar signs.

> [!NOTE]  
> See
> [Identifiers containing dollar signs](#identifiers-containing-dollar-signs) to
> see what JNIgen does when identifiers contain dollar signs.

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
// Dart Bindings - Boilerplate omitted for clarity.
class Calculator extends JObject {
  int add(int a, int b) { /* ... */ }

  double add$1(double a, double b) { /* ... */ }

  double add$2(double a, double b) { /* ... */ }

  int add1(int a) { /* ... */ }

  double add1$1(double a) { /* ... */ }
}
```

### Fields and methods with the same name

In Java, we can have a field and a method with the same name. This is not
possible in Dart.

```java
// Java
public class Player {
  // Player's personal duck!
  public Duck duck;

  // Lower your head!
  public void duck() { /* ... */ }
}
```

JNIgen handles this similarly to [method overloading](#method-overloading). The
method with the same name as the field will be appended by a dollar sign (`$`)
followed by a numeric suffix.

```dart
// Dart Bindings - Boilerplate omitted for clarity.
class Player extends JObject {
  Duck get duck { /* ... */ };
  set duck(Duck value) { /* ... */ }

  void duck$1() { /* ... */ }

  // If there were more `duck` methods they would be named
  // `duck$2`, `duck$3`, ...
}
```

It is important to note that the order of renaming is fields-first
methods-second. So when both a field named `duck` and a method named `duck`
exist, the field keeps its original name as seen above.

However the renaming happens for superclasses first. Consider this case.

```java
// Java
public class Player {
  // Lower your head!
  public void duck() { /* ... */ }
}

public class DuckOwningPlayer extends Player {
  // Player's personal duck!
  public Duck duck;
}
```

The `Player` class already has a method named `duck` and no field with the same
name. So this will be the generated bindings for it:

```dart
// Dart Bindings - Boilerplate omitted for clarity.
class Player extends JObject {
  void duck() { /* ... */ }
}
```

`DuckOwningPlayer` inherits the `duck()` method from `Player` and adds a field
named `duck`. This time, the field will be renamed as the method is simply
inherited.

```dart
// Dart Bindings - Boilerplate omitted for clarity.
class DuckOwningPlayer extends Player {
  Duck get duck$1 { /* ... */ };
  set duck$1(Duck value) { /* ... */ }
}
```

### Identifiers containing dollar signs

JNIgen uses dollar signs in the generated code to fill the syntactic and
semantic gaps between Java and Dart. This normally does not cause a problem as
the
[Java language specificifaction](https://docs.oracle.com/javase/specs/jls/se11/html/jls-3.html#jls-3.8)
suggests dollar signs should be used only in the generated code or, rarely, to
access pre-existing names on legacy systems.

JNIgen replaces each single dollar sign with two dollar signs. For example
`generated$method$2` will turn into `generated$$method$$2`. This prevents name
collision as JNIgen-renamed identifiers will end with an odd number of dollar
signs (optionally followed by a numeric suffix).

### Identifier starting with underscore (`_`)

Unlike Java, Dart identifiers that start with an underscore are private. This
means they are inaccessible outside their defining scope. Users should still be
able to access public Java identifiers that start with an underscore from the
generated Dart bindings. To allow this, JNIgen prepends such identifiers with a
dollar sign to keep them public in Dart.

For example, `_Example` in Java will be converted to `$_Example` in the Dart
bindings:

```java
// Java
public class _Example {
  public void _printMessage() {
    System.out.println("Hello from Java!");
  }
}
```

```dart
// Dart Bindings - Boilerplate omitted for clarity.
class $_Example extends JObject {
  void $_printMessage() { /* ... */ }
}
```

### Inner classes

Java has the concept of inner classes, while Dart does not. Therefore, inner
classes are generated as separate classes named by the name of their outer class
followed by a dollar sign (`$`) followed by their original name.

For example:

```java
// Java
public class Outer {
  public class Inner {}
}
```

will be turned into:

```dart
// Dart Bindings - Boilerplate omitted for clarity.
class Outer extends JObject {}

class Outer$Inner extends JObject {}
```
