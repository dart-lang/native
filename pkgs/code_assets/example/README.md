# Examples

These examples show how to use `package:code_assets` in build hooks to bundle native code with Dart and Flutter applications.

| Example                              | Use Case             | Used Features                                                                                                             |
| :----------------------------------- | :------------------- | :------------------------------------------------------------------------------------------------------------------------ |
| [`host_name`](host_name)             | Get the hostname.    | - Accessing a system library with `DynamicLoadingSystem` and `LookupInProcess`.<br/>- OS-specific differences.            |
| [`mini_audio`](mini_audio)           | Play audio.          | - C library built from source with `package:native_toolchain_c`.<br/>- Bundled with `DynamicLoadingBundled`.              |
| [`sqlite`](sqlite)                   | Database access.     | - C library built from source with `package:native_toolchain_c`.<br/>- Bundled with `DynamicLoadingBundled`.              |
| [`sqlite_prebuilt`](sqlite_prebuilt) | Database access.     | - Pre-built binary downloaded from the internet or available on host machine.<br/>- Bundled with `DynamicLoadingBundled`. |
| [`stb_image`](stb_image)             | Read image metadata. | - C library built from source with `package:native_toolchain_c`.<br/>- Bundled with `DynamicLoadingBundled`.              |

<!--
The samples in this directory are use-case driven, not feature driven.
When adding new features to hooks, we will update the samples accordingly.
-->
