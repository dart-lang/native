# Runtime type checks in Java (JNI)

Ordinary Dart has a distinction between an object's static type and its
runtime type:

```dart
class Base {}
class Child extends Base {}

Base x = Child();      // x has a static type of Base
print(x.runtimeType);  // but a runtime type of Child
```

The static type determines at compile time what methods are
allowed to be invoked on an object, and the runtime type determines
which class's method implementation is actually invoked at runtime.

When doing Java interop via JNI, another layer of typing is added to each
variable. As well as the Dart static type and runtime type, there is also the
Java runtime type to consider. The (Dart static/Dart runtime/Java runtime)
types could come in just about any combination, e.g. (`Base`/`Child`/`Child`),
(`Base`/`Base`/`Child`), or even (`Base`/`Child`/`Grandchild`).

Just like in the pure Dart case, the Dart static type determines
what methods are allowed to be invoked, but now the method
implementation that is actually invoked at run time is determined
by the *Java* runtime type. In fact, the Dart runtime type is
completely irrelevant when doing Java interop. Moreover, the
Dart wrappers around Java objects are [extension types](
https://dart.dev/language/extension-types#type-considerations),
which means their Dart runtime type (aka representation type) will always be
[`JObject`](https://pub.dev/documentation/jni/latest/jni/JObject-class.html).

Dart's `is` keyword checks the Dart runtime type. You shouldn't use
this on Java objects, because the Dart runtime type is always
`JObject`. If `Foo` and `Bar` are unrelated Java classes wrapped as
extension types, and `x` is a `Foo`, then `x is Bar` will be true at runtime,
making these checks useless and misleading. Instead of `x is Foo`, use
`x.isA(Foo.type)`, which calls into JNI to check the runtime type of the
underlying Java object.

Dart's `as` keyword changes the static type of an object (and also
checks its runtime type). Since the Java wrapper objects are
extension types, this works, but is unsafe. The implicit `is` check
that `as` performs is useless, for the reasons mentioned above.
Instead of `x as Foo`, use `x.as(Foo.type)`, which internally checks
`x.isA(Foo.type)`.

### Generic type erasure

Because of Java generic type erasure, `isA` cannot distinguish between
generic variations of the same class. For example, `Foo<A>` and `Foo<B>`
are both of type `Foo` at runtime in Java. Therefore, even if JNIgen had syntax
like `Foo.type(A.type)` (which it doesn't), `object.isA(Foo.type(A.type))`
would return `true` for objects of type `Foo<B>` as well. So JNIgen simply
generates `Foo.type` even for generic classes.

### Memory management when casting

When casting using `.as()`, you can optionally release the original reference
by passing `releaseOriginal: true`. This is useful to keep the number of active
global JNI references low.

```dart
final JNumber num = foo.someJNumber();
// Cast to JInteger and release the original JNumber reference.
final JInteger jint = num.as(JInteger.type, releaseOriginal: true);
```
