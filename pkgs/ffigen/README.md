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
   
   void main() {
     final packageRoot = Platform.script.resolve('../');
     FfiGenerator(
       // Required. Output path for the generated bindings.
       output: Output(dartFile: packageRoot.resolve('lib/add.g.dart')),
       // Optional. Where to look for header files.
       headers: Headers(entryPoints: [packageRoot.resolve('src/add.h')]),
       // Optional. What functions to generate bindings for.
       functions: Functions.includeSet({'add'}),
     ).generate();
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

## YAML Configuration Reference

In addition to the Dart API shown in the "Getting Started" section, FFIgen can
also be configured via YAML. Support for the YAML configuration will be
eventually phased out, and using the Dart API is recommended.

A YAML configuration can be either provided in the project's `pubspec.yaml` file
under the key `ffigen` or via a custom YAML file. To generate bindings
configured via YAML run either `dart run ffigen` if using the `pubspec.yaml`
file or run `dart run ffigen --config config.yaml` where `config.yaml` is the
path to your custom YAML file.

The following configuration options are available:

<table>
<thead>
  <tr>
    <th>Key</th>
    <th>Explanation</th>
    <th>Example</th>
  </tr>
  <colgroup>
      <col>
      <col style="width: 100px;">
  </colgroup>
</thead>
<tbody>
  <tr>
    <td>output<br><i><b>(Required)</b></i></td>
    <td>Output path of the generated bindings.</td>
    <td>

```yaml
output: 'generated_bindings.dart'
```
or
```yaml
output:
  bindings: 'generated_bindings.dart'
  ...
```
  </td>
  </tr>
  <tr>
    <td>llvm-path</td>
    <td>Path to <i>llvm</i> folder.<br> FFIgen will sequentially search
    for `lib/libclang.so` on linux, `lib/libclang.dylib` on macOS and
    `bin\libclang.dll` on windows, in the specified paths.<br><br>
    Complete path to the dynamic library can also be supplied.<br>
    <i>Required</i> if FFIgen is unable to find this at default locations.</td>
    <td>

```yaml
llvm-path:
  - '/usr/local/opt/llvm'
  - 'C:\Program Files\llvm`
  - '/usr/lib/llvm-11'
  # Specify exact path to dylib
  - '/usr/lib64/libclang.so'
```
  </td>
  </tr>
  <tr>
    <td>headers<br><i><b>(Required)</b></i></td>
    <td>The header entry-points and include-directives. Glob syntax is allowed.<br>
    If include-directives are not specified FFIgen will generate everything directly/transitively under the entry-points.</td>
    <td>

```yaml
headers:
  entry-points:
    - 'folder/**.h'
    - 'folder/specific_header.h'
  include-directives:
    - '**index.h'
    - '**/clang-c/**'
    - '/full/path/to/a/header.h'
```
  </td>
  </tr>
  <tr>
    <td>name<br><i>(Prefer)</i></td>
    <td>Name of generated class.</td>
    <td>

```yaml
name: 'SQLite'
```
  </td>
  </tr>
  <tr>
    <td>description<br><i>(Prefer)</i></td>
    <td>Dart Doc for generated class.</td>
    <td>

```yaml
description: 'Bindings to SQLite'
```
  </td>
  </tr>
  <tr>
    <td>compiler-opts</td>
    <td>Pass compiler options to clang. You can also pass
    these via the command line tool.</td>
    <td>

```yaml
compiler-opts:
  - '-I/usr/lib/llvm-9/include/'
```
and/or via the command line -
```bash
dart run ffigen --compiler-opts "-I/headers
-L 'path/to/folder name/file'"
```
  </td>
  </tr>
    <tr>
    <td>compiler-opts-automatic.macos.include-c-standard-library</td>
    <td>Tries to automatically find and add C standard library path to
    compiler-opts on macOS.<br>
    <b>Default: true</b>
    </td>
    <td>

```yaml
compiler-opts-automatic:
  macos:
    include-c-standard-library: false
```
  </td>
  </tr>
  <tr>
    <td>
      functions<br><br>structs<br><br>unions<br><br>enums<br><br>
      unnamed-enums<br><br>macros<br><br>globals
    </td>
    <td>Filters for declarations.<br><b>Default: all are included.</b><br><br>
    Options -<br>
    - Include/Exclude declarations.<br>
    - Rename declarations.<br>
    - Rename enum, struct, and union members, function parameters, and ObjC
      interface and protocol methods and properties.<br>
    - Expose symbol-address for functions and globals.<br>
    </td>
    <td>

```yaml
functions:
  include: # 'exclude' is also available.
    # Matches using regexp.
    - [a-z][a-zA-Z0-9]*
    # '.' matches any character.
    - prefix.*
    # Matches with exact name
    - someFuncName
    # Full names have higher priority.
    - anotherName
  rename:
    # Regexp groups based replacement.
    'clang_(.*)': '$1'
    'clang_dispose': 'dispose'
    # Removes '_' from beginning.
    '_(.*)': '$1'
  symbol-address:
    # Used to expose symbol address.
    include:
      - myFunc
structs:
  rename:
    # Removes prefix underscores
    # from all structures.
    '_(.*)': '$1'
  member-rename:
    '.*': # Matches any struct.
      # Removes prefix underscores
      # from members.
      '_(.*)': '$1'
enums:
  rename:
    # Regexp groups based replacement.
    'CXType_(.*)': '$1'
  member-rename:
    '(.*)': # Matches any enum.
      # Removes '_' from beginning
      # enum member name.
      '_(.*)': '$1'
    # Full names have higher priority.
    'CXTypeKind':
      # $1 keeps only the 1st
      # group i.e only '(.*)'.
      'CXType(.*)': '$1'
  as-int:
    # These enums will be generated as Dart integers instead of Dart enums
    include:
      - MyIntegerEnum
globals:
  exclude:
    - aGlobal
  rename:
    # Removes '_' from
    # beginning of a name.
    '_(.*)': '$1'
```
  </td>
  </tr>
  <tr>
    <td>typedefs</td>
    <td>Filters for referred typedefs.<br><br>
    Options -<br>
    - Include/Exclude (referred typedefs only).<br>
    - Rename typedefs.<br><br>
    Note: By default, typedefs that are not referred to anywhere will not be generated.
    </td>
    <td>

```yaml
typedefs:
  exclude:
    # Typedefs starting with `p` are not generated.
    - 'p.*'
  rename:
    # Removes '_' from beginning of a typedef.
    '_(.*)': '$1'
```
  </td>
  </tr>
  <tr>
    <td>include-unused-typedefs</td>
    <td>
      Also generate typedefs that are not referred to anywhere.
      <br>
      <b>Default: false</b>
    </td>
    <td>

```yaml
include-unused-typedefs: true
```
  </td>
  </tr>
  <tr>
    <td>functions.expose-typedefs</td>
    <td>Generate the typedefs to Native and Dart type of a function<br>
    <b>Default: Inline types are used and no typedefs to Native/Dart
    type are generated.</b>
    </td>
    <td>

```yaml
functions:
  expose-typedefs:
    include:
      # Match function name.
      - 'myFunc'
       # Do this to expose types for all function.
      - '.*'
    exclude:
      # If you only use exclude, then everything
      # not excluded is generated.
      - 'dispose'
```
  </td>
  </tr>
  <tr>
    <td>functions.leaf</td>
    <td>Set isLeaf:true for functions.<br>
    <b>Default: all functions are excluded.</b>
    </td>
    <td>

```yaml
functions:
  leaf:
    include:
      # Match function name.
      - 'myFunc'
       # Do this to set isLeaf:true for all functions.
      - '.*'
    exclude:
      # If you only use exclude, then everything
      # not excluded is generated.
      - 'dispose'
```
  </td>
  </tr>
  <tr>
    <td>functions.variadic-arguments</td>
    <td>Generate multiple functions with different variadic arguments.<br>
    <b>Default: var args for any function are ignored.</b>
    </td>
    <td>

```yaml
functions:
  variadic-arguments:
    myfunc:
      // Native C types are supported
      - [int, unsigned char, long*, float**]
      // Common C typedefs (stddef.h) are supported too
      - [uint8_t, intptr_t, size_t, wchar_t*]
      // Structs/Unions/Typedefs from generated code or a library import can be referred too.
      - [MyStruct*, my_custom_lib.CustomUnion]
```
  </td>
  </tr>
  <tr>
    <td>structs.pack</td>
    <td>Override the @Packed(X) annotation for generated structs.<br><br>
    <i>Options - none, 1, 2, 4, 8, 16</i><br>
    You can use RegExp to match with the <b>generated</b> names.<br><br>
    Note: Ffigen can only reliably identify packing specified using
    __attribute__((__packed__)). However, structs packed using
    `#pragma pack(...)` or any other way could <i>potentially</i> be incorrect
    in which case you can override the generated annotations.
    </td>
    <td>

```yaml
structs:
  pack:
    # Matches with the generated name.
    'NoPackStruct': none # No packing
    '.*': 1 # Pack all structs with value 1
```
  </td>
  </tr>
  <tr>
    <td>comments</td>
    <td>Extract documentation comments for declarations.<br>
    The style and length of the comments recognized can be specified with the following options- <br>
    <i>style: doxygen(default) | any </i><br>
    <i>length: brief | full(default) </i><br>
    If you want to disable all comments you can also pass<br>
    comments: false.
    </td>
    <td>

```yaml
comments:
  style: any
  length: full
```
  </td>
  </tr>
  <tr>
    <td>structs.dependency-only<br><br>
        unions.dependency-only
    </td>
    <td>If `opaque`, generates empty `Opaque` structs/unions if they
were not included in config (but were added since they are a dependency) and
only passed by reference(pointer).<br>
    <i>Options - full(default) | opaque</i><br>
    </td>
    <td>

```yaml
structs:
  dependency-only: opaque
unions:
  dependency-only: opaque
```
  </td>
  </tr>
  <tr>
    <td>sort</td>
    <td>Sort the bindings according to name.<br>
      <b>Default: false</b>, i.e keep the order as in the source files.
    </td>
    <td>

```yaml
sort: true
```
  </td>
  </tr>
  <tr>
    <td>use-supported-typedefs</td>
    <td>Should automatically map typedefs, E.g uint8_t => Uint8, int16_t => Int16, size_t => Size etc.<br>
    <b>Default: true</b>
    </td>
    <td>

```yaml
use-supported-typedefs: true
```
  </td>
  </tr>
  <tr>
    <td>use-dart-handle</td>
    <td>Should map `Dart_Handle` to `Handle`.<br>
    <b>Default: true</b>
    </td>
    <td>

```yaml
use-dart-handle: true
```

  </td>
  </tr>
  <tr>
    <td>ignore-source-errors</td>
    <td>Where to ignore compiler warnings/errors in source header files.<br>
    <b>Default: false</b>
    </td>
    <td>

```yaml
ignore-source-errors: true
```
and/or via the command line -
```bash
dart run ffigen --ignore-source-errors
```
  </td>
  </tr>
  <tr>
    <td>silence-enum-warning</td>
    <td>Where to silence warning for enum integer type mimicking.<br>
    The integer type used for enums is implementation-defined, and not part of
    the ABI. FFIgen tries to mimic the integer sizes chosen by the most common
    compilers for the various OS and architecture combinations.<br>
    <b>Default: false</b>
    </td>
    <td>

```yaml
silence-enum-warning: true
```
  </td>
  </tr>
  <tr>
    <td>exclude-all-by-default</td>
    <td>
      When a declaration filter (eg `functions:` or `structs:`) is empty or
      unset, it defaults to including everything. If this flag is enabled, the
      default behavior is to exclude everything instead.<br>
      <b>Default: false</b>
    </td>
    <td>

```yaml
exclude-all-by-default: true
```
  </td>
  </tr>
  <tr>
    <td>preamble</td>
    <td>Raw header of the file, pasted as-it-is.</td>
    <td>

```yaml
preamble: |
  // ignore_for_file: camel_case_types, non_constant_identifier_names
```
</td>
  </tr>
  <tr>
    <td>library-imports</td>
    <td>Specify library imports for use in type-map.<br><br>
    Note: ffi (dart:ffi) is already available as a predefined import.
    </td>
    <td>

```yaml
library-imports:
  custom_lib: 'package:some_pkg/some_file.dart'
```
  </td>
  </tr>
  <tr>
    <td>type-map</td>
    <td>Map types like integers, typedefs, structs,  unions to any other type.<br><br>
    <b>Sub-fields</b> - <i>typedefs</i>, <i>structs</i>, <i>unions</i>, <i>ints</i><br><br>
    <b><i>lib</i></b> must be specified in <i>library-imports</i> or be one of a predefined import.
    </td>
    <td>

```yaml
type-map:
  'native-types': # Targets native types.
    'char':
      'lib': 'pkg_ffi' # predefined import.
      'c-type': 'Char'
      # For native-types dart-type can be be int, double or float
      # but same otherwise.
      'dart-type': 'int'
    'int':
      'lib': 'custom_lib'
      'c-type': 'CustomType4'
      'dart-type': 'int'
  'typedefs': # Targets typedefs.
    'my_type1':
      'lib': 'custom_lib'
      'c-type': 'CustomType'
      'dart-type': 'CustomType'
  'structs': # Targets structs.
    'my_type2':
      'lib': 'custom_lib'
      'c-type': 'CustomType2'
      'dart-type': 'CustomType2'
  'unions': # Targets unions.
    'my_type3':
      'lib': 'custom_lib'
      'c-type': 'CustomType3'
      'dart-type': 'CustomType3'
```
  </td>
  </tr>
  <tr>
    <td>ffi-native</td>
    <td>
      <b>WARNING:</b> Native support is EXPERIMENTAL. The API may change
      in a breaking way without notice.
      <br><br>
      Generate `@Native` bindings instead of bindings using `DynamicLibrary` or `lookup`.
    </td>
    <td>

```yaml
ffi-native:
  asset-id: 'package:some_pkg/asset' # Optional, was assetId in previous versions
```
  </td>
  </tr>
  <tr>
    <td>language</td>
    <td>
      <b>WARNING:</b> Other language support is EXPERIMENTAL. The API may change
      in a breaking way without notice.
      <br><br>
      Choose the input language. Must be one of 'c', or 'objc'. Defaults to 'c'.
    </td>
    <td>

```yaml
language: 'objc'
```
  </td>
  </tr>
  <tr>
    <td>output.objc-bindings</td>
    <td>
      Choose where the generated ObjC code (if any) is placed. The default path
      is `'${output.bindings}.m'`, so if your Dart bindings are in
      `generated_bindings.dart`, your ObjC code will be in
      `generated_bindings.dart.m`.
      <br><br>
      This ObjC file will only be generated if it's needed. If it is generated,
      it must be compiled into your package, as part of a flutter plugin or
      build.dart script. If your package already has some sort of native build,
      you can simply add this generated ObjC file to that build.
    </td>
    <td>

```yaml
output:
  ...
  objc-bindings: 'generated_bindings.m'
```
</td>
  </tr>
  <tr>
    <td>output.symbol-file</td>
    <td>Generates a symbol file yaml containing all types defined in the generated output.</td>
    <td>

```yaml
output:
  ...
  symbol-file:
    # Although file paths are supported here, prefer Package Uri's here
    # so that other pacakges can use them.
    output: 'package:some_pkg/symbols.yaml'
    import-path: 'package:some_pkg/base.dart'
```
</td>
  </tr>
  <tr>
    <td>import.symbol-files</td>
    <td>Import symbols from a symbol file. Used for sharing type definitions from other pacakges.</td>
    <td>

```yaml
import:
  symbol-files:
    # Both package Uri and file paths are supported here.
    - 'package:some_pkg/symbols.yaml'
    - 'path/to/some/symbol_file.yaml'
```
  </td>
  </tr>

  <tr>
    <td>
      external-versions
    </td>
    <td>
      Interfaces, methods, and other API elements may be marked with
      deprecation annotations that indicate which platform version they were
      deprecated in. If external-versions is set, APIs that were
      deprecated as of the minimum version will be omitted from the
      generated bindings.
      <br><br>
      The minimum version is specified per platform, and an API will be
      generated if it is available on *any* of the targeted platform versions.
      If a version is not specified for a particular platform, the API's
      inclusion will be based purely on the platforms that have a specified
      minimum version.
      <br><br>
      Current support OS keys are ios and macos. If you have a use case for
      version checking on other OSs, please file an issue.
    </td>
    <td>

```yaml
external-versions:
  # See https://docs.flutter.dev/reference/supported-platforms.
  ios:
    min: 12.0.0
  macos:
    min: 10.14.0
```

  </td>
  </tr>
</tbody>
</table>

### Objective-C configuration options

<table>
<thead>
  <tr>
    <th>Key</th>
    <th>Explanation</th>
    <th>Example</th>
  </tr>
  <colgroup>
    <col>
    <col style="width: 100px;">
  </colgroup>
</thead>
<tbody>
  <tr>
    <td>
      objc-interfaces<br><br>
      objc-protocols<br><br>
      objc-categories
    </td>
    <td>
      Filters for Objective-C interface, protocol, and category declarations.
      This option works the same as other declaration filters like `functions`
      and `structs`.
    </td>
    <td>

```yaml
objc-interfaces:
  include:
    # Includes a specific interface.
    - 'MyInterface'
    # Includes all interfaces starting with "NS".
    - 'NS.*'
  exclude:
    # Override the above NS.* inclusion, to exclude NSURL.
    - 'NSURL'
  rename:
    # Removes '_' prefix from interface names.
    '_(.*)': '$1'
objc-protocols:
  include:
    # Generates bindings for a specific protocol.
    - MyProtocol
objc-categories:
  include:
    # Generates bindings for a specific category.
    - MyCategory
```

  </td>
  </tr>

  <tr>
    <td>
      objc-interfaces.module<br><br>
      objc-protocols.module
    </td>
    <td>
      Adds a module prefix to the interface/protocol name when loading it
      from the dylib. This is only relevant for ObjC headers that are generated
      wrappers for a Swift library. See example/swift for more information.
      <br><br>
      This is not necessary for objc-categories.
    </td>
    <td>

```yaml
headers:
  entry-points:
    # Generated by swiftc to wrap foo_lib.swift.
    - 'foo_lib-Swift.h'
objc-interfaces:
  include:
    # Eg, foo_lib contains a set of classes prefixed with FL.
    - 'FL.*'
  module:
    # Use 'foo_lib' as the module name for all the FL.* classes.
    # We don't match .* here because other classes like NSString
    # shouldn't be given a module prefix.
    'FL.*': 'foo_lib'
```

  </td>
  </tr>

  <tr>
    <td>
      objc-interfaces.member-filter<br><br>
      objc-protocols.member-filter<br><br>
      objc-categories.member-filter
    </td>
    <td>
      Filters interface and protocol methods and properties. This is a map from
      interface name to a list of method include and exclude rules. The
      interface name can be a regexp. The include and exclude rules work exactly
      like any other declaration. See
      <a href="#how-does-objc-method-filtering-work">below</a> for more details.
    </td>
    <td>

```yaml
objc-interfaces:
  member-filter:
    MyInterface:
      include:
        - "someMethod:withArg:"
      # Since MyInterface has an include rule, all other methods
      # are excluded by default.
objc-protocols:
  member-filter:
    NS.*:  # Matches all protocols starting with NS.
      exclude:
        - copy.*  # Remove all copy methods from these protocols.
objc-categories:
  member-filter:
    MyCategory:
      include:
        - init.*  # Include all init methods.
```

  </td>
  </tr>

  <tr>
    <td>
      include-transitive-objc-interfaces<br><br>
      include-transitive-objc-protocols
    </td>
    <td>
      By default, Objective-C interfaces and protocols that are not directly
      included by the inclusion rules, but are transitively depended on by
      the inclusions, are not fully code genned. Transitively included
      interfaces are generated as stubs, and transitive protocols are omitted.
      <br><br>
      If these flags are enabled, transitively included interfaces and protocols
      are fully code genned.
      <br><br>
      <b>Default: false</b>
    </td>
    <td>

```yaml
include-transitive-objc-interfaces: true
include-transitive-objc-protocols: true
```
  </td>
  </tr>

  <tr>
    <td>
      include-transitive-objc-categories
    </td>
    <td>
      By default, if an Objective-C interface is included in the bindings, all
      the categories that extend it are also included. To filter them, set this
      flag to false, then use objc-categories to include/exclude particular
      categories.
      <br><br>
      Transitive categories are generated by default because it's not always
      obvious from the Apple documentation which interface methods are declared
      directly in the interface, and which are declared in categories. So it may
      appear that the interface is missing methods, when in fact those methods
      are part of a category. This would be a difficult problem to diagnose if
      transitive categories were not generated by default.
      <br><br>
      <b>Default: true</b>
    </td>
    <td>

```yaml
include-transitive-objc-categories: false
```
  </td>
  </tr>
</tbody>
</table>
