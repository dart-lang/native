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
completely irrelevant when doing Objective-C interop.

Dart's `is` keyword checks the Dart runtime type. You shouldn't use
this on Objective-C objects, because the Dart runtime type is irrelevant, and
often won't match the Objective-C runtime type. Instead of `x is Foo`,
use `Foo.isInstance(x)`.

Dart's `as` keyword changes the static type of an object (and also
checks its runtime type). You shouldn't use this on Objective-C objects,
because the runtime type check may fail since the Dart runtime
type often won't match the Objective-C runtime type. Instead of `x as Foo`,
use `Foo.castFrom(x)`.
