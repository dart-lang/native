The examples in this folder illustrate how native code is built and bundled
in Dart and Flutter apps.

* [native_add_app/](native_add_app/) has a dependency with C code.
  This app should declare nothing special. Dart and Flutter should check
  all dependencies for native code.
* [native_add_library/](native_add_library/) contains a library with C code.
  When Dart code in this library or dependent on this library is invoked, the
  C code must be built and bundled so that it can be used by the Dart code.
