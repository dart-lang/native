# Overview

## Contents

### wrapper.c

Contains wrapper functions that interact with pointers because directly passing around structs in dart2wasm is currently not possible

### include/

Contains header files for libclang that are used by ffigen to generate dart:ffi bindings.

### bin/

Contains libclang.wasm along with the wrapper functions present in *wrapper.c*, also contains a list of functions in *libclang.exports* emscripten was made to export.


### llvm-project/

TODO: Add instructions or a script on how to build libclang.wasm