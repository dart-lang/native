# Icon data record_use

The goal here is to be able to tree-shake icon fonts in Flutter. Currently, this
is a custom-built solution in Flutter. This should be the capability of a
package.

Dart API and use:

<!-- no-source-file -->
```dart
class IconData {
  const IconData(
    this.codePoint, {
    this.fontFamily,
    this.fontPackage,
    this.matchTextDirection = false,
    this.fontFamilyFallback,
  });
}
```

<!-- no-source-file -->
```dart
abstract final class GalleryIcons {
  static const IconData tooltip = IconData(0xe900, fontFamily: 'GalleryIcons');
  static const IconData text_fields_alt = IconData(0xe901, fontFamily: 'GalleryIcons');
  // ...
}
```

## Information needed for tree-shaking

Const instances inside Dart code (const instances inside annotations are not
reachable at runtime, and thus can never be used).

Note that `const` constructors can be called in non-`const` contexts. To
reliably track all uses, we need to record both `const` instances and all calls
to `const` constructors, regardless of whether the call site is `const`.

* https://github.com/dart-lang/native/issues/2911

Moreover, we need the arguments to the const constructor calls and the fields of
the const instances.

### Static getters won't work.

Since this API is already in active use, we cannot simply change the API to
static getters, as that would prevent const:

<!-- no-source-file -->
```dart
abstract final class GalleryIcons {
  static IconData get tooltip => IconData(0xe900, fontFamily: 'GalleryIcons');
  static IconData get text_fields_alt => IconData(0xe901, fontFamily: 'GalleryIcons');
  // ...
}
```

An API with static getters (disallowing const instances) would enable two other
possiblities of recording uses.

1. Record each static getter in `GalleryIcons` individually, no arguments.
   (Static calls we are aiming for in v1.0)
2. Record the non-const constructor of `IconData` with the const argument values.
   This requires:
   
   * https://github.com/dart-lang/native/issues/2907

Flutter actively makes everything const, so forcing this API to be non-const is
a no-go.

## Links

* https://api.flutter.dev/flutter/cupertino/CupertinoIcons-class.html
* https://github.com/flutter/flutter/pull/174860
