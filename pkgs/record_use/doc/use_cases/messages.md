# messages record_use

The goal of this package is to provide translation. The goal of using link hooks
is to be able to shrink the translation files based on use.

```dart
class MessageTable {
  @RecordUse()
  static String lookup(int id, String appId) => // ...

  @RecordUse()
  static String evaluate(int id, String appId, List<dynamic> args) =>
      // ...
}
```

```dart
String translateFoo() => lookup(/*int id of foo*/0, 'baz');

String translateBar(String name) => evaluate(/*int id of foo*/0, 'baz', name);
```

The calls to the translate methods are almost always generated. Either by a
transformer as a compiler plugin or by an external code generator that generates
the API for the translations.

If a transformer use used, the pre-transform code looks something like:

```dart
class Intl {
  static String message(String messageText,
          {String? desc = '',
          Map<String, Object>? examples,
          String? locale,
          String? name,
          List<Object>? args,
          String? meaning,
          bool? skip});
}
```

An `id` is generated based on the calls to `message` and the message calls are
transformed to the `lookup` and `evaluate` calls.

This transformation step might not be needed if we can reconstruct the
id-generation in the link hook.

## Information needed for tree-shaking

The uses of the static methods, and their const argument values.

## Links

* https://pub.dev/packages/intl
* https://pub.dev/packages/messages
