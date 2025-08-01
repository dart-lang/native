## 20.0.0-wip

- __Breaking change__: Refactor the Dart API a bit, to merge the `FfiGen` and
  `Config` classes. Rename `FfiGen.run` to `.generate`, and make it an extension
  method on the `Config` class. So `FfiGen().run(config)` becomes
  `config.generate(logger)`.
- __Breaking change__: Minor breaking change in the way that ObjC interface
  methods are generated. Interface methods are now generated as extension
  methods instead of being part of the class. This shouldn't require any code
  changes unless you are using `show` or `hide` when importing the interface.
  - If you are using `show`/`hide` to show or hide a particular interface, eg
    `Foo`, you'll now also need to show or hide `Foo$Methods`.
  - In rare cases the runtime type of the Dart wrapper object around the ObjC
    object may change, but the underlying ObjC object will still be the same.
    In any case, you should be using `Foo.isInstance(x)` instead of `x is Foo`
    to check the runtime type of an ObjC object.

## 19.1.0

- Bump minimum Dart version to 3.8.0.
- Format using `dart format` so that the formatter uses the target package's
  Dart version and formatting options.
- Add `_` to the list of Dart keywords, since it has special meaning in newer
  Dart versions.
- Update to the latest lints.

## 19.0.0

- Use package:objective_c 8.0.0.
- __Breaking change__: Major change to the way ObjC methods are code-genned.
  Methods now use named parameters, making them more readable and closer to how
  they're written in ObjC. For example, the `NSData` method
  `dataWithBytes:length:` used to be generated as
  `dataWithBytes_length_(Pointer<Void> bytes, int length)`, but is now generated
  as `dataWithBytes(Pointer<Void> bytes, {required int length})`. Protocol
  methods are not affected.
  - Migration tip: A quick way to find affected methods is to search for `_(`.
