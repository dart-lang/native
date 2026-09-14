# FAQ

## Can FFIgen be used for removing underscores or renaming declarations?

You can use a `Visitor` to rename declarations or members, by setting the `name` property.

Here's an example of how to remove prefix underscores from any struct name:

```dart
Visitor(
  struct: (node) {
    if (node.name.startsWith('_')) {
      node.name = node.name.substring(1);
    }
  },
)
```

## How to generate declarations only from particular headers?

The default behavior is to include everything directly or transitively under each of the `entryPoints` specified in `Input`.

If you only want declarations from particular headers, you can provide an `include` callback to `Input`:

```dart
Input(
  entryPoints: [packageRoot.resolve('path/to/my_header.h')],
  include: (header) => header.path.endsWith('my_header.h'),
)
```

## Can FFIgen filter declarations by name?

By default, all top level API elements are excluded from the generated bindings.
You must write a `Visitor` to include the specific APIs you want:

```dart
Visitor(
  func: (node) {
    // Include all functions starting with clang.
    node.isIncluded = node.name.startsWith('clang'); 
  },
)
```

## How does FFIgen handle C Strings?

FFIgen treats `char*` just as any other pointer (`Pointer<Int8>`).
To convert these to/from `String`, you can use [package:ffi](https://pub.dev/packages/ffi).
Use `ptr.cast<Utf8>().toDartString()` to convert `char*` to dart `string` and
`"str".toNativeUtf8()` to convert `string` to `char*`.

## How are unnamed enums handled?

Unnamed enums are visited via `Visitor.unnamedEnumConstant` and generated as top-level constants.

Here's an example that shows how to include and rename unnamed enum constants:

```dart
Visitor(
  unnamedEnumConstant: (node) {
    node.isIncluded = node.originalName.startsWith('CX');
    if (node.name.startsWith('CXType_')) {
      node.name = node.name.replaceFirst('CXType_', '');
    }
  },
)
```

## How can I handle unexpected enum values?

Native enums are, by default, generated into Dart enums with `int get value` and
`fromValue(int)`. This works well in the case that your enum values are known
in advance and not going to change, and in return, you get the full benefits of
Dart enums like exhaustiveness checking.

However, if a native library adds another possible enum value after you generate
your bindings, and this new value is passed to your Dart code, this will result
in an `ArgumentError` at runtime. To fix this, you can regenerate the bindings
on the new header file, but if you wish to avoid this issue entirely, you can
tell FFIgen to generate plain Dart integers for your enum instead. To do this,
set `node.style = EnumStyle.intConstants` in a visitor:

```dart
Visitor(
  enumClass: (node) {
    if (node.name == 'MyIntegerEnum') {
      node.style = EnumStyle.intConstants;
    }
  },
)
```

Functions that accept or return these enums will now accept or return integers
instead, and it will be up to your code to map integer values to behavior and
handle invalid values. But your code will be future-proof against new additions
to the enums.

## Why are some struct/union declarations generated even after excluding them?

This happens when an excluded struct/union is a dependency to some included
declaration. (A dependency means a struct is being passed/returned by a function
or is member of another struct in some way.)

Note: You can configure `dependencies = CompoundDependencies.opaque` so that
FFIgen generates these struct dependencies as `Opaque` if they were only passed
by reference (pointer):

```dart
Visitor(
  struct: (node) {
    // You can set the opaque option for all nodes.
    node.dependencies = CompoundDependencies.opaque;
  },
  union: (node) {
    // Or for specific nodes.
    if (node.name == 'MyOpaqueUnion') {
      node.dependencies = CompoundDependencies.opaque;
    }
  },
)
```

## How to expose the native function pointers?

By default, native function pointers are private, but you can expose them by setting
`node.exposeSymbolAddress = true` on `Func` or `Global` nodes:

```dart
Visitor(
  func: (node) {
    if (node.name == 'someFunc') {
      node.exposeSymbolAddress = true;
    }
  },
)
```

## How to get typedefs to Native and Dart type of a function?

By default, these types are inline. But you can set `node.generateTypedefs = true`
on a `Func` node to generate them. This will expose the Native and Dart types.
E.g. for a function named `hello` the generated typedefs are named
`NativeHello` and `DartHello`.

```dart
Visitor(
  func: (node) {
    if (node.name == 'hello') {
      node.generateTypedefs = true;
    }
  },
)
```

## How are Structs/Unions/Enums that are referred to via typedefs handled?

Named declarations use their own names even when inside another typedef.
However, unnamed declarations inside typedefs take the name of the _first_
typedef that refers to them.

## Why are some typedefs not generated?

The following typedefs are not generated:
  - They are not referred to anywhere in the included declarations.
  - They refer to a struct/union having the same name as itself.
  - They refer to a boolean, enum, inline array, Handle or any unsupported type.

## How are macros handled?

FFIgen uses `clang`'s own compiler frontend to parse and traverse the `C`
header files. FFIgen expands the macros using `clang`'s macro expansion and
then traverses the expanded code. To do this, FFIgen generates temporary files
in a system tmp directory.

A custom temporary directory can be specified by setting the `TEST_TMPDIR`
environment variable.

## What are these logs generated by FFIgen and how to fix them?

FFIgen can sometimes generate a lot of logs, especially when it's parsing a lot
of code.
- `SEVERE` logs are something you *definitely need to address*. They can be
  caused due to syntax errors, or more generally missing header files
  (which need to be specified using `compilerOptions` on `Input`).
- `WARNING` logs are something *you can ignore*, but should probably look into.
  These are mostly indications of declarations FFIgen couldn't generate due
  to limitations of `dart:ffi`, private declarations (which can be resolved
  by renaming them via a `Visitor`) or other minor issues.
- Everything else can be safely ignored. Its purpose is to simply let you know
  what FFIgen is doing.
- The verbosity and destination of the logs can be configured by passing a custom
  `Logger` to `generate(logger: logger)`.

## How can type definitions be shared?

FFIgen can share type definitions using symbol files.
- A package can generate a symbol file by configuring `symbolFile` in `Output`:
  ```dart
  Output(
    dart: DartOutput(path: packageRoot.resolve('lib/base.dart')),
    symbolFile: SymbolFile(
      Uri.parse('package:my_pkg/base.dart'),
      packageRoot.resolve('lib/symbols.yaml'),
    ),
  )
  ```
- Another package can then import and reuse those types via `importType`:
  ```dart
  final generator = FfiGenerator(
    // ...
    importType: (declaration) => importFromSymbolFile(symbolFileUri, declaration),
  );
  ```
- Doing so will reuse all the types such as Struct/Unions, and will automatically
  exclude generating other types (e.g. functions, enums, macros).

Check out `example/shared_bindings` for details.

For manually reusing definitions from another package, you can write your own
`importType` function that returns a custom `ImportedType`.
