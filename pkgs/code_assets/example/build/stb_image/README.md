# stb_image

This project is a minimal, cross-platform demonstration of how to use Dart's
[build hooks][], with code assets and `dart:ffi` to call a simple function from a
popular C library. This project uses `stbi_info` from the `stb_image.h` library
to read an image's dimensions and color channels without loading the entire file
into memory.

[build hooks]: https://dart.dev/tools/hooks
