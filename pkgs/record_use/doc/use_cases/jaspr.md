# Jaspr Component Trees record_use

Jaspr is a web framework. The goal is to generate a minimal CSS file containing
only the styles used in a Jaspr application. This is achieved by using
`record_use` to extract information about which components are used and what
styles they apply. This enables a "Tailwind-like" experience where developers
use style utilities and the final CSS is tree-shaken.

For example, a `Column` component might have styling options passed to its
constructor:

<!-- no-source-file -->
```dart
class Column extends Component {
  @RecordUse()
  const Column({this.spacing = 0, this.crossAxisAlignment = 'start'});

  @override
  Iterable<Component> build(BuildContext context) {
    // ...
  }
}
```

When this component is used, we want to record the constructor call, including
the arguments:

<!-- no-source-file -->
```dart
class MyComponent extends Component {
  @override
  Iterable<Component> build(BuildContext context) {
    return [
      Column(spacing: 42, crossAxisAlignment: 'center'),
    ];
  }
}
```

A link-time hook can then process all recorded uses of `Column`. From the
`spacing` and `crossAxisAlignment` arguments, it can generate the required CSS
rules and emit them into a single CSS file for the application:

```css
.column-spacing-42 {
  padding: 42px;
}

.column-cross-axis-center {
  align-items: center;
}
```

## Information required for CSS generation

To generate the CSS, the link hook needs to know about all constructor calls to
components that are annotated with `@RecordUse`.

* **`const` constructor calls**:
  These are the most common in component trees. We need to record the static
  calls to these `const` constructors and the values of their arguments.
  See: https://github.com/dart-lang/native/issues/2911

* **`const` instances**:
  `const` instances of components are also common. The hook needs to be aware
  of these instances and their field values.
  (We are _not_ interested in any of these const instances occurring in
  annotations, such as https://github.com/dart-lang/native/issues/2719.)

* **Non-`const` constructor calls**:
  Component trees are not always `const`. To ensure all styles are captured, we
  also need to record non-`const` constructor calls.
  See: https://github.com/dart-lang/native/issues/2907

By collecting this information, a tool can build a complete picture of which
styling primitives are used in an application and generate an optimized CSS file.

## Links

* https://github.com/schultek/jaspr
* https://github.com/schultek/universal_widgets
