# Examples

The examples in `package:hooks` show how to use `package:hooks` and
`package:code_assets` in build hooks to bundle native code with Dart and Flutter
applications.

| Example                                                        | Use Case             | Used Features                                                                                                             |
| :------------------------------------------------------------- | :------------------- | :------------------------------------------------------------------------------------------------------------------------ |
| [`host_name`](../../code_assets/example/host_name)             | Get the hostname.    | - Accessing a system library with `DynamicLoadingSystem` and `LookupInProcess`.<br/>- OS-specific differences.            |
| [`mini_audio`](../../code_assets/example/mini_audio)           | Play audio.          | - C library built from source with `package:native_toolchain_c`.<br/>- Bundled with `DynamicLoadingBundled`.              |
| [`sqlite`](../../code_assets/example/sqlite)                   | Database access.     | - C library built from source with `package:native_toolchain_c`.<br/>- Bundled with `DynamicLoadingBundled`.              |
| [`sqlite_prebuilt`](../../code_assets/example/sqlite_prebuilt) | Database access.     | - Pre-built binary downloaded from the internet or available on host machine.<br/>- Bundled with `DynamicLoadingBundled`. |
| [`stb_image`](../../code_assets/example/stb_image)             | Read image metadata. | - C library built from source with `package:native_toolchain_c`.<br/>- Bundled with `DynamicLoadingBundled`.              |

<!--
The above samples are use-case driven, not feature driven.
When adding new features to hooks, we will update the samples accordingly.
-->

The following examples showcase individual features of of `package:hooks`:

* [build/](build/) contains examples on how to use `hook/build.dart` to build
  and bundle code assets, such as C libraries, into Dart applications.
* [link/](link/) contains examples on how to treeshake unused assets from a Dart
  application using the `hook/link.dart` script.
