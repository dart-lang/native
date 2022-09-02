# Experimental generator for FFI+JNI bindings.

This package will generate JNI code to invoke Java from C, and Dart FFI bindings to invoke this C code.
This enables calling Java code from Dart.

This is a GSoC 2022 project.

Currently this package is highly experimental and proof-of-concept. See `test/jackson_core_test` for an example of generating bindings for a library. It is possible to specify some dependencies to be downloaded automatically through `maven`.

## Basics
### Running `jni_gen`
There are 2 ways to use `jni_gen`:

* Import `package:jni_gen/jni_gen.dart` from a script in `tool/` directory of your project.
* Run as command line tool with a YAML config.

Both approaches are almost identical. If using YAML, it's possible to selectively override configuration properties with command line, using `-Dproperty.name=value` syntax.

### Generated bindings
Generated bindings will consist of 2 parts - C bindings which call JNI, and Dart bindings which call C bindings. The generated bindings will depend on `package:jni` for instantiating / obtaining a JVM instance.

The following properties must be specified in yaml.

* `c_root`: root folder to write generated C bindings.
* `dart_root`: root folder to write generated Dart bindings (see below).
* `library_name`: specifies name of the generated library in CMakeFiles.txt.

The generated C file has to be linked to JNI libraries. Therefore a CMake configuration is always generated which builds the generated code as shared library. The `init.dart` in generated dart code loads the library on first time a method is accessed. On dart standalone, it will be loaded from the same directory specified in `Jni.spawn` call.

## Examples
Few runnable examples are provided in [examples/](examples/) directory. These directories do not include generated code. Generate the bindings by running `dart run jni_gen --config jnigen.yaml` in the example project root. See the respective READMEs for more details.

