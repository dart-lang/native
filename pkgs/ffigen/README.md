[![Build Status](https://github.com/dart-lang/native/actions/workflows/ffigen.yml/badge.svg)](https://github.com/dart-lang/native/actions/workflows/ffigen.yml)
[![Coverage Status](https://coveralls.io/repos/github/dart-lang/native/badge.svg?branch=main)](https://coveralls.io/github/dart-lang/native?branch=main)
[![pub package](https://img.shields.io/pub/v/ffigen.svg)](https://pub.dev/packages/ffigen)
[![package publisher](https://img.shields.io/pub/publisher/ffigen.svg)](https://pub.dev/packages/ffigen/publisher)

## Introduction

Bindings generator for [FFI](https://dart.dev/guides/libraries/c-interop) bindings.

> Note: FFIgen only supports parsing `C` headers, not `C++` headers.

This bindings generator can be used to call C code or code in another language
that compiles to C modules that follow the C calling convention, such as Go or 
Rust. For more details, see https://dart.dev/guides/libraries/c-interop.

FFIgen also supports calling ObjC code.
For details see https://dart.dev/guides/libraries/objective-c-interop.

More FFIgen documentation can be found [here](doc/README.md).

## Getting Started

This guide demonstrates how to call a custom C API from a standalone Dart
application. It assumes that Dart has been set up 
([instructions](https://dart.dev/get-dart)) and that LLVM is installed on the
system ([instructions](#requirements)). Furthermore, it assumes that the Dart
app has been created via `dart create ffigen_example`.

1. Add the utility package `package:ffi` as a dependency and the bindings 
   generator `package:ffigen` as a dev_dependency to the pubspec of your app by
   running: `dart pub add ffi dev:ffigen`.

2. Write the C code and place it inside a subdirectory of your app. For this
   example we will place the following code in `src/add.h` and `src/add.c`
   respectively. It defines a simple API to add two integers in C.

   ```C
   // in src/add.h:
   
   int add(int a, int b);
   ```

   ```C
   // in src/add.c:
   
   int add(int a, int b) {
     return a + b;
   }
   ```

3. To generate the bindings, we will write a script using `package:ffigen` and
   place it under `tool/ffigen.dart`. The script instantiates and configures a
   `FfiGenerator`. Refer to the code comments below and the API docs to learn
   more about available configuration options.

   ```dart
   import 'dart:io';

   import 'package:ffigen/ffigen.dart';

   Future<void> main() async {
     final packageRoot = Platform.script.resolve('../');
     final generator = FfiGenerator(
       // Required. Output path for the generated bindings.
       output: Output(
         dart: DartOutput(path: packageRoot.resolve('lib/add.g.dart')),
       ),
       // Optional. Where to look for header files.
       input: Input(entryPoints: [packageRoot.resolve('src/add.h')]),
       // Optional. Transform and filter AST nodes.
       visitors: [
         Visitor(func: (node) => node.isIncluded = node.name == 'add'),
       ],
     );
     await generator.generate();
   }
   ```

4. Run the script with `dart run tool/ffigen.dart` to generate the bindings.
   This will create the output `lib/add.g.dart` file, which can be imported by
   Dart code to access the C APIs. This command must be re-run whenever the
   FFIgen configuration (in `tool/ffigen.dart`) or the C sources for which
   bindings are generated change.

5. Import `add.g.dart` in your Dart app and call the generated methods to access
   the native C API:

   ```dart
   import 'add.g.dart';

   // ...
   
   void answerToLife() {
     print('The answer to the Ultimate Question is ${add(40, 2)}!');
   }
   ```

6. Before we can run the app, we need to compile the C sources. There are many
   ways to do that. For this example, we are using a
   [build hook](https://dart.dev/tools/hooks), which we define in
   `hook/build.dart` as follows. This build hook also requires a dependency
   on the `hooks`, `code_assets`, and `native_toolchain_c` helper packages,
   which we can add to our app by running
   `dart pub add hooks code_assets native_toolchain_c`.

   ```dart
   import 'package:code_assets/code_assets.dart';
   import 'package:hooks/hooks.dart';
   import 'package:native_toolchain_c/native_toolchain_c.dart';
   
   void main(List<String> args) async {
     await build(args, (input, output) async {
       if (input.config.buildCodeAssets) {
         final builder = CBuilder.library(
           name: 'add',
           assetName: 'add.g.dart',
           sources: ['src/add.c'],
         );
         await builder.run(input: input, output: output);
       }
     });
   }
   ```

That's it! Run your app with `dart run` to see it in action!

The complete and runnable example can be found in [example/add](example/add).

## More Examples

The `code_asset` package contains [comprehensive examples](../code_assets/example)
that showcase FFIgen. Additional examples that show how FFIgen can be used
in different scenarios can also be found in the [example](example/) directory.

## Requirements

LLVM (9+) must be installed on your system to use `package:ffigen`. Install it
in the following way:

### Linux

1. Install libclangdev:
   * with apt-get: `sudo apt-get install libclang-dev`.
   * with dnf: `sudo dnf install clang-devel`.

### Windows

1. Install Visual Studio with C++ development support.
2. Install [LLVM](https://releases.llvm.org/download.html) or 
   `winget install -e --id LLVM.LLVM`.

#### macOS

1. Install Xcode.
2. Install Xcode command line tools: `xcode-select --install`.

## Configuration

FFIgen is configured using a Dart script, typically placed under `tool/ffigen.dart` and executed via `dart run tool/ffigen.dart`.

The script instantiates an `FfiGenerator` with your desired configuration and calls `await generator.generate()`.

### Example

```dart
import 'dart:io';

import 'package:ffigen/ffigen.dart';

Future<void> main() async {
  final packageRoot = Platform.script.resolve('../');
  final generator = FfiGenerator(
    // Required. Output path and options for the generated bindings.
    output: Output(
      dart: DartOutput(
        path: packageRoot.resolve('lib/src/generated_bindings.dart'),
      ),
    ),
    // Where to look for header files.
    input: Input(
      entryPoints: [packageRoot.resolve('src/my_header.h')],
    ),
    // Visitors transform and filter AST nodes. By default, all top level APIs
    // are excluded from the bindings. You must explicitly include the APIs
    // you're interested in. Here we include all functions and structs.
    visitors: [
      Visitor(
        func: (node) => node.isIncluded = true,
        struct: (node) => node.isIncluded = true,
      ),
    ],
  );
  await generator.generate();
}
```

Run the script to generate bindings:

```shell
dart run tool/ffigen.dart
```

See the [examples](https://github.com/dart-lang/native/tree/main/pkgs/ffigen/example)
and [API documentation](https://pub.dev/documentation/ffigen/latest/ffigen/)
for more information.
