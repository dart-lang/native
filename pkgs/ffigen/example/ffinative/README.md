# Natives example

A simple example generating `Native` bindings for a very small header file (`headers/example.h`).

## Generating bindings
At the root of this example (`example/ffinative`), run -
```
dart run tool/ffigen.dart
```
This will generate bindings in a file: [lib/generated_bindings.dart](./lib/generated_bindings.dart).
