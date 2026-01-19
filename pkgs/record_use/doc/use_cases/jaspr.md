# Jasper Widget Trees record_use

Goal of using record_use, extracting information from the widget trees and
generating css (like tailwind).

```dart
class Column {
  @RecordUse()
  const Column({this.spacing = 0});
}

class MyWidget {
  build() {
    return Column(spacing: 42);
  }
}
```

## Information required for extracting css

* Static const-constructor calls.
  https://github.com/dart-lang/native/issues/2911
* Const instances in Dart code.
  (We are _not_ interested in any of these const instances occurring in
  annotations, such as https://github.com/dart-lang/native/issues/2719.)
  Lints such as prefer const will toggle Dart code between const instances and
  static calls to const constructors often.
* Potentially: Static non-const constructor calls.
  https://github.com/dart-lang/native/issues/2907
  In general, widget trees are constructed in such a way that they allow for
  const constructors always, so non-const constructors might not have to be
  supported. However, if we support static (non-const) calls to const
  constructors, we'd like also support static calls to const constructors.

## Links

* https://github.com/schultek/universal_widgets