- Make it easier for a downstream clone to change behavior of certain utils.
- Fix [a bug](https://github.com/dart-lang/native/issues/1268) where types could
  occasionally show up as a generic ObjCObjectBase, when they were supposed to
  be codegenned as a more specific interface types.

## 18.1.0

- Fix a clang warning in ObjC protocol generated bindings.

## 18.0.0

- Use package:objective_c 7.0.0.
- Add variable substitutions that can be used in the `headers.entry-points` to
  locate Apple APIs: `$XCODE`, `$IOS_SDK`, and `$MACOS_SDK`.
- Add an empty constructor to all ObjC interfaces that have a `new` method,
  which just calls that method.
- __Breaking change__: Change the `usrTypeMappings` field of `Config`'s factory
  constructor from a `List<ImportedType>` to a `Map<String, ImportedType>`.
- Add a `keepIsolateAlive` parameter to the block and protocol constructors that
  allows a block or protocol to keep its owner isolate alive.
- __Breaking change__: `keepIsolateAlive` defaults to true, so all existing ObjC
  blocks and protocols now keep their isolates alive by default.
- Change how protocols are implemented to fix
  [a bug](https://github.com/dart-lang/http/issues/1702), by removing all uses
  of `NSProxy`.
- __Breaking change__: Change how duplicate identifiers are renamed to match
  jnigen. The main change is that `$` is used as a delimiter now, to avoid
  renamed identifiers from colliding with other identifiers. For example, `foo`
  is renamed to `foo$1` if there's already a `foo` in the namespace.
- Fix [a bug](https://github.com/dart-lang/native/issues/1967) where blocking
  blocks could deadlock if invoked from the Flutter UI thread. Note that this
  relies on changes in Flutter that are currently only available in the main
  channel. These changes will likely be released in Flutter 3.31.0.

## 17.0.0

- Use package:objective_c 6.0.0
- Support transitive categories of built-in types:
  https://github.com/dart-lang/native/issues/1820
- __Breaking change__: Maintain protocol conformance when translating from ObjC
  to Dart. For example, ObjC's `id<FooProtocol>` is now translated to Dart's
  `FooProtocol`. Generally this shouldn't be a breaking change for code that is
  using protocols correctly, with a few caveats:
    - For more advanced use cases that use `ObjCProtocolBuilder` directly, after
      calling `build()` you will need to cast the generated object to the target
      protocol: `FooProtocol.castFrom(protocolBuilder.build())`.
    - Due to limitations in the Dart type system, only the first protocol of an
      `id` is used: `id<FooProtocol, BarProtocol>` becomes `FooProtocol`. The
      `FooProtocol.castFrom` method can help work around issues this may cause.
- Fix the handling of global arrays to remove the extra pointer reference.
- Add a `max` field to the `external-versions` config, and use it to determine
  which APIs are generated.
- Add a runtime OS version check to ObjC APIs, which throws an error if the
  current OS version is earlier than the version that the API was introduced.

## 16.1.0

- Ensure that required symbols are available to FFI even when the final binary
  is linked with `-dead_strip`.
- Handle dart typedefs in import/export of symbol files.
- Add support for blocking ObjC blocks that can be invoked from any thread.
- Add support for blocking ObjC protocol methods.
- Remove explicit `objc_retain` calls from the generated bindings.

## 16.0.0

- Ensure all protocols referenced in bindings are available at runtime.
- Use `package:dart_style` directly to format generated Dart code, rather than
  subprocessing to `dart format`.
- Use package:objective_c 4.0.0
- Fix various small bugs todo with config filters:
  - https://github.com/dart-lang/native/issues/1582
  - https://github.com/dart-lang/native/issues/1594
  - https://github.com/dart-lang/native/issues/1595
- Fix [a bug](https://github.com/dart-lang/native/issues/1701) where nullable
  typealiases were treated as non-null.
- Allow static and instance methods to have the same name:
  https://github.com/dart-lang/native/issues/1136
- __Breaking change__: Change the way ObjC categories are generated. Instead of
  inserting their methods into the interface, generate Dart extension methods.
  For instance methods this makes no difference to user code (as long as the
  extension methods are imported correctly). But for static methods it means
  `MyInterface.staticMethod` must change to `MyCategory.staticMethod`.
  Categories are included/excluded by the `objc-categories` config entry.
- Add `include-transitive-objc-interfaces`, `include-transitive-objc-protocols`,
  and `include-transitive-objc-categories` config flags, which control whether
  transitively included ObjC interfaces, protocols, and categories are
  generated.
- __Breaking change__: `include-transitive-objc-interfaces` defaults to false,
  which changes the default behavior from pulling in all transitive deps, to
  generating them as stubs. `include-transitive-objc-protocols` defaults to
  false, and `include-transitive-objc-categories` defaults to true, but these
  both replicate the existing behavior.
- Fix [bugs](https://github.com/dart-lang/native/issues/1220) caused by
  mismatches between ObjC and Dart's inheritance rules.

## 15.0.0

- Bump minimum Dart version to 3.4.
- Dedupe `ObjCBlock` trampolines to reduce generated ObjC code.
- Update to latest `package:objective_c`.
- ObjC objects now include the methods from the protocols they implement. Both
  required and optional methods are included. Optional methods will throw an
  exception if the method isn't implemented.
- __Breaking change__: Only generate ObjC protocol implementation bindings for
  protocols that are included by the config filters. This is breaking because
  previously super protocols would automatically get implementation bindings,
  rather than just being incorporated into the child protocol. If you want those
  implementation bindings, you may need to add the super protocol to your
  `objc-protocols` filters.
- Fix a bug where ObjC listener blocks could be deleted after being invoked by
  ObjC but before the invocation was received by Dart:
  https://github.com/dart-lang/native/issues/1571
- `sort:` config option now affects ObjC interface/protocol methods.
- Fix a bug where `NSRange` was not being imported from package:objective_c:
  https://github.com/dart-lang/native/issues/1180
- __Breaking change__: Return structs from ObjC methods by value instead of
  taking a struct return pointer.

## 14.0.1

- Fix bug with nullable types in `ObjCBlock`'s type arguments:
  https://github.com/dart-lang/native/issues/1537
- Fix a path normalization bug: https://github.com/dart-lang/native/issues/1543

## 14.0.0

- Create a public facing API for ffigen that can be invoked as a library:
  `void generate(Config config)`. Make `Config` an implementatble interface,
  rather than needing to be parsed from yaml.
- Add a `external-versions` config option. Setting the minimum target
  version will omit APIs from the generated bindings if they were deprecated
  before this version.
- Global variables using ObjC types (interfaces or blocks) will now use the
  correct Dart wrapper types, instead of the raw C-style pointers.
- Rename `assetId` under *ffi-native* to `asset-id` to follow dash-case.
- __Breaking change__: ObjC blocks are now passed through all ObjC APIs as
  `ObjCBlock<Ret Function(Args...)>`, instead of the codegenned
  `ObjCBlock_...` wrapper. The wrapper is now a non-constructible set of util
  methods for constructing `ObjCBlock`.
- __Breaking change__: Generated ObjC code has been migrated to ARC (Automatic
  Reference Counting), and must now be compiled with ARC enabled. For example,
  if you had a line like `s.requires_arc = []` in your podspec, this should
  either be removed, or you should add the ffigen generated ObjC code to the
  list. If you're compiling directly with clang, add the `-fobjc-arc` flag.
- __Breaking change__: Structs with enum members now generate their members
  as Dart enum values as well. For example, with an enum `MyEnum` and a struct
  with a member `MyEnum enumMember`, two members are generated: `enumMemberAsInt`
  which contains the original integer value, and `enumMember`, which is of type
  `MyEnum`. If you configure the enum to be generated as Dart integers, this
  new behavior will not apply, and the struct member will be an integer as well.
- __Breaking change__: Enums generated as integers will now generate `sealed`
  classes as opposed to `abstract` classes.
- Fix some bugs in the way ObjC method families and ownership annotations were
  being handled: https://github.com/dart-lang/native/issues/1446
- Apply the existing `member-rename` option to ObjC interface and protocol
  methods and properties.
- Add a `member-filter` option that filters ObjC interface and protocol methods
  and properties.

## 13.0.0

- __Breaking change__: Code-gen the ObjC `id` type to `ObjCObjectBase` rather
  than `NSObject`, since not all ObjC classes inherit from `NSObject`. Eg
  `NSProxy`.
- __Breaking change__: Generate a native trampoline for each listener block, to
  fix a ref counting bug: https://github.com/dart-lang/native/issues/835.
    - If you have listener blocks affected by this ref count bug, a .m file will
      be generated containing the trampoline. You must compile this .m file into
      your package. If you already have a flutter plugin or build.dart, you can
      simply add this generated file to that build.
    - If you don't use listener blocks, you can ignore the .m file.
    - You can choose where the generated .m file is placed with the
      `output.objc-bindings` config option.
- __Breaking change__: Native enums are now generated as real Dart enums, instead
  of abstract classes with integer constants. Native enum members with the same
  integer values are handled properly on the Dart side, and native functions
  that use enums in their signatures now accept the generated enums on the Dart
  side, instead of integer values. To opt out of this, use the `enums->as-int`
  option as specified in the README.
- __Breaking change__: Enum integer types are implementation-defined and not
  part of the ABI. Therefore FFIgen does a best-effort approach trying to mimic
  the most common compilers for the various OS and architecture combinations.
  To silence the warning set config `silence-enum-warning` to `true`.
- Rename ObjC interface methods that clash with type names. Fixes
  https://github.com/dart-lang/native/issues/1007.
- Added support for implementing ObjC protocols from Dart. Use the
  `objc-protocols` config option to generate bindings for a protocol.
- Fix some bugs where ObjC interface/protocol methods could collide with Dart
  built-in methods, or with types declared elsewhere in the generated bindings.
- Add `include-unused-typedefs` to allow generating typedefs that are not
  referred to anywhere, the default option is `false`.
- Use `package:dart_flutter_team_lints`.

## 12.0.0

- Global variables are now compatible with the `ffi-native` option.
- Exposing symbol addresses of functions and globals is now compatible with the
  `ffi-native` option.
- Add `retainAndReturnPointer` method to ObjC objects and blocks, and add
  `castFromPointer` method to blocks.
- Add `-Wno-nullability-completeness` as default compiler option for MacOS.
- __Breaking change__: Use `package:objective_c` in ObjC bindings.
  - ObjC packages will have a flutter dependency (until
    https://github.com/dart-lang/native/issues/1068 is fixed).
  - Core classes such as `NSString` have been moved into `package:objective_c`.
  - ObjC class methods don't need the ubiquitous `lib` argument anymore. In
    fact, ffigen won't even generate the native library class (unless it needs
    to bind top level functions without using `@Native`). It is still necessary
    to `DynamicLibrary.open` the dylib though, to load the classes and methods.
  - Adapting to this change:
    - Update ffigen and re-run the code generation. If the generated code no
      longer contains the native library class, it means it isn't needed
      anymore. So `final lib = FooNativeLib(DynamicLibrary.open('foo.dylib'));`
      must be changed to `DynamicLibrary.open('foo.dylib');`.
    - Regardless of whether the native library class still exists, delete the
      `lib` parameter from all ObjC object constructors and static method calls
      and block constructors.
    - If core ObjC classes such as `NSString` are being used,
      `package:objective_c` must be imported, as they won't be exported by the
      generated bindings.
- Add --[no-]format option to ffigen command line, which controls whether the
  formatting step happens. Defaults to true.
- Delete Dart functions associated with ObjC closure blocks when the block is
  destroyed. Fixes https://github.com/dart-lang/native/issues/204
- Reduce cursor definition not found logs when `structs/unions` ->
  `dependency-only` is set to `opaque`.

## 11.0.0

- Any compiler errors/warnings in source header files will now result in
bindings to **not** be generated by default, since it may result in invalid
bindings if the compiler makes a wrong guess. A flag `--ignore-source-errors` (or yaml config `ignore-source-errors: true`)
must be passed to change this behaviour.
- __Breaking change__: Stop generating setters for global variables marked `const` in C.
- Fix objc_msgSend being used on arm64 platforms where it's not available.
- Fix missing comma with `ffi-native` functions marked `leaf`.
- Add support for finding libclang in Conda environment.

## 10.0.0

- Stable release targeting Dart 3.2 using new `dart:ffi` features available
  in Dart 3.2 and later.
- Add support for ObjC Blocks that can be invoked from any thread, using
  NativeCallable.listener.
- Fix invalid exceptional return value ObjCBlocks that return floats.
- Fix return_of_invalid_type analysis error for ObjCBlocks.
- Fix crash in ObjC methods and blocks that return structs by value.
- Fix ObjC methods returning instancetype having the wrong type in sublasses.
- When generating typedefs for `Pointer<NativeFunction<Function>>`, also
  generate a typedef for the `Function`.
- Use Dart wrapper types in args and returns of ObjCBlocks.
- Use Dart wrapper types in args and returns of static functions.
- Renamed `asset` to `assetId` for `ffi-native`.

## 9.0.1

- Fix doc comment missing on struct/union array fields.
- Allow extern inline functions to be generated.

## 9.0.0

- Added a JSON schema for FFIgen config files.

## 8.0.2

- Fixed invalid code generated due to zero-length arrays in structs/union.

## 8.0.1

- Fixed invalid code generated due to anonymous structs/unions with unsupported types.

## 8.0.0

- Stable release for Dart 3.0 with support for class modifers, variadic arguments, and `@Native`s.

## 8.0.0-dev.3

- Added support for variadic functions using config `functions -> variadic-arguments`.

## 8.0.0-dev.2

- Use `@Native` syntax instead of deprecated `@FfiNative` syntax.


## 8.0.0-dev.1

- Fix invalid struct/enum member references due to multiple anonymous struct/enum in a declaration.

## 8.0.0-dev.0

- Adds `final` class modifier to generated sub types `Struct`, `Union` and
  `Opaque`. A class modifier is required in Dart 3.0 because the classes
  `dart:ffi` as marked `base`.
  When migrating a package that uses FFIgen, _and_ exposes the generated code in
  the public API of the package, to Dart 3.0, that package does not
  need a major version bump. Sub typing `Struct`, `Union` and
  `Opaque` sub types is already disallowed by `dart:ffi` pre 3.0, so adding the
  `final` keyword is not a breaking change.
- Bumps SDK lowerbound to 3.0.
## 7.2.11

- Fix invalid struct/enum member references due to multiple anonymous struct/enum in a declaration.

## 7.2.10

- Generate parameter names in function pointer fields and typedefs.

## 7.2.9

- Detect LLVM installed using Scoop on Windows machines.

## 7.2.8

- Automatically generate `ignore_for_file: type=lint` if not specified in preamble.

## 7.2.7

- Fix some macros not being generated in some cases due to relative header paths.

## 7.2.6

- Fix path normalization behaviour for absolute paths and globs starting with `**`.

## 7.2.5

- Add support nested anonymous union/struct

## 7.2.4

- Add new supported typedef - `uintptr_t` (mapped to `ffi.UintPtr`).

## 7.2.3

- Change compiler option order so that user options can override built-in
  options.

## 7.2.2

- Added newer versions of LLVM, to default `linuxDylibLocations`.

## 7.2.1

- Fix helper methods sometimes missing from NSString.

## 7.2.0

- Added support for sharing bindings using `symbol-file` config. (See `README.md`
and examples/shared_bindings).

## 7.1.0

- Handle declarations with definition accessible from a different entry-point.

## 7.0.0

- Fix typedef include/exclude config.
- Return `ObjCBlock` wrapper instead of raw pointer in more cases.

## 7.0.0-dev

- Relative paths in ffigen config files are now assumed to be relative to the
  config file, rather than the working directory of the tool invocation.

## 6.1.2

- Fix bug where function bindings were not deduped correctly.

## 6.1.1

- _EXPERIMENTAL_ support for `FfiNative`. The API and output
  might change at any point.

## 6.1.0

- Added `exclude-all-by-default` config flag, which changes the default behavior
  of declaration filters to exclude everything, rather than include everything.

## 6.0.2

- Bump `package:ffi` to 2.0.1.

## 6.0.1

- Replace path separators in `include-directives` before matching file names.
- Add more ways to find `libclang`.

## 6.0.0
- Removed config `dart-bool`. Booleans are now always generated with `bool`
and `ffi.Bool` as it's Dart and C Type respectively.

## 5.0.1

- Add a the xcode tools llvm as default path on MacOS.

## 5.0.0

- Stable release targeting Dart 2.17, supporting ABI-specific integer types.
- _EXPERIMENTAL_ support for ObjectiveC on MacOS hosts. The API and output
  might change at any point. Feel free to report bugs if encountered.

## 5.0.0-dev.1
- Fixed invalid default dart types being generated for `size_t` and `wchar_t`.

## 5.0.0-dev.0
- Added support for generating ABI Specific integers.
- Breaking: removed config keys - `size-map` and `typedef-map`.
- Added config keys - `library-imports` and `type-map`.

## 4.1.3
- Analyzer fixes.

## 4.1.2
- Added fix for empty include list to exclude all

## 4.1.1
- Added fix for errors due to name collision between member name
and type name used internally in structs/unions.

## 4.1.0
- Add config key `functions -> leaf` for specifying `isLeaf:true` for functions.

## 4.0.0
- Release for Dart SDK `>=2.14`.

## 4.0.0-dev.2
- Added config key `functions -> expose-typedefs` to expose the typedef
to Native and Dart type.
- Config key `function`->`symbol-address` no longer exposes the typedef
to Native type. Use `expose-typedefs` to get the native type.

## 4.0.0-dev.1
- This package now targets package:lints for the generated code. The generated
code uses C symbol names as is. Use either `// ignore_for_file: lintRule1, lintRule2`
in the `preamble`, or rename the symbols to make package:lints happy.
- Name collisions are now resolved by suffixing `<int>` instead of `_<int>`.

## 4.0.0-dev.0
- Added support for generating typedefs (_referred_ typedefs only).
<table>
<tr>
<td>Example C Code</td>
<td>Generated Dart typedef</td>
</tr>
<tr>
<td>

```C++
typedef struct A{
    ...
} TA, *PA;

TA func(PA ptr);
```
</td>
<td>

```dart
class A extends ffi.Struct {...}
typedef TA = A;
typedef PA = ffi.Pointer<A>;
TA func(PA ptr){...}
```
</td>
</tr>
</table>

- All declarations that are excluded by the user are now only included if being
used somewhere.
- Improved struct/union include/exclude. These declarations can now be targetted
by their actual name, or if they are unnamed then by the name of the first
typedef that refers to them.

## 3.1.0-dev.1
- Users can now specify exact path to dynamic library in `llvm-path`.

## 3.1.0-dev.0
- Added support for generating unions.

## 3.0.0
- Release for dart sdk `>=2.13` (Support for packed structs and inline arrays).

## 3.0.0-beta.0
- Added support for inline arrays in `Struct`s.
- Remove config key `array-workaround`.
- Remove deprecated key `llvm-lib` from config, Use `llvm-path` instead.

## 2.5.0-beta.1
- Added support for `Packed` structs. Packed annotations are generated
automatically but can be overriden using `structs -> pack` config.
- Updated sdk constraints to `>=2.13.0-211.6.beta`.

## 2.4.2
- Fix issues due to declarations having duplicate names.
- Fix name conflict of declaration with ffi library prefix.
- Fix `char` not being recognized on platforms where it's unsigned by default.

## 2.4.1
- Added `/usr/lib` to default dynamic library location for linux.

## 2.4.0
- Added new config key `llvm-path` that accepts a list of `path/to/llvm`.
- Deprecated config key `llvm-lib`.

## 2.3.0
- Added config key `compiler-opts-automatic -> macos -> include-c-standard-library`
(default: true) to automatically find and add C standard library on macOS.
- Allow passing list of string to config key `compiler-opts`.

## 2.2.5
- Added new command line flag `--compiler-opts` to the command line tool.

## 2.2.4
- Fix `sort: true` not working.
- Fix extra `//` or `///` in comments when using `comments -> style`: `full`.

## 2.2.3
- Added new subkey `dependency-only` (options - `full (default) | opaque`) under `structs`.
When set to `opaque`, ffigen will generate empty `Opaque` structs if structs
were excluded in config (i.e added because they were a dependency) and
only passed by reference(pointer).

## 2.2.2
- Fixed generation of empty opaque structs due to forward declarations in header files.

## 2.2.1
- Fixed generation of duplicate constants suffixed with `_<int>` when using multiple entry points.

## 2.2.0
- Added subkey `symbol-address` to expose native symbol pointers for `functions` and `globals`.

## 2.1.0
- Added a new named constructor `NativeLibrary.fromLookup()` to support dynamic linking.
- Updated dart SDK constraints to latest stable version `2.12.0`.

## 2.0.3
- Ignore typedef to struct pointer when possible.
- Recursively create directories for output file.

## 2.0.2
- Fixed illegal use of `const` in name, crash due to unnamed inline structs and
structs having `Opaque` members.

## 2.0.1
- Switch to preview release of `package:quiver`.

## 2.0.0
- Upgraded all dependencies. `package:ffigen` now runs with sound null safety.

## 2.0.0-dev.6
- Functions marked `inline` are now skipped.

## 2.0.0-dev.5
- Use `Opaque` for representing empty `Struct`s.

## 2.0.0-dev.4
- Add support for parsing and generating globals.

## 2.0.0-dev.3
- Removed the usage of `--no-sound-null-safety` flag.

## 2.0.0-dev.2
- Removed setup phase for ffigen. Added new optional config key `llvm-lib`
to specify path to `llvm/lib` folder.

## 2.0.0-dev.1
- Added support for passing and returning struct by value in functions.

## 2.0.0-dev.0
- Added support for Nested structs.

## 2.0.0-nullsafety.1
- Removed the need for `--no-sound-null-safety` flag.

## 2.0.0-nullsafety.0
- Migrated to (unsound) null safety.

## 1.2.0
- Added support for `Dart_Handle` from `dart_api.h`.

## 1.1.0
- `typedef-map` can now be used to map a typedef name to a native type directly.

## 1.0.6
- Fixed missing typedefs nested in another typedef's return types.

## 1.0.5
- Fixed issues with generating macros of type `double.Infinity` and `double.NaN`.

## 1.0.4
- Updated code to use `dart format` instead of `dartfmt` for sdk version `>= 2.10.0`.

## 1.0.3
- Fixed errors due to extended ASCII and control characters in macro strings.

## 1.0.2
- Fix indentation for pub's readme.

## 1.0.1
- Fixed generation of `NativeFunction` parameters instead of `Pointer<NativeFunction>` in type signatures.

## 1.0.0
- Bump version to 1.0.0.
- Handle unimplememnted function pointers causing errors.
- Log lexical/semantic issues in headers as SEVERE.

## 0.3.0
- Added support for including/excluding/renaming _un-named enums_ using key `unnamed_enums`.

## 0.2.4+1
- Minor changes to dylib creation error log.

## 0.2.4
- Added support for C booleans as Uint8.
- Added config `dart-bool` (default: true) to use dart bool instead of int in function parameters and return type.

## 0.2.3+3
- Wrapper dynamic library version now uses ffigen version from its pubspec.yaml file.

## 0.2.3+2
- Handle code formatting using dartfmt by finding dart-sdk.

## 0.2.3+1
- Fixed missing typedefs of nested function pointers.

## 0.2.3
- Fixed parsing structs with bitfields, all members of structs with bit field members will now be removed. See [#84](https://github.com/dart-lang/ffigen/issues/84)

## 0.2.2+1
- Updated `package:meta` version to `^1.1.8` for compatibility with flutter sdk.

## 0.2.2
- Fixed multiple generation/skipping of typedef enclosed declarations.
- Typedef names are now given higher preference over inner names, See [#83](https://github.com/dart-lang/ffigen/pull/83).

## 0.2.1+1
- Added FAQ to readme.

## 0.2.1
- Fixed missing/duplicate typedef generation.

## 0.2.0
- Updated header config. Header `entry-points` and `include-directives` are now specified under `headers` key. Glob syntax is allowed.
- Updated declaration `include`/`exclude` config. These are now specified as a list.
- Added Regexp based declaration renaming using `rename` subkey.
- Added Regexp based member renaming for structs, enums and functions using `member-rename` subkey. `prefix` and `prefix-replacement` subkeys have been removed.

## 0.1.5
- Added support for parsing macros and anonymous unnamed enums. These are generated as top level constants.

## 0.1.4
- Comments config now has a style and length sub keys - `style: doxygen(default) | any`, `length: brief | full(default)`, and can be disabled by passing `comments: false`.

## 0.1.3
- Handled function arguments - dart keyword name collision
- Fix travis tests: the dynamic library is created using `pub run ffigen:setup` before running the tests.

## 0.1.2
- Fixed wrapper not found error when running `pub run ffigen`.

## 0.1.1
- Address pub score: follow dart File conventions, provide documentation, and pass static analysis.

## 0.1.0
- Support for Functions, Structs and Enums.
- Glob support for specifying headers.
- HeaderFilter - Include/Exclude declarations from specific header files using name matching.
- Filters - Include/Exclude function, structs and enum declarations using Regexp or Name matching.
- Prefixing - function, structs and enums can have a global prefix. Individual prefix Replacement support using Regexp.
- Comment extraction: full/brief/none
- Support for fixed size arrays in struct. `array-workaround` (if enabled) will generate helpers for accessing fixed size arrays in structs.
- Size for ints can be specified using `size-map` in config.
- Options to disable using supported typedefs (e.g `uint8_t => Uint8`), sort bindings.
- Option to add a raw `preamble` which is included as is in the generated file.
