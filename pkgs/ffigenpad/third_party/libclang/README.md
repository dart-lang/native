# Overview

## Contents

### wrapper.c

Contains wrapper functions that interact with pointers because directly passing around structs in dart2wasm is currently not possible.

### libclang.exports

List of functions `bin/libclang.wasm` is made to export by emscripten.

### include/

Contains header files for libclang that are used by ffigen to generate `dart:ffi` bindings.

### llvm-project/

Contains precompiled archive files for building libclang, downloaded using `tool/setup.dart`.
