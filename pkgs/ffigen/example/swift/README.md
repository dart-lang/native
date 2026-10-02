# Swift example

This example shows how to use FFIgen to interact with Swift libraries.

Swift APIs can be made compatible with Objective-C, using the `@objc`
annotation. Then you can use the `swiftc` tool to build a dylib for the library
using `-emit-library`, and generate an Objective-C wrapper header using
`-emit-objc-header-path filename.h`:

```shell
swiftc -c swift_api.swift                           \
    -module-name swift_module                       \
    -emit-objc-header-path third_party/swift_api.h  \
    -emit-library -o libswiftapi.dylib
```

This should generate libswiftapi.dylib and swift_api.h.
For more information about Objective-C / Swift interoperability, see the
[Apple documentation](https://developer.apple.com/documentation/swift/importing-swift-into-objective-c).

Once you have an Objective-C wrapper header, FFIgen can parse it like
any other header:

```shell
dart run tool/ffigen.dart
```

This will generate [swift_api_bindings.dart](./swift_api_bindings.dart).

Finally, you can run the example using this command:

```shell
dart run example.dart
```

## Config notes

The FFIgen configuration is defined in `tool/ffigen.dart`. FFIgen only sees
the Objective-C wrapper header, `swift_api.h`. So you need to enable Objective-C
support and set the entry-point to the header.

<!-- file://./tool/ffigen.dart#generator -->
```dart
final generator = FfiGenerator(
  output: Output(
    dart: DartOutput(path: packageRoot.resolve('swift_api_bindings.dart')),
  ),
  objectiveC: const ObjectiveC(),
  input: Input(entryPoints: [packageRoot.resolve('third_party/swift_api.h')]),
  visitors: [
    Visitor(
      objCInterface: (node) {
        if (node.name == 'SwiftClass') {
          node.isIncluded = true;
          node.module = 'swift_module';
        }
      },
    ),
  ],
);
```

There are two important things to note about this example:
1. Swift classes become Objective-C interfaces, so include them using an
  `objCInterface` visitor.
2. When `swiftc` compiles the library, it gives the Objective-C interface
  a module prefix. Internally, our `SwiftClass` is actually registered
  as `swift_module.SwiftClass`. So you need to tell FFIgen about this prefix
  using `node.module`. The module is whatever you passed to `swiftc` in the
  `-module-name` flag.
