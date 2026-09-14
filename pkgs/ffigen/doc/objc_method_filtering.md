# Objective-C method filtering

Methods and properties on Objective-C interfaces, protocols, and categories can
be filtered using AST visitors via `Visitor(objCMethod: ...)`.

## Basic filtering

Each `ObjCMethod` node passed to the visitor provides access to:
- `node.selector`: The Objective-C selector string (e.g. `"someMethod:withArg:"` or `"init"`).
- `node.originalName`: The original method name.
- `node.name`: The generated Dart name for this method.
- `node.parent`: The parent declaration (`ObjCInterface`, `ObjCProtocol`, or `ObjCCategory`).
- `node.isPropertyGetter` / `node.isPropertySetter`: Whether this method is an Objective-C property getter or setter.
- `node.isIncluded`: Set to `true` or `false` to include or exclude the method.

```dart
Visitor(
  objCMethod: (node) {
    if (node.parent.name == 'MyInterface') {
      if (node.selector == 'someOtherMethod') {
        node.isIncluded = false;
      }
    }
  },
)
```

## Matching selectors

The `selector` property contains the Objective-C method selector, where the method
name and all external parameter names are concatenated with `:` characters
(e.g., `"application:didFinishLaunchingWithOptions:"`). This matches the selector
used in Objective-C API documentation.

You can match exact selectors or use regular expressions:

```dart
Visitor(
  objCMethod: (node) {
    // Exclude all init methods across interfaces
    if (node.selector.startsWith('init')) {
      node.isIncluded = false;
    }

    // Exclude a specific method on NSDate
    if (node.parent.name == 'NSDate' &&
        node.selector == 'dateWithTimeIntervalSinceNow:') {
      node.isIncluded = false;
    }
  },
)
```

## Property filtering

Objective-C properties are parsed into getter and setter methods. You can inspect
`node.isPropertyGetter` and `node.isPropertySetter` to specifically filter or
customize property accessors:

```dart
Visitor(
  objCMethod: (node) {
    // Exclude all property setters on MyInterface
    if (node.parent.name == 'MyInterface' && node.isPropertySetter) {
      node.isIncluded = false;
    }
  },
)
```
