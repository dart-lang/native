# Overview



### **wrapper.c**

Contains wrapper functions that interact with pointers because directly passing around structs in dart2wasm is currently not possible

### **include/**

Contains header files for libclang that are used by ffigen to generate dart:ffi bindings.

### **bin/**

Contains libclang.wasm bundled with the wrapper functions built using emscripten.

TODO: Add instructions or a script on how to build libclang.wasm
