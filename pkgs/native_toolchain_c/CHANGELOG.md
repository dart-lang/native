## 0.8.0

- Bump `package:native_assets_cli` to 0.11.0.
- Support for LLVM Clang on Windows (requires MSVC to be installed).

## 0.7.0

- For Android, produce dylibs with page-size set to 16kb by default.
  https://github.com/dart-lang/native/issues/1611
- Make optimization level configurable from `CBuilder`. It defaults to `-3s` and
  `/O3`. https://github.com/dart-lang/native/issues/1267
- Make build mode configurable form `CBuilder`. It defaults to `release`. (The
  build mode was removed from the build config of the hooks.)
- Add `libraries` and `libraryDirectories` to `CTool`.
- Bump `package:native_assets_cli` to 0.10.0.

## 0.6.0

- Address analyzer info diagnostic about multi-line if requiring a block body.
- Bump `package:native_assets_cli` to `0.9.0`. This makes
  `package:native_toolchain_c` now take `BuildOutputBuilder` and
  `LinkOutputBuilder` objects.

## 0.5.4

- Bump `package:native_assets_cli` to `0.8.0`.

## 0.5.3

- Fix internal bug in `LinkerOptions`.
- Bump `package:native_assets_cli` to 0.7.3.

## 0.5.2

- Deprecated `CBuilder`'s constructors `dartBuildFiles`. The Dart sources are
  automatically used for determining whether hooks need to be rerun by newer
  Dart and Flutter SDKs.

## 0.5.1

- Bump `package:native_assets_cli` to 0.7.0.

## 0.5.0

- Renamed parameters in `Builder.run`.
- Added `Language.objectiveC`.
- Use `HookConfig.targetIosSdk` and `HookConfig.targetMacosSdk` optional
  values, and pass them to the clang compiler.

## 0.4.2

- Bump `package:native_assets_cli` to 0.5.0.

## 0.4.1

- Output an `Asset.file` in dry run.
  https://github.com/dart-lang/native/issues/1049

## 0.4.0

- **Breaking change** Completely rewritten API in `native_assets_cli`.
- **Breaking change** No longer assumes `build.dart` to be the main script.
  https://github.com/dart-lang/native/issues/823
- **Breaking change** Use JSON instead of YAML in the protocol.
  https://github.com/dart-lang/native/issues/991
- Bump `package:native_assets_cli` to 0.5.0.

## 0.3.4+1

- Stop depending on private `package:native_assets_cli` `CCompilerConfig` fields.

## 0.3.4

- Bump `package:native_assets_cli` to 0.4.0.

## 0.3.3

- Export `environmentFromBatchFile`.
- Bump `package:native_assets_cli` to 0.3.2.

## 0.3.2

- Added workaround minSdkVersion 19 and 20 for Android.
- Start using sysroot for Android.
- Added tests for up to Android API version 34.

## 0.3.1

- Added MSVC arm64 toolchain.

## 0.3.0

- Bump `package:native_assets_cli` to 0.3.0.

## 0.2.5

- Explicitly tell linker to create position dependent or position independent executable
  ([#113](https://github.com/dart-lang/native/issues/133)).

## 0.2.4

- Added `includes` for specifying include directories.
- Added `flags` for specifying arbitrary compiler flags.
- Added `std` for specifying a language standard.
- Added `language` for selecting the language (`c` and `cpp`) to compile source files as.
- Added `cppLinkStdLib` for specifying the C++ standard library to link against.

## 0.2.3

- Fix MSVC tool resolution inside (x86) folder
  ([#123](https://github.com/dart-lang/native/issues/123)).

## 0.2.2

- Generate position independent code for libraries by default and add
  `pic` option to control this behavior.

## 0.2.1

- Added `defines` for specifying custom defines.
- Added `buildModeDefine` to toggle define for current build mode.
- Added `ndebugDefine` to toggle define of `NDEBUG` for non-debug builds.

## 0.2.0

- **Breaking change** Rename `assetName` to `assetId`
  ([#100](https://github.com/dart-lang/native/issues/100)).
- Added topics.

## 0.1.0

- Initial version.
