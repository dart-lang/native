# Objective-C method filtering

Methods and properties on Objective-C interfaces, protocols, and categories
are included by default. They can be filtered and renamed using AST visitors
via `Visitor(objCMethod: ...)`.

## Basic filtering

`ObjCMethod` nodes can be filtered and renamed just like any other node.
But it can be particularly helpful to use the `node.parent` and `node.selector`
properties. For example:

```dart
Visitor(
  objCMethod: (node) {
    if (node.parent.name == 'MyInterface') {
      if (node.selector == 'someMethod:withArg:') {
        node.name = 'someMethodWithArg';
      }
      if (node.selector == 'someOtherMethod') {
        node.isIncluded = false;
      }
    }
  },
)
```

## Property filtering

Objective-C properties are parsed into getter and setter methods. You can
inspect `node.isPropertyGetter` and `node.isPropertySetter` to specifically
filter or customize property accessors:

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
