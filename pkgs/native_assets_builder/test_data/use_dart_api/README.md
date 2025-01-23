An example that uses the [C API of the Dart VM].

The example shows how to pass an object from the Dart heap to native code and
hold on to it via a `PersistentHandle`. For more documentation about handles,
and the other C API features refer to the documentation in the header files.

## Usage

Run tests with `dart --enable-experiment=native-assets test`.

[C API of the Dart VM]: https://github.com/dart-lang/sdk/tree/main/runtime/include
