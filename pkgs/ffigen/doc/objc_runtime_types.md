# Runtime type checks in Objective-C

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

When doing Objective-C interop (or Java interop for that matter),
another layer of typing is added to each variable. As well as the
Dart static type and runtime type, there is also the Objective-C
runtime type to consider. The (Dart static/Dart runtime/Objective-C runtime)
types could come in just about any combination, e.g. (`Base`/`Child`/`Child`),
(`Base`/`Base`/`Child`), or even (`Base`/`Child`/`Grandchild`).

Just like in the pure Dart case, the Dart static type determines
what methods are allowed to be invoked, but now the method
implementation that is actually invoked at run time is determined
by the *Objective-C* runtime type. In fact, the Dart runtime type is
completely irrelevant when doing Objective-C interop. Moreover, the
Dart wrapper around the Objective-C object is an [extension type](
https://dart.dev/language/extension-types#type-considerations),
which means the Dart runtime type will always be [`ObjCObject`](
https://pub.dev/documentation/objective_c/latest/objective_c/ObjCObject-class.html).

Dart's `is` keyword checks the Dart runtime type. You shouldn't use
this on Objective-C objects, because the Dart runtime type is always
`ObjCObject`. If `Foo` and `Bar` are unrelated  `ObjCObject`s, and `x`
a `Foo`, then `x is Bar` will be true, making these checks useless and
misleading. Instead of `x is Foo`, use `Foo.isA(x)`, which calls into
Objective-C to check the runtime type of the underlying object.

Dart's `as` keyword changes the static type of an object (and also
checks its runtime type). Since the Objective-C wrapper objects are
extension types, this works, but is unsafe. The implicit `is` check
that `as` performs is useless, for the reasons mentioned above.
Instead of `x as Foo`, use `Foo.as(x)`, which internally checks
`Foo.isA(x)`.
