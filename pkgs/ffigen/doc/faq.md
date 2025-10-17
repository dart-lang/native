# FAQ

## Can FFIgen be used for removing underscores or renaming declarations?

FFIgen supports **regexp-based renaming**. The regexp must be a full match.
For renaming you can use regexp groups (`$1` means group 1).

To renaming `clang_dispose_string` to `string_dispose` we can match it using
`clang_(.*)_(.*)` and rename with `$2_$1`.

Here's an example of how to remove prefix underscores from any struct and its
members.

```yaml
structs:
  ...
  rename:
    '_(.*)': '$1' # Removes prefix underscores from all structures.
  member-rename:
    '.*': # Matches any struct.
      '_(.*)': '$1' # Removes prefix underscores from members.
```
## How to generate declarations only from particular headers?

The default behavior is to include everything directly/transitively under
each of the `entry-points` specified.

If you only want to have declarations directly particular header you can do so
using `include-directives`. You can use **glob matching** to match header paths.

```yaml
headers:
  entry-points:
    - 'path/to/my_header.h'
  include-directives:
    - '**my_header.h' # This glob pattern matches the header path.
```
## Can FFIgen filter declarations by name?

FFIgen supports including/excluding declarations using full regexp matching.

Here's an example to filter functions using names:

```yaml
functions:
  include:
    - 'clang.*' # Include all functions starting with clang.
  exclude:
    - '.*dispose': # Exclude all functions ending with dispose.
```

This will include `clang_help`. But will exclude `clang_dispose`.

Note: exclude overrides include.

## How does FFIgen handle C Strings?

FFIgen treats `char*` just as any other pointer (`Pointer<Int8>`).
To convert these to/from `String`, you can use [package:ffi](https://pub.dev/packages/ffi).
Use `ptr.cast<Utf8>().toDartString()` to convert `char*` to dart `string` and
`"str".toNativeUtf8()` to convert `string` to `char*`.

## How are unnamed enums handled?

Unnamed enums are handled separately, under the key `unnamed-enums`, and are
generated as top level constants.

Here's an example that shows how to include/exclude/rename unnamed enums:

```yaml
unnamed-enums:
  include:
    - 'CX_.*'
  exclude:
    - '.*Flag'
  rename:
    'CXType_(.*)': '$1'
```

## How can I handle unexpected enum values?

Native enums are, by default, generated into Dart enums with `int get value` and
`fromValue(int)`. This works well in the case that your enums values are known
in advance and not going to change, and in return, you get the full benefits of
Dart enums like exhaustiveness checking.

However, if a native library adds another possible enum value after you generate
your bindings, and this new value is passed to your Dart code, this will result
in an `ArgumentError` at runtime. To fix this, you can regenerate the bindings
on the new header file, but if you wish to avoid this issue entirely, you can
tell FFIgen to generate plain Dart integers for your enum instead. To do this,
simply list your enum's name in the `as-int` section of your FFIgen config:

```yaml
enums:
  as-int:
    include:
      - MyIntegerEnum
      - '*IntegerEnum'
    exclude:
      - FakeIntegerEnum
```

Functions that accept or return these enums will now accept or return integers
instead, and it will be up to your code to map integer values to behavior and
handle invalid values. But your code will be future-proof against new additions
to the enums.

## Why are some struct/union declarations generated even after excluded them in config?

This happens when an excluded struct/union is a dependency to some included
declaration. (A dependency means a struct is being passed/returned by a function
or is member of another struct in some way.)

Note: If you supply `structs.dependency-only` as `opaque` FFIgen will generate
these struct dependencies as `Opaque` if they were only passed by reference
(pointer).

```yaml
structs:
  dependency-only: opaque
unions:
  dependency-only: opaque
```

## How to expose the native pointers?

By default, the native pointers are private, but you can use the
`symbol-address` subkey for functions/globals and make them public by matching
with its name. The pointers are then accessible via `nativeLibrary.addresses`.

Example:

```yaml
functions:
  symbol-address:
    include:
      - 'myFunc' # Match function name.
      - '.*' # Do this to expose all function pointers.
    exclude: # If you only use exclude, then everything not excluded is generated.
      - 'dispose'
```

## How to get typedefs to Native and Dart type of a function?

By default, these types are inline. But you can use the `expose-typedef` subkey
for functions to generate them. This will expose the Native and Dart type.
E.g. for a function named `hello` the generated typedefs are named as
`NativeHello` and `DartHello`.

Example:

```yaml
functions:
  expose-typedefs:
    include:
      - 'myFunc' # Match function name.
      - '.*' # Do this to expose types for all functions.
    exclude: # If you only use exclude, then everything not excluded is generated.
      - 'dispose'
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
  (which need to be specified using `compiler-opts` in config).
- `WARNING` logs are something *you can ignore*, but should probably look into.
  These are mostly indications of declarations FFIgen couldn't generate due
  to limitations of `dart:ffi`, private declarations (which can be resolved
  by renaming them via FFIgen's config) or other minor issues in the config
  file itself.
- Everything else can be safely ignored. Its purpose is to simply let you know
  what FFIgen is doing.
- The verbosity of the logs can be changed by adding a flag with
  the log level, e.g. `dart run ffigen --verbose <level>`.
  Level options are `[all, fine, info (default), warning, severe]`.
  The `all` and `fine` will print a ton of logs are meant for debugging
  purposes only.

## How can type definitions be shared?

FFIgen can share type definitions using symbol files.
- A package can generate a symbol file using the `output.symbol-file` config.
- And another package can then import this, using `import.symbol-files` config.
- Doing so will reuse all the types such as Struct/Unions, and will automatically
  exclude generating other types (E.g. functions, enums, macros).

Checkout `examples/shared_bindings` for details.

For manually reusing definitions from another package, the `library-imports`
and `type-map` config can be used.
