The examples in this folder illustrate how assets are built and bundled in Dart
and Flutter apps.

Currently two main asset types are supported in `package:native_assets_cli`:
  * Native libraries
  * Data assets

Note that Data assets are not yet consumable in Dart and Flutter.

Examples:

* Bundling C/C++/Objective-C source code in a package. This native code is built on the developers' machine when such package is a dependency.
  * [native_add_library/](native_add_library/) contains a library with C code.
    When Dart code in this library or dependent on this library is invoked, the
    C code must be built and bundled so that it can be used by the Dart code.
  * [native_add_app/](native_add_app/) has a dependency with C code.
    This app should declare nothing special. Dart and Flutter should check
    all dependencies for native code.
* Bundling prebuilt native libaries.
  * [download_asset/](download_asset/) is very similar to
    [native_add_library/](native_add_library/), but instead of building the
    native code on the machine of developers pulling in the package, the native
    libraries are prebuilt in GitHub actions and downloaded in the build hook.
* Bundling multiple dynamic libraries depending on each other.
  * [native_dynamic_linking/](native_dynamic_linking/) contains source code for
    3 native libraries that depend on each other and load each other with the
    native dynamic loader at runtime.
* Using system libraries
  * [system_library/](system_library/) contains a package using native libaries
    available on the host system where a Dart or Flutter app is deployed.
* Building dynamic libraries against `dart_api_dl.h`.
  * [use_dart_api/](use_dart_api/) contains a library with C code that invokes
    `dart_api_dl.h` to interact with the Dart runtime.
* Bundling all files in a directory as data assets.
  * [local_asset/](local_asset/) contains a package that bundles all files in
    the `assets/` directory as data assets.
* Transforming files and bundling them as data assets.
  * [transformer/](../../../native_assets_builder/test_data/transformer/README.md)
    contains a package that transforms files and bundles the result as data
    assets. The hook uses caching internally to prevent retransforming files if
    not needed.
