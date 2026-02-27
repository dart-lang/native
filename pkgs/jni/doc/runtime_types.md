# Runtime type checks in Java

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

When doing Java interop, another layer of typing is added to each variable.
As well as the Dart static type and runtime type, there is also the Java
runtime type to consider. The (Dart static/Dart runtime/Java runtime)
types could come in just about any combination, e.g. (`Base`/`Child`/`Child`),
(`Base`/`Base`/`Child`), or even (`Base`/`Child`/`Grandchild`).

Just like in the pure Dart case, the Dart static type determines
what methods are allowed to be invoked, but now the method
implementation that is actually invoked at run time is determined
by the _Java_ runtime type. In fact, the Dart runtime type is
completely irrelevant when doing Java interop. Moreover, the
Dart wrapper around the Java object is an [extension type](https://dart.dev/language/extension-types#type-considerations),
which means the Dart runtime type will always be the underlying
representation type (usually `JObject`).

Dart's `is` keyword checks the Dart runtime type. You shouldn't use
this on Java objects, because the Dart runtime type is always
`JObject`. If `Foo` and `Bar` are unrelated Java classes, and `x`
a `Foo`, then `x is Bar` will be true, making these checks useless and
misleading. Instead of `x is Foo`, use `Foo.type.isA(x)`, which calls into
JNI to check the runtime type of the underlying object using `IsInstanceOf`.

Dart's `as` keyword changes the static type of an object (and also
checks its runtime type). Since the Java wrapper objects are
extension types, this works, but is unsafe. The implicit `is` check
that `as` performs is useless, for the reasons mentioned above.
Instead of `x as Foo`, use `Foo.type.as(x)`, which internally checks
`Foo.type.isA(x)` and throws a `CastError` if it fails.
